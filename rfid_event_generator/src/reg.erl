-module(reg).

-export([add_port/1, delete_port/1, add_handler/2
		, delete_handler/2, list_current_ports/0
		% , start_port_from_config/0
		, get_current_lease_time/1, set_lease_time/2
		, refresh_port_filter_list/0
		, get_port_filter_list/0
		, event_call/2
		, event_notify/2]).


% start_port_from_config() ->
% 	case file:consult("config.dat") of 
% 		{error, enoent} ->
% 			io:format("config file does not exist~n");
% 		{ok, Config} ->
% 			[{ports, PortList}] = Config,
% 			% lists:foreach(fun({Port}) -> io:format("File -> Port -> ~p~n", [Port]) end, PortList)
% 			lists:foreach(fun({Port}) -> add_port(Port) end, PortList)
% 			% io:format("-> ~p~n", [Config])
% 	end.

list_current_ports() ->
	Lists = reg_store:to_list(),
	lists:foreach(fun({Port, _}) -> io:format("Port -> ~p~n", [Port]) end, Lists).
	% io:format("~p~n", [Lists]).

add_port(UdpPort) ->
	reg_port_mng:add_port(UdpPort),
	reg_event:add_port(UdpPort).

delete_port(UdpPort) ->
	reg_port_mng:delete_port(UdpPort),
	reg_event:delete_port(UdpPort).

add_handler(Handler, Args) ->
	reg_event:add_handler(Handler, Args).

delete_handler(Handler, Args) ->
	reg_event:delete_handler(Handler, Args).

event_call(Handler, Request) ->
	reg_event:call(Handler, Request).
event_notify(Handler, Request) ->
	reg_event:notify(Handler, Request).

get_current_lease_time(UdpPort) ->
	LeaseTime = reg_port_mng:get_lease_time(UdpPort),
	io:format("Current Lease Time -> ~p~n", [LeaseTime]).

set_lease_time(UdpPort, Seconds) ->
	reg_port_mng:set_lease_time(UdpPort, Seconds).

refresh_port_filter_list() ->
	reg_event_sensor:refresh_port_filter_list().

get_port_filter_list() ->
	PortList = reg_event_sensor:get_port_filter_list(),
	io:format("Filter Ports -> ~p~n", [PortList]).

