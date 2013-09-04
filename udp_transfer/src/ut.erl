-module(ut).

-export([add_user/3, delete_user/3, send_data/2, config/0, list_current_ports/0, list_user/1]).
-export([test/0, send_something/0]).


%%%%===================================================================================
% User Interface
add_user(IP, UserPort, UdpPort) ->
	ut_client_mng:add_user(IP, UserPort, UdpPort),
	ok.

delete_user(IP, UserPort, UdpPort) ->
	ut_client_mng:delete_user(IP, UserPort, UdpPort),
	ok.

send_data(UdpPort, Data) ->
		case ut_store:lookup(UdpPort) of
		{ok, Pid} -> 
			% io:format("Port ~p received data ~p To Pid ~p ~n",[UdpPort, Data, Pid]),
			ut_transfer:send_data(Pid, {send_data, Data});

		{error, not_found} ->
			io:format("Pid for Port ~p not yet created ~n",[UdpPort])
	end,
	ok.

list_current_ports() ->
	Lists = ut_store:to_list(),
	lists:foreach(fun({Port, _}) -> io:format("Port -> ~p~n", [Port]) end, Lists).

list_user(UdpPort) ->
	List = ut_client_mng:list_user(UdpPort),
	lists:foreach(fun({IP, Port}) -> io:format("IP -> ~p  Port -> ~p ~n", [IP, Port]) end, List),
	ok.

config() ->
	case idc:ut_config() of 
		void ->
			io:format("config does not exist~n");
		UserList ->
			lists:foreach(fun({IP, UserPort, UdpPort}) -> add_user(IP, UserPort, UdpPort) end, UserList)
	end.

%%%%===================================================================================
%%%% Just 4 test
test() ->
	add_user("192.168.1.102", 5000, 1455),
	SomeString = "9000 udp",
	send_data(1455, list_to_binary(SomeString)).

send_something() ->
	send_data(1455, "send_something").