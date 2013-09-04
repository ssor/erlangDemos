-module(izeg_app).
-behaviour(application).

-export([start/0,stop/1, start/2]).


start() ->
	izeg_store:init(),
	% zeg_event_sensor:add_handler(),
	case izeg_sup:start_link() of 
		{ok,Pid} ->
			io:format("Intelligent Zigbee Event Generator Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.


%%%%=======================================================================
%%%% Callbacks

start(_Type,_StartArgs) ->
	izeg_store:init(),
	% zeg_event_sensor:add_handler(),
	case izeg_sup:start_link() of 
		{ok,Pid} ->
			io:format("Intelligent Zigbee Event Generator Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	
stop(_State) ->
	ok.