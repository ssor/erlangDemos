-module(zeg_app).
-behaviour(application).

-export([start/0,stop/1, start/2]).


start() ->
	zeg_store:init(),
	% zeg_event_sensor:add_handler(),
	case zeg_sup:start_link() of 
		{ok,Pid} ->
			io:format("Zigbee Event Generator Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.


%%%%=======================================================================
%%%% Callbacks

start(_Type,_StartArgs) ->
	zeg_store:init(),
	% zeg_event_sensor:add_handler(),
	case zeg_sup:start_link() of 
		{ok,Pid} ->
			io:format("Zigbee Event Generator Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	
stop(_State) ->
	ok.