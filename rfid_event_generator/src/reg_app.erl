-module(reg_app).
-behaviour(application).

-export([start/0,stop/1, start/2]).


start() ->
	reg_store:init(),
	% ut_event_sensor:add_handler(),
	case reg_sup:start_link() of 
		{ok,Pid} ->
			io:format("RFID Event Generator Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.


%%%%=======================================================================
%%%% Callbacks

start(_Type,_StartArgs) ->
	reg_store:init(),
	% ut_event_sensor:add_handler(),
	case reg_sup:start_link() of 
		{ok,Pid} ->
			io:format("RFID Event Generator Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	
stop(_State) ->
	ok.