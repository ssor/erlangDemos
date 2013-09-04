-module(dc_sup).
-behaviour(supervisor).

% API
-export([start_link/0, start_child/1, stop_child/1]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
% ?SERVER : used to register as a name
	supervisor:start_link({local,?SERVER}, ?MODULE, []).


start_child(Port) ->
	 dc_data_receiver_sup:start_child(Port).
	% {ok, Pid} = supervisor:start_child(?SERVER, [Port]),
	% {ok, pid}.

stop_child(Pid) ->
	dc_data_receiver_sup:stop_child(Pid).


init([]) ->
	DataReceiverSup = {dc_data_receiver_sup,{dc_data_receiver_sup,start_link,[]},
					permanent, 2000 , supervisor, [dc_data_receiver]},
	EventManager = {dc_event, {dc_event, start_link, []},
					permanent, 2000, worker, [dc_event]},
	Children = [DataReceiverSup, EventManager],
	RestartStrategy = {one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.