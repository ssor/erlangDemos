-module(dc_app).
-behaviour(application).

-export([start/2,stop/1, start/0]).

start() ->
	dc_store:init(),
	case dc_sup:start_link() of 
		{ok,Pid} ->
			io:format("Data Collector Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	
start(_Type,_StartArgs) ->
	% io:format("start/2 ->", []),
	dc_store:init(),
	case dc_sup:start_link() of 
		{ok,Pid} ->
			io:format("Data Collector Running...~n"),
			{ok,Pid};
		Other ->
			{error, Other}
	end.
	
stop(_State) ->
	ok.