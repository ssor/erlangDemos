%%%%========================================================================
% This module is used to get event from the data source application.


%%%%========================================================================

-module(icreg_event_sensor_in_mt_transfer).

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
	mt:add_msg_radio(icreg, ?MODULE, []).
	% icreg:add_handler(?MODULE, []).

delete_handler() ->
	mt:delete_msg_radio(icreg, ?MODULE, []).

init([]) ->
	{ok, #state{}}.


% handle_event({add_port, Port}, State) ->
% 	mt_client_mng:add_port(Port),
% 	{ok, State};
% handle_event({delete_port, Port}, State) ->
% 	mt_client_mng:delete_port(Port),
% 	{ok, State};

handle_event({tag_existing, Port, AllExistingTags}, State) -> 
	% io:format("icreg_event_sensor_in_mt_transfer tag_existing ->~n"),
	case length(AllExistingTags) >0 of
		true  ->
			String = format_tags_to_string(AllExistingTags, []),
			Packet = "[tag_existing" ++ String ++ "]",
			mt:send_data(Port, Packet);
		false -> void
	end,
	{ok, State};

handle_event({tag_new, Port, {Tag, Ant, Count}}, State) ->
	Packet = "[tag_new," ++ Tag ++ "," ++ Ant ++ "," ++ Count ++ "]",
	error_logger:info_msg("icreg_event_sensor_in_mt_transfer Port -> ~p  data (~p) ~n", [Port, Packet]),
	mt:send_data(Port, Packet),
	{ok, State};

handle_event({tag_disapear, Port, Tag}, State) ->
	Packet = "[tag_disapear," ++ Tag ++ "]",
	error_logger:info_msg("icreg_event_sensor_in_mt_transfer Port -> ~p  data (~p) ~n", [Port, Packet]),
	mt:send_data(Port, Packet),
	{ok, State};
handle_event(_Request, State) ->
	{ok, State}.

format_tags_to_string([], String) -> String;
format_tags_to_string([H|T], String) ->
	{Tag, Ant, Count} = H,
	Packet = ",{" ++ Tag ++ "," ++ Ant ++ "," ++ Count ++ "}",
	NewString = lists:append(String, Packet),
	format_tags_to_string(T, NewString).


handle_call(_Request, State) ->
	Reply = ok,
	{ok, Reply, State}.

handle_info(_Info, State) ->
	{ok, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
