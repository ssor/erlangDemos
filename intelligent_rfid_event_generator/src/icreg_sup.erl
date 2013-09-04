-module(icreg_sup).
-behaviour(supervisor).

% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
	icreg_event_sensor:add_handler(),
	supervisor:start_link({local,?SERVER}, ?MODULE, []).

init([]) ->
	GeneratorSup = {icreg_generator_sup,{icreg_generator_sup,start_link,[]},
					permanent, 2000 , supervisor, [icreg_generator]},
					
	PortManager = {icreg_port_mng, {icreg_port_mng, start_link, []},
					permanent, 2000, worker, [icreg_port_mng]},

	EventManager = {icreg_event, {icreg_event, start_link, []},
					permanent, 2000, worker, [icreg_event]},
	Children = [GeneratorSup, PortManager, EventManager],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.