-module(test).

-export([test1/0, test2/0, test3/1, test4/0, test5/0]).

-include("ms_transform.hrl").
-record(tagInfo,{epc, ant, count, last_read_time, start_time}).

%%%%===================================================================================
%%%% Just 4 test

test5() ->
	% ReList = "Disc:\\d{4}/\\d{2}/\\d{2}\\s\\d{2}:\\d{2}:\\d{2},\\sLast:\\d{4}/\\d{2}/\\d{2}\\s\\d{2}:\\d{2}:\\d{2},\\sCount:\\d{5},\\sAnt:\\d{2},\\sType:\\d{2},\\sTag:[a-f0-9A-F]{24}",
	List1 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:0",
	List2 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C00101AA01Disc",
	% io:format("~p~n", [string:substr(List2, 1 ,110)]),
	List5 = "ast:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C001010105   
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:02, Type:04, Tag:300833B2DDD906C001010106  
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:01, Type:04, Tag:300833B2DDD906C001010107
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:01, Type:04, Tag:300833B2DDD906C001010108
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:01, Type:04, Tag:300833B2DDD906C001010109
Disc:2000/02/28 20:01:51, Las",
	case splite_command(List1) of
		{nomatch, TailList} ->
			io:format("no match Source ->~p~n", [TailList]);
		{match, CommandList, TailList} ->
			print_command_list(CommandList),
			io:format("TailList -> ~p~n", [TailList])
	end.

	% case re:run(List2, ReList, [global]) of
	% 	{match, Captured} ->
	% 		io:format("~p~n", [Captured]),
	% 		LastCaptured = lists:last(Captured),
	% 		[{StartIndex, Length}] = LastCaptured,
	% 		TailList = string:substr(List2, StartIndex + 1 + Length, string:len(List2) - (StartIndex + Length)),
	% 		io:format("TailList -> ~p~n", [TailList]),
	% 		{ok, CommandList} = collect_sub_command(Captured, List2, []),
	% 		% io:format("CommandList -> ~n ~p~n", [CommandList]),
	% 		print_command_list(CommandList);
	% 	nomatch	->
	% 		io:format("no match~n")
	% end.
	% case re:run("E-mail: xyz@pdq.com", "[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-z]{2,3}") of
	% 	{match, Captured2} ->
	% 		io:format("~p~n", [Captured2]);
	% 	nomatch	->
	% 		io:format("no match~n")
	% end.
splite_command([]) -> {nomatch, []};		
splite_command(StringList) ->
	ReList = "Disc:\\d{4}/\\d{2}/\\d{2}\\s\\d{2}:\\d{2}:\\d{2},\\sLast:\\d{4}/\\d{2}/\\d{2}\\s\\d{2}:\\d{2}:\\d{2},\\sCount:\\d{5},\\sAnt:\\d{2},\\sType:\\d{2},\\sTag:[a-f0-9A-F]{24}",
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


test3(LeaseTime) ->
	List1 = ["300833B2DDD906C001010101","300833B2DDD906C001010102","300833B2DDD906C001010103"],
	delete_tag_for_time_elapse(List1).
	% Now = calendar:local_time(),
	% io:format("Now is ~p~n", [Now]),
	% CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	% io:format("CurrentTime is ~p~n", [CurrentTime]),
	% StartTime = 63511300654,
	% time_left(StartTime, LeaseTime).
	% time_min(LeaseTime).
	% ok.

