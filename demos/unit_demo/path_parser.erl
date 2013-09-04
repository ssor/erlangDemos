-module(path_parser).

-export([test/1]).


test([]) ->
	parse("/timer/1/id/zhang/name/quan");
test(Path) ->
	parse(Path).

% 检查路径是否符合最基本的规定
parse(UrlPath)->
	H = string:tokens(UrlPath,"/"),
	io:format("~p~n",[H]),
	if
		length(H) rem 2 =:= 0 ->
		Dic = dict:new(),
		Dic2 = get_key_value(H,Dic),
		
		% 打印测试
		Keys = dict:fetch_keys(Dic2),
		pring_key_value(Dic2,Keys)
	end.

%解析路径成键值对
get_key_value([],Dic) -> Dic;
get_key_value([Key|T],Dic)->
		% io:format("key_values ~p~n",[raw_key_value_list]),
		[Value|T2] = T,
		Dic2 = dict:store(Key,Value,Dic),
		get_key_value(T2,Dic2).

% 打印字典里的键值
pring_key_value([],_Dic) -> ok;
pring_key_value([Key|T],Dic)->
	Value = dict:fetch(Key,Dic),
	io:format("key -> ~p   value -> ~p ~n",[Key,Value]),
	pring_key_value(Dic,T).


