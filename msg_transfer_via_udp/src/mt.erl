-module(mt).

-export([add_user/3, delete_user/3, send_data/2, 
		add_msg_radio/3, list_current_ports/0, 
		delete_msg_radio/3
		 ,list_user/1,
		 config/0]).
-export([test/0, send_something/0, start_sensor_list/0]).


%%%%===================================================================================
% User Interface

add_msg_radio(ModuleOfMsgSource, ModuleOfListener, Args) ->
	ModuleOfMsgSource:add_handler(ModuleOfListener, Args).


delete_msg_radio(ModuleOfMsgSource, ModuleOfListener, Args) ->
	ModuleOfMsgSource:delete_handler(ModuleOfListener, Args).

add_user(IP, UserPort, UdpPort) ->
	mt_client_mng:add_user(IP, UserPort, UdpPort),
	ok.

delete_user(IP, UserPort, UdpPort) ->
	mt_client_mng:delete_user(IP, UserPort, UdpPort),
	ok.

list_user(UdpPort) ->
	List = mt_client_mng:list_user(UdpPort),
	lists:foreach(fun({IP, Port}) -> io:format("IP -> ~p  Port -> ~p ~n", [IP, Port]) end, List),
	% io:format("User List -> ~p~n", [List]),
	ok.
list_current_ports() ->
	Lists = mt_store:to_list(),
	lists:foreach(fun({Port, _}) -> io:format("Port -> ~p~n", [Port]) end, Lists).

send_data(UdpPort, Data) ->
	mt_client_mng:send_data(UdpPort, Data),
	% 	case mt_store:lookup(UdpPort) of
	% 	{ok, Pid} -> 
	% 		% io:format("Port ~p received data ~p To Pid ~p ~n",[UdpPort, Data, Pid]),
	% 		mt_transfer:send_data(Pid, {send_data, Data});

	% 	{error, not_found} ->
	% 		io:format("Pid for Port ~p not yet created ~n",[UdpPort])
	% end,
	ok.
config() ->
	case idc:mt_config() of 
		void ->
			io:format("config does not exist~n");
		UserList ->
			lists:foreach(fun({IP, UserPort, UdpPort}) -> add_user(IP, UserPort, UdpPort) end, UserList)
	end.

start_sensor_list() ->
	% zeg_event_sensor_in_mt_transfer:start().
	iz_event_sensor_in_mt_transfer:start().

%%%%===================================================================================
%%%% Just 4 test
test() ->
	add_user("192.168.1.101", 5000, 1455),
	% SomeString = "9000 udp",
	% send_data(1455, list_to_binary(SomeString)).
	ok.

send_something() ->
	send_data(1455, "send_something").