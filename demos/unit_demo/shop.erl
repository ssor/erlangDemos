%% shop.erl

-module(shop).
-export([cost/1,caculate/1,sum/1,sum2/1]).

%% 每种的花费
cost(orange) -> 1;
cost(apple) -> 2.

%% 计算一种的花费
caculate({What,N}) ->
	cost(What) * N.

%% 计算全部的花费
sum([{What,N}|T]) ->
	caculate({What,N}) + sum(T);
	sum([]) -> 0.

%% 列表解析版的计算
sum2(L) ->
	lists:sum([cost(What) * N||{What,N} <- L]).