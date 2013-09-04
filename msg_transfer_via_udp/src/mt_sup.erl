-module(mt_sup).
-behaviour(supervisor).

% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
	supervisor:start_link({local,?SERVER}, ?MODULE, []).

init([]) ->
	MtTransferSup = {mt_transfer_sup,{mt_transfer_sup,start_link,[]},
					permanent, 2000 , supervisor, [mt_transfer]},
					
	ClientManager = {mt_client_mng, {mt_client_mng, start_link, []},
					permanent, 2000, worker, [mt_client_mng]},
	Children = [ClientManager, MtTransferSup],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.