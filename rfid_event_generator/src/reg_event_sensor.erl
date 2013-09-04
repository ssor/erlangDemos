%%%%========================================================================
% This module is used to get event from the data source application.


%%%%========================================================================

-module(reg_event_sensor).

-behaviour(gen_event).

% API
-export([add_handler/0, delete_handler/0, refresh_port_filter_list/0
		, get_port_filter_list/0]).

-export([init/1, handle_event/2, handle_call/2,
		 handle_info/2, terminate/2, code_change/3]).

-record(state, {port_list = []}).

% Add this module as callback
add_handler() ->
	data_collector:add_handler(?MODULE, []).

delete_handler() ->
	data_collector:delete_handler(?MODULE, []).

refresh_port_filter_list() ->
	data_collector:event_call(?MODULE, refresh_port_filter_list).

get_port_filter_list() ->
	data_collector:event_call(?MODULE, get_port_filter_list).

init([]) ->
	Config = idc:reg_config(),
	case lists:keyfind(sensor_port_filter, 1, Config) of
		false ->
			% io:format("reg_event_sensor init -> PortFilter is []: ~n", []),
			{ok, #state{port_list = []}};
		{sensor_port_filter, PortList} ->
			% io:format("reg_event_sensor init -> PortFilter: ~p~n", [PortList]),
			{ok, #state{port_list = PortList}}
	end.
			


handle_event({add_port, Port},#state{port_list = PortList} = State) ->
	% here, a filter for port should be added
	% not all port is needed
	case lists:member(Port, PortList) of
		true ->	
			reg:add_port(Port);
			% reg_port_mng:add_port(Port),
			% eg_event:add_port(UdpPort);
		false-> ok
	end,
	{ok, State};
handle_event({delete_port, Port}, State) ->
	% reg_port_mng:delete_port(Port),
	reg:delete_port(Port),
	{ok, State};
handle_event({data, Port, BinaryData}, State) ->
	% error_logger:info_msg("Port -> ~p  data (~p) ~n", [Port, BinaryData]),
	reg_port_mng:send_data(Port, BinaryData),
	{ok, State}.

handle_call(refresh_port_filter_list, State) ->
	Config = idc:reg_config(),
	case lists:keyfind(sensor_port_filter, 1, Config) of
		false ->
			% io:format("reg_event_sensor init -> PortFilter is []: ~n", []),
			{ok, ok, State#state{port_list = []}};
		{sensor_port_filter, PortList} ->
			% io:format("reg_event_sensor init -> PortFilter: ~p~n", [PortList]),
			{ok, ok, State#state{port_list = PortList}}
	end;
handle_call(get_port_filter_list, #state{port_list = PortList} = State) ->
	Reply = PortList,
	{ok, Reply, State};
handle_call(_Request, State) ->
	Reply = ok,
	{ok, Reply, State}.

handle_info(_Info, State) ->
	{ok, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.