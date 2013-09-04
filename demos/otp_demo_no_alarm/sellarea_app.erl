-module(sellarea_app).
-behaviour(application).
-export([start/2,stop/1]).

start(_Type,StartArgs)->
	sellarea_supervisor:start_link(StartArgs).


stop(_State)->
	ok.