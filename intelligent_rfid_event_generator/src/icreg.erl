-module(icreg).

-export([add_port/1, delete_port/1, add_handler/2, delete_handler/2
		, start_port_from_config/0, list_current_ports/0
		, get_lease_time/1, get_check_time/1, set_check_time/2
		, set_lease_time/2]).


start_port_from_config() ->
	case file:consult("config.dat") of 
		{error, enoent} ->
			io:format("config file does not exist~n");
		{ok, Config} ->
			[{ports, PortList}] = Config,
			% lists:foreach(fun({Port}) -> io:format("File -> Port -> ~p~n", [Port]) end, PortList)
			lists:foreach(fun({Port}) -> add_port(Port) end, PortList)
			% io:format("-> ~p~n", [Config])
	end.

list_current_ports() ->
	Lists = icreg_store:to_list(),
	lists:foreach(fun({Port, _}) -> io:format("Port -> ~p~n", [Port]) end, Lists).
	% io:format("~p~n", [Lists]).


add_port(UdpPort) ->
	icreg_port_mng:add_port(UdpPort),
	icreg_event:add_port(UdpPort).

delete_port(UdpPort) ->
	icreg_port_mng:delete_port(UdpPort),
	icreg_event:delete_port(UdpPort).

add_handler(Handler, Args) ->
	icreg_event:add_handler(Handler, Args).

delete_handler(Handler, Args) ->
	icreg_event:delete_handler(Handler, Args).

get_check_time(UdpPort) ->
	CheckTime = icreg_port_mng:get_check_time(UdpPort),
	io:format("Port ~p Check Time -> ~p~n", [UdpPort, CheckTime]).

get_lease_time(UdpPort) ->
	Time = icreg_port_mng:get_lease_time(UdpPort),
	io:format("Port ~p Lease Time -> ~p~n", [UdpPort, Time]).

set_check_time(UdpPort, Seconds) ->
	icreg_port_mng:set_check_time(UdpPort, Seconds).

set_lease_time(UdpPort, Seconds) ->
	icreg_port_mng:set_lease_time(UdpPort, Seconds).


