-module(reg_sup).
-behaviour(supervisor).

% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
	reg_event_sensor:add_handler(),
	supervisor:start_link({local,?SERVER}, ?MODULE, []).

init([]) ->
	GeneratorSup = {reg_generator_sup,{reg_generator_sup,start_link,[]},
					permanent, 2000 , supervisor, [reg_generator]},
					
	PortManager = {reg_port_mng, {reg_port_mng, start_link, []},
					permanent, 2000, worker, [reg_port_mng]},

	EventManager = {reg_event, {reg_event, start_link, []},
					permanent, 2000, worker, [reg_event]},
	Children = [GeneratorSup, PortManager, EventManager],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.