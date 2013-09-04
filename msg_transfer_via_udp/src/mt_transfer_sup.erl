-module(mt_transfer_sup).
-behaviour(supervisor).

% API
-export([start_link/0, start_child/1, stop_child/1]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_child(Port) ->
	% io:format("~p start_child->~n",[?MODULE]),
	supervisor:start_child(?SERVER, [Port]).


stop_child(Pid) ->
	io:format("~p stop_child-> ~p~n",[?MODULE, Pid]),
	case supervisor:terminate_child(?SERVER, Pid) of 
		ok  ->  io:format("stop_child ok"),
				ok;
		{error, Error} -> io:format("stop_child failed, error -> ~p~n",[Error]),
							{error, Error}
	end.

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
	Receiver = {mt_transfer,{mt_transfer,start_link,[]},
				permanent, 2 , worker, [mt_transfer]},
	Children = [Receiver],
	RestartStrategy = {simple_one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.