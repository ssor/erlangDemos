%% @doc This module is created to broadcast some universal infomation
%% Such as the Rest Service host IP and Port

-module(ub).
-export([get_broadcast_content/0,
		 set_broadcast_interval/1,
		  get_broadcast_interval/0,
		   refresh_broadcast_content/0]).

%%%%======================================================================

%% @doc print the content broadcasted
%% @spec get_broadcast_content() -> ok
get_broadcast_content() ->
	{ok, Content} = broadcaster:get_broadcast_content(),
	io:format("~p~n", [Content]),
	ok.

%% @doc Set broadcast interval as second
%% @spec set_broadcast_interval(Interval) -> ok
set_broadcast_interval(Interval) ->
	broadcaster:set_broadcast_interval(Interval),
	ok.

%% @doc Get broadcast interval as second
%% @spec get_broadcast_interval() -> ok
get_broadcast_interval() ->
	Interval = broadcaster:get_broadcast_interval(),
	io:format("Interval now is ~p~n", [Interval]),
	ok.

%% @doc Reread the file to get the latest data to
%%      broadcast
%% @spec refresh_broadcast_content() -> ok
refresh_broadcast_content() ->
	broadcaster:refresh_broadcast_content(),
	ok.
% get_lease_time(Pid) ->
% 	gen_server:call(Pid, get_lease_time).
% set_lease_time(Pid, LeaseTime) ->
% 	gen_server:call(Pid, {set_lease_time, LeaseTime}),
% 	ok.
%%%%======================================================================


%%%%=======================================================================
