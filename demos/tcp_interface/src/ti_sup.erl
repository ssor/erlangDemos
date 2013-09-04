-module(ti_sup).
-behaviour(supervisor).
-export([start_link/1,start_child/0]).
-export([init/1]).
-define(SERVER,?MODULE).

start_link(LSock)->
% start_link(SupName, Module, Args)
% Args is an arbitrary term which is passed as the argument to Module:init/1.
	supervisor:start_link({local,?SERVER},?MODULE,[LSock]).

init([LSock])->
	Server = {ti_server,{ti_server,start_link,[LSock]},
				temporary,brutal_kill,worker,[ti_server]},
	Children = [Server],
	RestartStrategy = {simple_one_for_one,0,1},
	{ok,{RestartStrategy,Children}}.

start_child()->
	supervisor:start_child(?Server,[]).