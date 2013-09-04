%% Feel free to use, reuse and abuse the code in this file.

-module(cowboy_websocket_demo).
-behaviour(application).
-export([start/0, start/2, stop/1]).

start() ->
	application:start(crypto),
	application:start(public_key),
	application:start(ssl),
	application:start(cowboy),
	application:start(cowboy_examples).

start(_Type, _Args) ->
	Dispatch = [
		{'_', [
			{[<<"websocket">>], websocket_demo_handler, []},
			% {[<<"eventsource">>], eventsource_handler, []},
			% {[<<"eventsource">>, <<"live">>], eventsource_emitter, []},
			{'_', default_handler, []}
		]}
	],
	cowboy:start_listener(http, 100,
		cowboy_tcp_transport, [{port, 8080}],
		cowboy_http_protocol, [{dispatch, Dispatch}]
	),
	% cowboy:start_listener(my_https_listener, 100,
	% 	cowboy_ssl_transport, [
	% 		{port, 8443}, {certfile, "priv/ssl/cert.pem"},
	% 		{keyfile, "priv/ssl/key.pem"}, {password, "cowboy"}],
	% 	cowboy_http_protocol, [{dispatch, Dispatch}]
	% ),
	io:format("cowboy_websocket start..."),
	cowboy_websocket_demo_sup:start_link().

stop(_State) ->
	ok.
