%% Feel free to use, reuse and abuse the code in this file.

-module(eventsource_emitter).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/2]).

init({_Any, http}, Req, []) ->
	timer:send_interval(1000, {event, <<"Tick">>}),
	timer:send_after(10000, shutdown),
	{ok, Req, undefined}.

handle(Req, State) ->
	Headers = [{'Content-Type', <<"text/event-stream">>}],
	{ok, Req2} = cowboy_http_req:chunked_reply(200, Headers, Req),
	handle_loop(Req2, State).

handle_loop(Req, State) ->
	receive
		shutdown ->
			{ok, Req, State};
		{event, Message} ->
			Event = ["id: ", id(), "\ndata: ", Message, "\n\n"],
			ok = cowboy_http_req:chunk(Event, Req),
			handle_loop(Req, State)
	end.

terminate(_Req, _State) ->
	ok.


id() ->
	{Mega, Sec, Micro} = erlang:now(),
	Id = (Mega * 1000000 + Sec) * 1000000 + Micro,
	integer_to_list(Id, 16).
