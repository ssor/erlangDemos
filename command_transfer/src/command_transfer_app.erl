%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(command_transfer_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

% GET http://localhost:8080/get_cmd/?flag=inventory&check_time=63513419258

% POST http://localhost:8080/post_cmd/?flag=inventory
% Body 

%% API.
% cowboy_http_protocol 427
start(_Type, _Args) ->
	Dispatch = [
		{'_', [
			{[<<"post_cmd">>], post_cmd_handler, []},
			{[<<"get_cmd">>], post_cmd_handler, []},
			{[<<"check_time">>], post_cmd_handler, []},
			{'_', default_handler, []}
		]}
	],
	{ok, _} = cowboy:start_listener(http, 100,
		cowboy_tcp_transport, [{port, 8080}],
		cowboy_http_protocol, [{dispatch, Dispatch}]
	),
	command_transfer_sup:start_link().

stop(_State) ->
	ok.
