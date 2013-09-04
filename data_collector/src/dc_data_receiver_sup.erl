-module(dc_data_receiver_sup).
-behaviour(supervisor).

% API
-export([start_link/0, start_child/1, stop_child/1]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
% ?SERVER : used to register as a name

	supervisor:start_link({local, ?SERVER}, ?MODULE, []).
	% supervisor:start_link({local,?SERVER}, ?MODULE, [Port]).
% io:format("~p ~n",[supervisor:start_link({local,?SERVER}, ?MODULE, [Port])]),
% {ok,pid}.

start_child(Port) ->
	supervisor:start_child(?SERVER, [Port]).


stop_child(Pid) ->
	supervisor:terminate_child(?SERVER, Pid).

%% when OTP callback after supervisor:start_link is invoked,
%% init/1 will be used, but as RestartStrategy is set to be
%% simple_one_for_one, no process is spawned. Only ater 
%% supervisor:start_child/2 is invoked, that the init/1 and 
%% simple_one_for_one will work responsively
%% The list after start_link is  the para for create a new
%% child passed from supervisor:start_child's second para,
%% and the passed para will be appended to it permanent
% temporary
init([]) ->
	Receiver = {dc_data_receiver,{dc_data_receiver,start_link,[]},
				permanent, 2 , worker, [dc_data_receiver]},
	Children = [Receiver],
	RestartStrategy = {simple_one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.