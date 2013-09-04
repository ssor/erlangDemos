%%%%========================================================================
% This module is used to get event from the data source application.


%%%%========================================================================

-module(icreg_event_sensor).

-behaviour(gen_event).

% API
-export([add_handler/0, delete_handler/0]).

-export([init/1, handle_event/2, handle_call/2,
		 handle_info/2, terminate/2, code_change/3]).

-record(state, {port_list = []}).

% Add this module as callback
add_handler() ->
	reg:add_handler(?MODULE, []).

delete_handler() ->
	reg:delete_handler(?MODULE, []).

init([]) ->
	{ok, #state{port_list = [1455, 1456]}}.


handle_event({add_port, Port},#state{port_list = PortList} = State) ->
	% here, a filter for port should be added
	% not all port is needed
	% io:format("icreg_event_sensor -> add_port"),
	case lists:member(Port, PortList) of
		true ->	icreg_port_mng:add_port(Port);
		false-> ok
	end,
	{ok, State};
handle_event({delete_port, Port}, State) ->
	icreg_port_mng:delete_port(Port),
	{ok, State};
handle_event({Event, Port, {Tag, Ant, Count}}, State) ->
	% error_logger:info_msg("Port -> ~p  data (~p) ~n", [Port, BinaryData]),
	icreg_port_mng:handle_rfid_event(Port, {Event, Port, {Tag, Ant, Count}}),
	{ok, State}.

handle_call(_Request, State) ->
	Reply = ok,
	{ok, Reply, State}.

handle_info(_Info, State) ->
	{ok, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.