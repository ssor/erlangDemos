-module(reg_generator_sup).
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
	% io:format("~p stop_child-> ~p~n",[?MODULE, Pid]),
	case supervisor:terminate_child(?SERVER, Pid) of 
		ok  ->  io:format("stop_child ok"),
				ok;
		{error, Error} -> io:format("stop_child failed, error -> ~p~n",[Error]),
							{error, Error}
	end.

%%%%===============================================================================

init([]) ->
	Receiver = {reg_generator,{reg_generator,start_link,[]},
				permanent, 2 , worker, [reg_generator]},
	Children = [Receiver],
	RestartStrategy = {simple_one_for_one, 4, 3600},
	{ok, {RestartStrategy,Children}}.