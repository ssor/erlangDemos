%% @author {{author}}
%% @copyright myapp {{author}}

%% @doc Callbacks for the myapp application.

-module(myapp_app).
% -author("{{author}}").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for myapp.
start(_Type, _StartArgs) ->
	io:format("type => ~p  _StartArgs => ~p~n",[_Type,_StartArgs]),
    myapp_deps:ensure(),
    io:format("start_link ->~n"),
    myapp_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for myapp.
stop(_State) ->
    ok.
