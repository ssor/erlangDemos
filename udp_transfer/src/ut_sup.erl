-module(ut_sup).
-behaviour(supervisor).

% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
	supervisor:start_link({local,?SERVER}, ?MODULE, []).

init([]) ->
	UtTransferSup = {ut_transfer_sup,{ut_transfer_sup,start_link,[]},
					permanent, 2000 , supervisor, [ut_transfer]},
					
	ClientManager = {ut_client_mng, {ut_client_mng, start_link, []},
					permanent, 2000, worker, [ut_client_mng]},
	Children = [ClientManager, UtTransferSup],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.