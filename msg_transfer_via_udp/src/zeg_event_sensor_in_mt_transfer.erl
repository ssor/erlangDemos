%%%%========================================================================
% This module is used to get event from the data source application.


%%%%========================================================================

-module(zeg_event_sensor_in_mt_transfer).

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
	mt:add_msg_radio(zeg, ?MODULE, []).
	% zeg:add_handler(?MODULE, []).

delete_handler() ->
	mt:delete_msg_radio(zeg, ?MODULE, []).

init([]) ->
	{ok, #state{}}.


% handle_event({add_port, Port}, State) ->
% 	mt_client_mng:add_port(Port),
% 	{ok, State};
% handle_event({delete_port, Port}, State) ->
% 	mt_client_mng:delete_port(Port),
% 	{ok, State};

handle_event({event, Port, {Address, NodeID, Huminity, Temp}}, 
				State) -> 
	Packet = "[" ++ "," ++ Address ++ "," ++ NodeID ++ "," ++ integer_to_list(Huminity) ++ "," 
				++ integer_to_list(Temp) ++"]",
	io:format("~p~n", [Packet]),
	mt:send_data(Port, Packet),

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
