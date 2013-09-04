%% @doc Module to generate temperature and humidity event
%%
%% Events generated listed as followed:
%%
%% Events for humidity
%%
%% {interval_humidity_notify, Address, {Address, NodeID, Huminity}}   
%% 
%% {humidity_lower, Address, {Address, NodeID, Humidity}}
%% 
%% {humidity_higher, Address, {Address, NodeID, Humidity}}
%% 
%% {humidity_too_low, Address, {Address, NodeID, Humidity}}
%% 
%% {humidity_too_high, Address, {Address, NodeID, Humidity}}
%% 
%% Events for temperature
%% 
%% {temperature_lower, Address, {Address, NodeID, Temp}}
%% 
%% {temperature_higher, Address, {Address, NodeID, Temp}}
%% 
%% {temperature_too_low, Address, {Address, NodeID, Temp}}
%% 
%% {temperature_too_high, Address, {Address, NodeID, Temp}}
%% 
%% {interval_temperature_notify, Address, {Address, NodeID, Temp}}
%% 
-module(izeg).

-export([add_node/1, delete_node/1, add_handler/2
		, delete_handler/2, list_current_nodes/0
		, event_call/2, event_notify/2
		, refresh_port_filter_list/0
		, get_port_filter_list/0]).

-export([get_huminity_min/1,
		 get_huminity_max/1,
		 get_temperature_max/1,
		 get_temperature_min/1]).

-export([set_humidity_min/2,
			set_humidity_max/2,
			set_temperature_max/2,
			set_temperature_min/2]).

%% @doc Add a node to application
%%
%% If this node is alread added,it will be ignored
%%
%% @spec add_node(string()) -> ok
add_node(Address) ->
	izeg_port_mng:add_node(Address).

%% @doc Remove a node 
%%
%% If this node is not yet added,it will be ignored
%%
%% @spec delete_node(string()) -> ok	
delete_node(Address) ->
	izeg_port_mng:delete_node(Address).

%% @doc Subscribe the event from data_collector
%% @spec add_handler(atom(), term()) -> ok
add_handler(Handler, Args) ->
	izeg_event:add_handler(Handler, Args).

%% @doc Unsubscribe the event from data_collector
%% @spec delete_handler(atom(), term()) -> ok
delete_handler(Handler, Args) ->
	izeg_event:delete_handler(Handler, Args).

%% @doc List all zigbee nodes used in application
%% @spec list_current_nodes() -> ok
list_current_nodes() ->
	Lists = izeg_store:to_list(),
	lists:foreach(fun({zigbeeInfo, Address, _, Index}) -> io:format("Index ~p  Address -> ~p~n", [Index, Address]) end, Lists),
	Lists.
	% io:format("~p~n", [Lists]).

%% @doc Set the mininum humidity
%% @spec set_humidity_min(integer(), integer()) -> ok
set_humidity_min(Index, Value) ->
	case izeg_store:lookup_by_index(Index) of
		{ok, _Address, Pid, _Index} ->
			izeg_generator:set_border_config(Pid, set_huminity_min, Value);

		{error, not_found} -> []
	end.

%% @doc Set the maximum humidity
%% @spec set_humidity_max(integer(), integer()) -> ok	
set_humidity_max(Index, Value) ->
	case izeg_store:lookup_by_index(Index) of
		{ok, _Address, Pid, _Index} ->
			izeg_generator:set_border_config(Pid, set_huminity_max, Value);

		{error, not_found} -> []
	end.

%% @doc Set the maximum temperature
%% @spec set_temperature_max(integer(), integer()) -> ok	
set_temperature_max(Index, Value) ->
	case izeg_store:lookup_by_index(Index) of
		{ok, _Address, Pid, _Index} ->
			izeg_generator:set_border_config(Pid, set_temperature_max, Value);

		{error, not_found} -> []
	end.

%% @doc Set the mininum temperature
%% @spec set_temperature_min(integer(), integer()) -> ok		
set_temperature_min(Index, Value) ->
	case izeg_store:lookup_by_index(Index) of
		{ok, _Address, Pid, _Index} ->
			izeg_generator:set_border_config(Pid, set_temperature_min, Value);

		{error, not_found} -> []
	end.

%% @doc Get the mininum humidity
%% @spec get_huminity_min(integer()) -> integer()
get_huminity_min(Index) ->
	case izeg_store:lookup_by_index(Index) of
		{ok, _Address, Pid, _Index} ->
			izeg_generator:get_border_config(Pid, get_huminity_min);

		{error, not_found} -> []
	end.

%% @doc Get the maximum humidity
%% @spec get_huminity_max(integer()) -> integer()
get_huminity_max(Index) ->
	case izeg_store:lookup_by_index(Index) of
		{ok, _Address, Pid, _Index} ->
			izeg_generator:get_border_config(Pid, get_huminity_max);

		{error, not_found} -> []
	end.

%% @doc Get the maximum temperature
%% @spec get_temperature_max(integer()) -> integer()
get_temperature_max(Index) ->
	case izeg_store:lookup_by_index(Index) of
		{ok, _Address, Pid, _Index} ->
			izeg_generator:get_border_config(Pid, get_temperature_max);

		{error, not_found} -> []
	end.

%% @doc Get the mininum temperature
%% @spec get_temperature_min(integer()) -> integer()
get_temperature_min(Index) ->
	case izeg_store:lookup_by_index(Index) of
		{ok, _Address, Pid, _Index} ->
			izeg_generator:get_border_config(Pid, get_temperature_min);

		{error, not_found} -> []
	end.

event_call(Handler, Request) ->
	izeg_event:call(Handler, Request).
event_notify(Handler, Request) ->
	izeg_event:notify(Handler, Request).

refresh_port_filter_list() ->
	izeg_event_sensor:refresh_port_filter_list().

get_port_filter_list() ->
	PortList = izeg_event_sensor:get_port_filter_list(),
	io:format("Filter Ports -> ~p~n", [PortList]).
