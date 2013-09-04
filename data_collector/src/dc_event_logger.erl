-module(dc_event_logger).

-behaviour(gen_event).

% API
-export([add_handler/0, delete_handler/0]).

-export([init/1, handle_event/2, handle_call/2,
		 handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

% Add this module as callback
add_handler() ->
	data_collector:add_handler(?MODULE, []).

delete_handler() ->
	data_collector:delete_handler(?MODULE, []).

init([]) ->
	{ok, #state{}}.

handle_event({data, Port, Packet}, State) ->
	error_logger:info_msg("Port -> ~p  data (~p) ~n", [Port, Packet]),
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