delete_tag_for_time_elapse( []) -> ok;
delete_tag_for_time_elapse( [H|Tags]) ->
	io:format("tag ~p is deleted for time Elapse~n", [H]),
	% ets:match_delete(TagEts, #tagInfo{epc = H, _ = '_'}),
	delete_tag_for_time_elapse(Tags).


time_left(_StartTime, infinity) ->
	infinity;
time_left(StartTime, LeaseTime) ->
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	TimeElapsed = CurrentTime - StartTime,
	case LeaseTime - TimeElapsed of 
		Time when Time =< 0 -> 0;
		Time 				-> Time * 1000
	end.

% 
test4() ->
	TagEts = ets:new(ets, [{keypos, #tagInfo.epc}]),
	List1 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C001010101",
	List2 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C001010102",
	List3 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C001010102",
	List4 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:43, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C001010102",
	List5 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:43, Count:00019, Ant:08, Type:04, Tag:300833B2DDD906C001010102",
	List6 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:43, Count:00019, Ant:05, Type:04, Tag:300833B2DDD906C001010102",
	{ok, Event1, Ets1} = parse_new_command_text(List1, TagEts),
	io:format("~p~n", [Event1]),
	{ok, Event2, Ets2} = parse_new_command_text(List2, Ets1),
	io:format("~p~n", [Event2]),
	{ok, Event3, Ets3} = parse_new_command_text(List3, Ets2),
	io:format("~p~n", [Event3]),
	{ok, Event4, Ets4} = parse_new_command_text(List4, Ets3),
	io:format("~p~n", [Event4]),
	{ok, Event5, Ets5} = parse_new_command_text(List5, Ets4),
	io:format("~p~n", [Event5]),
	{ok, Event6, Ets6} = parse_new_command_text(List6, Ets5),
	io:format("~p~n", [Event6]),
	ok.
parse_new_command_text(CommandList, TagEts) ->
	% {Count, Ant, Tag, LastReadTime} = parse_command(CommandList),
	{ok, #tagInfo{epc = Tag, count = Count, ant = Ant, last_read_time = LastReadTime, start_time = StartTime} = TagInfo}
		= parse_command(CommandList),
	% io:format("~p~n", [TagInfo]),
	% Now = calendar:local_time(),		
	% StartTime = calendar:datetime_to_gregorian_seconds(Now),
	NewTagInfo = #tagInfo{epc = Tag, last_read_time = LastReadTime, count = Count, ant = Ant, start_time = StartTime},
	case ets:lookup(TagEts, Tag) of
		[#tagInfo{ant = Ant4, last_read_time = LastReadTime4}] ->
			case Ant4 == Ant of 
				false -> 
					case lists:member(Ant, ["01", "02", "04", "08"]) of 
						true  -> 
							% io:format("Ant Changed From ~p To ~p~n", [Ant4, Ant]),
							update_taginfo(TagEts, NewTagInfo),
							{ok, tag_ant_change, TagEts};
						false ->
							% io:format("Wrong Read ~n"),
							% ant is not updated
							NewTagInfo2 = #tagInfo{epc = Tag, last_read_time = LastReadTime, count = Count, start_time = StartTime},
							update_taginfo(TagEts, NewTagInfo2),
							{ok, tag_missed_read, TagEts}
					end;
				true  ->
					case LastReadTime == LastReadTime4 of
						true  -> 
							% io:format("Nothing Changed !~n"),
							{ok, tag_nothing_changed, TagEts};
						false ->
							 % io:format("Time updated~n"),
							 update_taginfo(TagEts, NewTagInfo),
							{ok, tag_time_update, TagEts}
					end
			end; 
		[] ->

			insert_taginfo(TagEts, NewTagInfo),
			{ok, insert_new_tag, TagEts}
	end.

insert_taginfo(TagEts,#tagInfo{epc = Tag} = TagInfo) ->
	% io:format("add a Tag ~p~n", [Tag]),
	ets:insert(TagEts, TagInfo).
update_taginfo(TagEts,#tagInfo{epc = Tag} = TagInfo) ->
	% io:format("update a Tag ~p~n", [Tag]),
	ets:insert(TagEts, TagInfo).


test2() ->

	TagEts = ets:new(ets, [{keypos, #tagInfo.epc}]),
	List = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C001010101",
	{ok, #tagInfo{epc = Tag, ant = Ant, count = Count, last_read_time = LastReadTime}} = parse_command(List),
	Now = calendar:local_time(),		
	StartTime = calendar:datetime_to_gregorian_seconds(Now),
	NewTagInfo = #tagInfo{epc = Tag, ant = Ant, count = Count, start_time = StartTime, last_read_time = LastReadTime},
	ets:insert(TagEts, NewTagInfo),
	List2 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00018, Ant:02, Type:04, Tag:300833B2DDD906C001010103",
	{ok, #tagInfo{epc = Tag2, ant = Ant2, count = Count2, last_read_time = LastReadTime2}} = parse_command(List2),
	NewTagInfo2 = #tagInfo{epc = Tag2, ant = Ant2, count = Count2, start_time = StartTime, last_read_time = LastReadTime2},
	ets:insert(TagEts, NewTagInfo2),

	% FuncMatch = ets:fun2ms(fun(#tagInfo{ epc = Epc}) -> Epc end),
	% [H|_Objects] = ets:select(TagEts, FuncMatch) ,
	% io:format("match all -> ~p~n", [H]),
	Lists = ets:tab2list(TagEts),
	io:format("match all -> ~p~n", [Lists]),


	% Tag3 = "300833B2DDD906C001010103",
	% case ets:lookup(TagEts, Tag3) of
	% 	[#tagInfo{epc = Tag4, count = Count4, ant = Ant4}] -> 
	% 		io:format("search ~p -> tag ~p, count ~p, ant ~p~n",[Tag3, Tag4, Count4, Ant4]),
	% 		% update
	% 		ets:insert(TagEts, #tagInfo{epc = Tag4, start_time = StartTime, count = "001", ant = Ant4});
	% 	[] ->
	% 		io:format("search ~p , found nothing!!~n", [Tag3])
	% end,
	% FuncMatch = ets:fun2ms(fun(#tagInfo{epc = Epc}) when Epc == Tag3 -> Epc end),
	% case ets:select(TagEts, FuncMatch) of 
	% 	[Tag7|_] ->
	% 		io:format("search ~p -> tag ~p~n",[Tag3, Tag7]);
	% 	[] ->
	% 		io:format("search ~p , found nothing!!~n", [Tag3])
	% end,
	% case ets:lookup(TagEts, Tag3) of
	% 	[#tagInfo{epc = Tag5, count = Count5, ant = Ant5}] -> 
	% 		io:format("search ~p -> tag ~p, count ~p, ant ~p~n",[Tag3, Tag5, Count5, Ant5]),
	% 		% delete
	% 		ets:match_delete(TagEts, #tagInfo{epc = Tag3, _ = '_'});
	% 	[] ->
	% 		io:format("search ~p , found nothing!!~n", [Tag3])
	% end,
	% case ets:lookup(TagEts, Tag3) of
	% 	[#tagInfo{epc = Tag6, count = Count6, ant = Ant6}] -> 
	% 		io:format("search ~p -> tag ~p, count ~p, ant ~p~n",[Tag3, Tag6, Count6, Ant6]);
	% 	[] ->
	% 		io:format("search ~p , found nothing!!~n", [Tag3])
	% end,
	ok.





test1() ->
	List1 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C00101AA01",
	List2 = "p101Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C00101AA01",
	List3 = "Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C00101AA01Disc",
	List4 = "ast:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C001010102   
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:02, Type:04, Tag:300833B2DDD906C001010103  
Disc:2000/02/28 20:01:51, Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:08, Type:04, Tag:300833B2DDD90",
	List5 = "ast:2000/02/28 20:07:42, Count:00019, Ant:04, Type:04, Tag:300833B2DDD906C001010105   
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:02, Type:04, Tag:300833B2DDD906C001010106  
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:01, Type:04, Tag:300833B2DDD906C001010107
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:01, Type:04, Tag:300833B2DDD906C001010108
Disc:2000/02/28 20:01:51, Last:2000/02/28 20:07:42, Count:00019, Ant:01, Type:04, Tag:300833B2DDD906C001010109
Disc:2000/02/28 20:01:51, Las",
	List6 = "",

	% sub_command(List1).
	% sub_command(List2).
	% sub_command(List3).
	% sub_command(List4).
	sub_command(List5).
	% sub_command(List6).

% sub_command([], []) ->
% 	{ok, []};

sub_command(RawData) ->
	TotalLen = string:len(RawData),
	% io:format("total length -> ~p~n",[TotalLen]),
	case TotalLen >= 110 of
		true ->
			Index = string:str(RawData,"Disc"),
			% io:format("Index -> ~p~n",[Index]),
			case Index >=1 of 
				true  ->
					% ListBeforeIndex =  string:substr(RawData, 1, Index -1),
					% io:format("string before Index -> ~p~n", [ListBeforeIndex]),
					LengthOfTailPart = string:len(RawData) - Index + 1,
					case (LengthOfTailPart - 110) >= 0 of
						true -> 
								NewList = string:substr(RawData, Index, 110),
								case string:str(NewList, "Tag") == 83 of 
									true  -> 
								        ListAfterIndex = string:substr(RawData, Index + 110, string:len(RawData) - Index + 1 - 110) -- "\r\n",
										% io:format(">= 110 string After Index -> ~p~n", [ListAfterIndex]),
										% io:format("the cut string -> ~p~n",[NewList]),
										parse_command(NewList),
										sub_command(ListAfterIndex);
									false ->
										RawDataWithoutFirstDisc = string:substr(RawData, Index + 4, LengthOfTailPart - 4),
										io:format("RawDataWithoutFirstDisc -> ~p~n", [RawDataWithoutFirstDisc]),
										sub_command(RawDataWithoutFirstDisc)
								end;

						false-> {ok, RawData}
					     	   % ListAfterIndex1 = string:substr(RawData, Index, string:len(RawData) - Index + 1) -- "\r\n",
							   % io:format("< 110 string After Index -> ~p~n", [ListAfterIndex1]),
							   % sub_command(ListBeforeIndex, ListAfterIndex1 ++ HeadPiece)
					end;
				false -> {ok, RawData}
			end;
		false-> {ok, RawData}
	end.
parse_command(CommandSub) ->
	Count = string:substr(CommandSub, 59, 5),
	Ant = string:substr(CommandSub, 70, 2),
	Tag = string:substr(CommandSub, 87, 24),
	LastReadTime = string:substr(CommandSub, 32, 19),
	io:format("Count -> ~p, Ant -> ~p, Tag -> ~p  Last Time ~p~n ",[Count, Ant, Tag, LastReadTime]),
	Now = calendar:local_time(),		
	StartTime = calendar:datetime_to_gregorian_seconds(Now),
	{ok, #tagInfo{epc = Tag, count = Count, ant = Ant, last_read_time = LastReadTime, start_time = StartTime}}.
	% {Count, Ant, Tag, LastReadTime}.


time_min(LeaseTime) ->
	io:format("LeaseTime -> ~p~n", [LeaseTime]),
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	io:format("CurrentTime -> ~p~n", [CurrentTime]),
	TimeMin = CurrentTime - LeaseTime,
	io:format("TimeMin -> ~p~n", [TimeMin]),
	TimeMin.
