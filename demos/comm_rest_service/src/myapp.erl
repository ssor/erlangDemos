%% @author {{author}}
%% @copyright {{year}} {{author}}

%% @doc {{appid}}.

-module(myapp).
% -author("{{author}}").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the myapp server.
start() ->
    io:format("start -> ~n"),
    myapp_deps:ensure(),
    io:format("ensure_started~n"),
    ensure_started(crypto),
    io:format("application start ->"),
    application:start(myapp).


%% @spec stop() -> ok
%% @doc Stop the myapp server.
stop() ->
    io:format("start ->~n"),
    application:stop(myapp).
