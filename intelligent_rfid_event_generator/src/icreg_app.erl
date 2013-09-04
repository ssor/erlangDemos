-module(icreg_app).
-behaviour(application).

-export([start/0,stop/1, start/2]).

start() ->
	icreg_store:init(),
	% ut_event_sensor:add_handler(),
	case icreg_sup:start_link() of 
		{ok,Pid} ->
			{ok,Pid};
		Other ->
			{error, Other}
	end.


%%%%=======================================================================
%%%% Callbacks

start(_Type,_StartArgs) ->
	icreg_store:init(),
	% ut_event_sensor:add_handler(),
	case icreg_sup:start_link() of 
		{ok,Pid} ->
			io:format("Intelligent Carbinet RFID Event Generator Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	
stop(_State) ->
	ok.