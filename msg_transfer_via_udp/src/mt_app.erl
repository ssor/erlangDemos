-module(mt_app).
-behaviour(application).

-export([start/2,stop/1, start/0]).

start() ->
	mt_store:init(),
	% mt_event_sensor:add_handler(),
	case mt_sup:start_link() of 
		{ok,Pid} ->
			io:format("Message Transfer Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	

start(_Type,_StartArgs) ->
	mt_store:init(),
	% mt_event_sensor:add_handler(),
	case mt_sup:start_link() of 
		{ok,Pid} ->
			io:format("Message Transfer Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	
stop(_State) ->
	ok.