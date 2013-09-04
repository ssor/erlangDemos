%gen_server template
-module(mt_client_mng).
-behaviour(gen_server).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).

-export([send_data/2, add_port/1, delete_port/1, add_user/3, delete_user/3, start_link/0, list_user/1]).

-record(state,{}).

%%%%=========================================================================================================

send_data(UdpPort, Data) ->
	add_port(UdpPort),
	case mt_store:lookup(UdpPort) of
		{ok, Pid} -> 
			% io:format("Port ~p received data ~p To Pid ~p ~n",[UdpPort, Data, Pid]),
			mt_transfer:send_data(Pid, {send_data, Data});

		{error, not_found} ->
			io:format("error occored for Port ~p  created failed~n",[UdpPort])
	end,
	ok.

add_user(IP, UserPort, UdpPort) ->
	add_port(UdpPort),
	% gen_server:call(?MODULE, {add_user, IP, UserPort, Pid}).
	case mt_store:lookup(UdpPort) of
		{ok, Pid} -> 
			io:format("Pid for Port ~p already exists User info IP:~p Port:~p ~n",[UdpPort, IP, UserPort]),
			gen_server:call(?MODULE, {add_user, IP, UserPort, Pid})
	end.


delete_user(IP, UserPort, UdpPort) ->
	case mt_store:lookup(UdpPort) of
		{ok, Pid} ->
			io:format("delete_user for Port ~p User info IP:~p Port:~p ~n",[UdpPort, IP, UserPort]),
			gen_server:call(?MODULE, {delete_user, IP, UserPort, Pid});

		{error, not_found} -> ok
	end.

list_user(UdpPort) ->
	case mt_store:lookup(UdpPort) of
		{ok, Pid} ->
			gen_server:call(?MODULE, {list_user, Pid});

		{error, not_found} -> []
	end.

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

add_port(UdpPort) ->
	case mt_store:lookup(UdpPort) of
		{ok, _Pid} -> ok;
			% io:format("Pid for Port ~p already exists ~n",[UdpPort]);

		{error, not_found} ->
			io:format("Pid for Port ~p not yet created ~n",[UdpPort]),
		 	{ok, Pid} = mt_transfer_sup:start_child(UdpPort),
		 	% Pid = spawn(fun() -> io:format("fun -> Port ~n",[]) end),
			mt_store:insert(UdpPort, Pid)
			% io:format("Created Child Pid is ~p~n",[Pid])
	end.

delete_port(UdpPort) ->
	case mt_store:lookup(UdpPort) of
		{ok, Pid} ->
			io:format("delete_port for Port ~p  ~n",[UdpPort]),
			mt_transfer_sup:stop_child(Pid),
			mt_store:delete(UdpPort);
			% io:format("deleted Child Pid is ~p~n",[Pid]);
		{error, not_found} -> ok
	end.	


%%%%=========================================================================================================

init([]) ->
	{ok,#state{}}.


handle_call({add_user, IP, UserPort, Pid},
			_From,State) ->
	mt_transfer:add_port_listener(Pid, IP, UserPort),
	Reply = ok,
	{reply,Reply,State};
handle_call({delete_user, IP, UserPort, Pid},
			_From,State) ->
	mt_transfer:delete_port_listener(Pid, IP, UserPort),
	Reply = ok,
	{reply,Reply,State};
handle_call({list_user, Pid}, _From,State) ->
	Reply = mt_transfer:list_user(Pid),
	{reply,Reply,State};

handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State}.

handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(_Info,State) ->
	{noreply,State}.

terminate(_Reason,_State) ->
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

	