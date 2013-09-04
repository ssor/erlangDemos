%gen_server template
-module(ut_transfer).
-behaviour(gen_server).

-export([send_data/2, add_port_listener/3, delete_port_listener/3, start_link/1, list_user/1]).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).
-record(state,{upd_port, lsock, user_port_list = []}).

%%%%======================================================================

send_data(Pid, {send_data, Data}) ->
	gen_server:cast(Pid, {send_data, Data}).

add_port_listener(Pid, UserIP, UserPort) ->
	gen_server:call(Pid, {add_user, UserIP, UserPort}),
	ok.

delete_port_listener(Pid, UserIP, UserPort) ->
	gen_server:call(Pid, {delete_user, UserIP, UserPort}),
	ok.

list_user(Pid) ->
	UserList = gen_server:call(Pid, list_user),
	% io:format("UserList -> ~p~n", [UserList]),
	UserList.
	% [].


start_link(Port) ->
	gen_server:start_link(?MODULE, [Port], []).

%%%%======================================================================

init([UdpPort]) ->
	% io:format("Port ~p is initialized~n",[UdpPort]),
	process_flag(trap_exit, true),
	case  gen_udp:open(0, [binary]) of
		{ok, Socket} 	-> {ok,#state{upd_port = UdpPort, lsock = Socket}, 0};
		{error, Reason} -> io:format("open UDP error:~p~n", [Reason]),
						   {stop, "UDP initialization failed"}
	end.
	

handle_call({add_user, UserIP, UserPort}, _From,
				#state{user_port_list = UserList} = State) ->
	NewUserList = UserList -- [{UserIP, UserPort}],
	NewUserList2 = [{UserIP, UserPort}] ++ NewUserList,
	% io:format("add a user! the latest user list is ~n ~p~n",[NewUserList2]),
	Reply = ok,
	{reply,Reply,State#state{user_port_list = NewUserList2}};
handle_call({delete_user, UserIP, UserPort},_From,
				#state{user_port_list = UserList} = State) ->
	NewUserList = UserList -- [{UserIP, UserPort}],
	% io:format("Delete a user! the latest user list is ~n ~p~n",[NewUserList]),
	Reply = ok,
	{reply,Reply,State#state{user_port_list = NewUserList}};

handle_call(list_user, _From, #state{user_port_list = UserList} = State) ->
	Reply = UserList,
	{reply,Reply,State};

handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State}.

handle_cast({send_data, Data}, 
				#state{user_port_list = UserList, lsock = Socket, upd_port = UdpPort} = State) ->
	transfer_data_to_users(UdpPort, Data, UserList, Socket),
	{noreply, State};
handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(_Request, State) ->
	{noreply, State}.


terminate(_Reason, State) ->
	Port = State#state.upd_port,
	io:format("port ~p terminate here ~n",[Port]),
	Socket = State#state.lsock,
	gen_udp:close(Socket),
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

%%%%=======================================================================
transfer_data_to_users(_UdpPort, _Data, [], _Socket) ->
	ok;
transfer_data_to_users(UdpPort, Data, UserList, Socket) ->
	[{UserIP, UserPort} | T] = UserList,
	% io:format("From port ~p To ~p:~p  Data: ~p~n",[UdpPort, UserIP, UserPort, Data]),
	case gen_udp:send(Socket, UserIP, UserPort, Data) of
		ok   -> ok;
		{error, Reason} -> io:format("UDP send data error:~p~n", [Reason])
	end,
	transfer_data_to_users(UdpPort, Data, T, Socket).
