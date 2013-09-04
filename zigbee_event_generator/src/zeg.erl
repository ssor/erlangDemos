% edoc:files(["zeg.erl"],[{dir, "../doc/zeg"}]).

%% @doc This application will generate basic event of temperature and humunity
%%
%% This application will first subscribe event of data_collector to get data 
%% source, and then the data will be disposed through its protocol.
%%
%% The generated events list as followed:
%% {event, Port, {Address, NodeID, Huminity, Temperature}}
%%
-module(zeg).

-export([add_port/1, delete_port/1, add_handler/2
		, delete_handler/2, list_current_ports/0
		, event_call/2, event_notify/2
		, refresh_port_filter_list/0
		, get_port_filter_list/0]).

%% @doc Add a port to application
%%
%% If this port is alread added,it will be ignored
%%
%% This is not used usually,as this is automatically
%%  executed when a event occored in data_collector
%% @spec add_port(integer()) -> ok
add_port(UdpPort) ->
	zeg_port_mng:add_port(UdpPort).

%% @doc Remove a port 
%%
%% If this port is not yet added,it will be ignored
%%
%% This is not used usually,as this is automatically
%%  executed when a event occored in data_collector
%% @spec delete_port(integer()) -> ok	
delete_port(UdpPort) ->
	zeg_port_mng:delete_port(UdpPort).

%% @doc Subscribe the event from data_collector
%% @spec add_handler(atom(), term()) -> ok
add_handler(Handler, Args) ->
	zeg_event:add_handler(Handler, Args).

%% @doc Unsubscribe the event from data_collector
%% @spec delete_handler(atom(), term()) -> ok
delete_handler(Handler, Args) ->
	zeg_event:delete_handler(Handler, Args).

%% @doc List all ports used in application
%% @spec list_current_ports() -> ok
list_current_ports() ->
	Lists = zeg_store:to_list(),
	lists:foreach(fun({Port, _}) -> io:format("Port -> ~p~n", [Port]) end, Lists).
	% io:format("~p~n", [Lists]).

event_call(Handler, Request) ->
	zeg_event:call(Handler, Request).
event_notify(Handler, Request) ->
	zeg_event:notify(Handler, Request).

%% @doc As not all ports are needed, a filter list is set to only allow 
%% some ports' data to be disposed.This will read config file to refresh 
%% the filter list
refresh_port_filter_list() ->
	zeg_event_sensor:refresh_port_filter_list().

%% @doc Print the filter port list
get_port_filter_list() ->
	PortList = zeg_event_sensor:get_port_filter_list(),
	io:format("Filter Ports -> ~p~n", [PortList]).
