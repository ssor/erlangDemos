-module(test).

-export([test1/0, test2/0]).

-include("ms_transform.hrl").
-record(tagInfo,{epc, ant, count, last_update_time, start_time}).

test2() -> 
	get_event(temperature, 10, 9).

get_event(temperature, LastTemperature, Temp) ->
	if 
		LastTemperature == infinity ->
			temperature_nochange;
		LastTemperature > Temp ->
			temperature_down;
		LastTemperature == Temp ->
			temperature_nochange;
		LastTemperature < Temp ->
			temperature_up
	end.

test1() ->
 % index|Address----------------|node-|humi-|tem--|
 % 01 A5 00 15 8D 00 00 00 28 93 00 01 00 4F 00 1A 07 C5 00 8B 00 49 FF FF
	List1 = "8930001004F001A07C5008B0049FFFF",
	List2 = "01A500158D00000028930001004F001A07C5008B0049FFFF",
	List3 = "7C6007B002EFFFF019B00158D000000289300010033001907CC007B002AFFFF019B00158D000000289300010033001907CC007B002EFFFF019C001",
	% parse_command(List2).
	case splite_command(List3) of
		{nomatch, TailList} ->
			io:format("no match Source ->~p~n", [TailList]);
		{match, CommandList, TailList} ->
			print_command_list(CommandList),
			io:format("TailList -> ~p~n", [TailList])
	end.

splite_command([]) -> {nomatch, []};		
splite_command(StringList) ->
	ReList = "[0-9A-F]{44}FFFF",
	case re:run(StringList, ReList, [global]) of
		{match, Captured} ->
			% io:format("~p~n", [Captured]),
			LastCaptured = lists:last(Captured),
			[{StartIndex, Length}] = LastCaptured,
			TailList = string:substr(StringList, StartIndex + 1 + Length, string:len(StringList) - (StartIndex + Length)),
			% io:format("TailList -> ~p~n", [TailList]),
			{ok, CommandList} = collect_sub_command(Captured, StringList, []),
			% io:format("CommandList -> ~n ~p~n", [CommandList]),
			% print_command_list(CommandList),
			{match, CommandList, TailList};
		nomatch	->
			% io:format("no match~n"),
			{nomatch, StringList}
	end.

collect_sub_command([], _String, CommandList) ->
	{ok, CommandList};
collect_sub_command([H|T], String, CommandList) ->
	[{StartIndex, Length}] = H,
	SubCommand = string:substr(String, StartIndex + 1, Length),
	% io:format("~p~n", [SubCommand]),
	collect_sub_command(T, String, CommandList ++ [SubCommand]).

print_command_list([]) -> ok;
print_command_list([H|T]) ->
	io:format("Command -> ~p~n", [H]),
	print_command_list(T).


parse_command(CommandSub) ->
	Address = string:substr(CommandSub, 5, 16),
	NodeID = string:substr(CommandSub, 21, 4),
	Huminity = string:substr(CommandSub, 25, 4),
	Temp = string:substr(CommandSub, 29, 4),
	io:format("Address -> ~p, NodeID -> ~p, Huminity -> ~p  Temp -> ~p~n",[Address, NodeID, Huminity, Temp]),
	{Address, NodeID, list_to_integer(Huminity, 16), list_to_integer(Temp, 16)}.

sub_command([]) ->
	{ok, []};
sub_command(RawData) ->
	TotalLen = string:len(RawData),
	% io:format("total length -> ~p~n",[TotalLen]),
	case TotalLen >= 48 of
		true ->
			Index = string:rstr(RawData,"FFFF"),
			case Index >= 45 of
				true ->	io:format("Index -> ~p~n",[Index]),
						TailList = string:substr(RawData, Index + 4, TotalLen - (Index + 3)),
						ListBeforeIndex =  string:substr(RawData, 1, Index -45),
						NewList = string:substr(RawData, Index -44, 44),
						io:format("string before Index -> ~p~n", [ListBeforeIndex]),
						io:format("tail string -> ~p~n", [TailList]),
						io:format("the cut string -> ~p~n",[NewList]);

				false-> io:format("Data Not Formated~n")
			% case (string:len(RawData) - Index + 1) >= 110 of
			% 	true -> NewList = string:substr(RawData, Index, 110),
			% 			parse_command(NewList),
			% 			sub_command(ListBeforeIndex);

			% 	false-> sub_command(ListBeforeIndex)
			end;

		false-> {ok, RawData}
	end.
