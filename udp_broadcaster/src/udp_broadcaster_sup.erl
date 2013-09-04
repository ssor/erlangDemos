-module(udp_broadcaster_sup).
-behaviour(supervisor).

%% API.
-export([start_link/0]).

%% supervisor.
-export([init/1]).

%% API.

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% supervisor.

init([]) ->
	% Procs = [],
	% {ok, {{one_for_one, 10, 10}, Procs}}.

	Broadcaster = {broadcaster, {broadcaster, start_link, []},
					permanent, 2000, worker, [broadcaster]},
	Children = [Broadcaster],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy, Children}}.
