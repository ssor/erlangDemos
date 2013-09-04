-module(zeg_sup).
-behaviour(supervisor).

% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
	zeg_event_sensor:add_handler(),
	supervisor:start_link({local,?SERVER}, ?MODULE, []).

init([]) ->
	GeneratorSup = {zeg_generator_sup,{zeg_generator_sup,start_link,[]},
					permanent, 2000 , supervisor, [reg_generator]},
					
	PortManager = {zeg_port_mng, {zeg_port_mng, start_link, []},
					permanent, 2000, worker, [zeg_port_mng]},

	EventManager = {zeg_event, {zeg_event, start_link, []},
					permanent, 2000, worker, [zeg_event]},
	Children = [GeneratorSup, PortManager, EventManager],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.