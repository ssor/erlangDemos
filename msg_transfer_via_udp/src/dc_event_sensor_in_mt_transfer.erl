%%%%========================================================================
% This module is used to get event from the data source application.


%%%%========================================================================

-module(dc_event_sensor_in_mt_transfer).

-behaviour(gen_event).

% API
-export([start/0, add_handler/0, delete_handler/0]).

-export([init/1, handle_event/2, handle_call/2,
		 handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

% Add this module as callback


start() ->
	add_handler().

add_handler() ->
	mt:add_msg_radio(data_collector, ?MODULE, []).
	% icreg:add_handler(?MODULE, []).

delete_handler() ->
	mt:delete_msg_radio(data_collector, ?MODULE, []).

init([]) ->
	{ok, #state{}}.


% handle_event({add_port, Port}, State) ->
% 	mt_client_mng:add_port(Port),
% 	{ok, State};
% handle_event({delete_port, Port}, State) ->
% 	mt_client_mng:delete_port(Port),
% 	{ok, State};


handle_event({data, Port, Packet}, State) ->
	% error_logger:info_msg("icreg_event_sensor_in_mt_transfer Port -> ~p  data (~p) ~n", [Port, Packet]),
	mt:send_data(Port, Packet),
	{ok, State};
handle_event(_Request, State) ->
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
