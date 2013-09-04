-module(test).

-export([add_msg_radio/3]).
-export([test1/0, test2/0, test3/0]).


test3() ->
	case file:consult("config.dat") of 
		{error, enoent} ->
			io:format("The file does not exist~n");
		{ok, Config} ->
			Func = fun({Term1, Configs}) -> 
				case term1 == Term1 of
					true  -> io:format("-> ~p~n", [Configs]);
					false -> void 
				end
			end,
			lists:foreach(Func, Config)
	end.

test2() ->
	AllExistingTags = [{"tag1", "01", "19"}, {"tag2", "02", "19"}, {"tag3", "03", "19"}],
	String = format_tags_to_string(AllExistingTags, []),
	io:format("~p~n", [String]).

test1() ->
	add_msg_radio(data_collector, mt_event_sensor, []).


add_msg_radio(ModuleOfMsgSource, ModuleOfListener, Args) ->
	ModuleOfMsgSource:add_handler(ModuleOfListener, Args).

format_tags_to_string([], String) -> String;
format_tags_to_string([H|T], String) ->
	{Tag, Ant, Count} = H,
	Packet = ",{" ++ Tag ++ "," ++ Ant ++ "," ++ Count ++ "}",
	NewString = lists:append(String, Packet),
	format_tags_to_string(T, NewString).
