%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(mtvh_sup).
-behaviour(supervisor).

%% API.
-export([start_link/0]).

%% supervisor.
-export([init/1]).

%% API.

start_link() ->
	% command_store:init(),
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% supervisor.

init([]) ->
	% Procs = [],
	% {ok, {{one_for_one, 10, 10}, Procs}}.

	CommandManager = {command_store, {command_store, start_link, []},
					permanent, 2000, worker, [command_store]},
	Children = [CommandManager],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy, Children}}.
