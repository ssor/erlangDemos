-module(udp_broadcaster_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	udp_broadcaster_sup:start_link().

stop(_State) ->
	ok.
