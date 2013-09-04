-module(izeg_sup).
-behaviour(supervisor).

% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
	izeg_event_sensor:add_handler(),
	supervisor:start_link({local,?SERVER}, ?MODULE, []).

init([]) ->
	GeneratorSup = {izeg_generator_sup,{izeg_generator_sup,start_link,[]},
					permanent, 2000 , supervisor, [ireg_generator]},
					
	NodeManager = {izeg_node_mng, {izeg_node_mng, start_link, []},
					permanent, 2000, worker, [izeg_node_mng]},

	EventManager = {izeg_event, {izeg_event, start_link, []},
					permanent, 2000, worker, [izeg_event]},
	Children = [GeneratorSup, NodeManager, EventManager],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.