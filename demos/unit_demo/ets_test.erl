-module(ets_test).
-export([start/0]).


start() -> 
	% lists:foreach(fun test_ets/1,[set,ordered_set,bag,duplicate_bag]).
	test_ets(set).

test_ets(Mode) ->
		TableId = ets:new(test,[Mode]),
		ets:insert(TableId,{a,1}),
		ets:insert(TableId,{b,1}),
		ets:insert(TableId,{c,1}),
		ets:insert(TableId,{d,3}),
		List = ets:tab2list(TableId),
		io:format("~-13w => ~p~n",[Mode,List]),
		MatchList = ets:match(TableId,{a,1}),
		io:format("~p~n",MatchList),
		ets:delete(TableId).
