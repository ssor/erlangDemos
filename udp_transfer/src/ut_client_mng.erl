%gen_server template
-module(ut_client_mng).
-behaviour(gen_server).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).

-export([add_port/1, delete_port/1, add_user/3, delete_user/3, start_link/0, list_user/1]).

-record(state,{}).

%%%%=========================================================================================================
add_port(UdpPort) ->
	case ut_store:lookup(UdpPort) of
		{ok, _Pid} -> 
			ok;
			% io:format("Pid for Port ~p already exists ~n",[UdpPort]);

		{error, not_found} ->
			% io:format("Pid for Port ~p not yet created ~n",[UdpPort]),
		 	{ok, Pid} = ut_transfer_sup:start_child(UdpPort),
		 	% Pid = spawn(fun() -> io:format("fun -> Port ~n",[]) end),
			% io:format("Created Child Pid is ~p~n",[Pid]),
			ut_store:insert(UdpPort, Pid)
	end.	

add_user(IP, UserPort, UdpPort) ->
	add_port(UdpPort),
	% gen_server:call(?MODULE, {add_user, IP, UserPort, Pid}).
	case ut_store:lookup(UdpPort) of
		{ok, Pid} -> 
			% io:format("Pid for Port ~p already exists User info IP:~p Port:~p ~n",[UdpPort, IP, UserPort]),
			gen_server:call(?MODULE, {add_user, IP, UserPort, Pid})
	end.

delete_port(UdpPort) ->
	case ut_store:lookup(UdpPort) of
		{ok, Pid} ->
			% io:format("delete_port for Port ~p  ~n",[UdpPort]),
			ut_transfer_sup:stop_child(Pid),
			% io:format("deleted Child Pid is ~p~n",[Pid]),
			ut_store:delete(UdpPort);
		{error, not_found} -> ok
	end.	

delete_user(IP, UserPort, UdpPort) ->
	case ut_store:lookup(UdpPort) of
		{ok, Pid} ->
			% io:format("delete_user for Port ~p User info IP:~p Port:~p ~n",[UdpPort, IP, UserPort]),
			gen_server:call(?MODULE, {delete_user, IP, UserPort, Pid});

		{error, not_found} -> ok
	end.

list_user(UdpPort) ->
	case ut_store:lookup(UdpPort) of
		{ok, Pid} ->
			gen_server:call(?MODULE, {list_user, Pid});

		{error, not_found} -> []
	end.


start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%%=========================================================================================================

init([]) ->
	{ok,#state{}}.


handle_call({add_user, IP, UserPort, Pid},
			_From,State) ->
	ut_transfer:add_port_listener(Pid, IP, UserPort),
	Reply = ok,
	{reply,Reply,State};
handle_call({delete_user, IP, UserPort, Pid},
			_From,State) ->
	ut_transfer:delete_port_listener(Pid, IP, UserPort),
	Reply = ok,
	{reply,Reply,State};
handle_call({list_user, Pid}, _From,State) ->
	Reply = ut_transfer:list_user(Pid),
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

	