-module(json_test).
-compile(export_all).

% 40> J = "{\"name\":\"zhang\",\"age\":23}".
% "{\"name\":\"zhang\",\"age\":23}"
% 41> O = rfc4627:decode(J).
% {ok,{obj,[{"name",<<"zhang">>},{"age",23}]},[]}
% 42> {ok,{obj,List},_} = O.
% {ok,{obj,[{"name",<<"zhang">>},{"age",23}]},[]}
% 43> List.
% [{"name",<<"zhang">>},{"age",23}]


test_all() -> 
	Obj1 = {obj, [{name, hideto}, {age, 23}]},
 	Json1 = rfc4627:encode(obj1),
 	io:format("object ~p~n encoded ~p~n",[Obj1,Json1]),
% "{\"name\":\"hideto\",\"age\":23}"
	Obj2 = rfc4627:decode(Json1),
 	io:format(" encoded ~p~nobject ~p~n",[Json1,Obj2]),

 	Obj3 = [1,2,3,4,5],
	Json2 = rfc4627:encode(Obj3),
 	io:format("object ~p~n encoded ~p~n",[Obj3,Json2]),

 	Obj4 = rfc4627:decode(Json2),
 	io:format(" encoded ~p~nobject ~p~n",[Json2,Obj4]),

 	Obj5 = 12345,
 	Json3 = rfc4627:encode(Obj5),
 	io:format("object ~p~n encoded ~p~n",[Obj5,Json3]),

 	Obj6 = rfc4627:decode(Json3),
 	io:format(" encoded ~p~nobject ~p~n",[Json3,Obj6]),

 	Obj7 = "12345",
 	Json4 = rfc4627:encode(Obj7),
 	io:format("object ~p~n encoded ~p~n",[Obj7,Json4]),

 	Obj8 = rfc4627:decode(Json4),
 	io:format(" encoded ~p~nobject ~p~n",[Json4,Obj8]),

 	Obj9 = true,
 	Json5 = rfc4627:encode(Obj9),
 	io:format("object ~p~n encoded ~p~n",[Obj9,Json5]),
 	Obj10 = rfc4627:decode(Json5),
 	io:format(" encoded ~p~nobject ~p~n",[Json5,Obj10]),

 	Obj11 = null,
 	Json6 = rfc4627:encode(Obj11),
 	io:format("object ~p~n encoded ~p~n",[Obj11,Json6]),
 	Obj12 = rfc4627:decode(Json6),
 	io:format(" encoded ~p~nobject ~p~n",[Json6,Obj12]).
