-module(ut_app).
-behaviour(application).

-export([start/2,stop/1]).

% start() ->
% 	ut_store:init(),
% 	case ut_sup:start_link() of 
% 		{ok,Pid} ->
% 			{ok,Pid};
% 		Other ->
% 			{error, Other}
% 	end.
	

start(_Type,_StartArgs) ->
	ut_store:init(),
	ut_event_sensor:add_handler(),
	case ut_sup:start_link() of 
		{ok,Pid} ->
			io:format("udp_transfer running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	
stop(_State) ->
	ok.