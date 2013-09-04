%% Feel free to use, reuse and abuse the code in this file.

-module(msg_transfer_via_http).

%% API.
-export([start/0]).

%% API.

start() ->
	ok = application:start(cowboy),
	ok = application:start(echo_get).
