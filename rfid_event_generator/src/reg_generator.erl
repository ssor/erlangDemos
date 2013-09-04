%gen_server template
-module(reg_generator).
-behaviour(gen_server).

-export([send_data/2, start_link/1
		,get_lease_time/1, set_lease_time/2]).

-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).
-record(state,{upd_port, default_lease_time, raw_data = " ", tags_ets, tags_temp_ets}).
-record(tagInfo,{epc, ant, count, last_read_time, start_time}).
-define(DEFAULT_LEASE_TIME, 60 * 30).
-include("ms_transform.hrl").

%%%%======================================================================

start_link(Port) ->
	gen_server:start_link(?MODULE, [Port], []).

send_data(Pid, BinaryData) ->
	gen_server:call(Pid, {send_data, BinaryData}).

get_lease_time(Pid) ->
	LeaseTime = gen_server:call(Pid, get_lease_time),
	LeaseTime.
set_lease_time(Pid, LeaseTime) ->
	gen_server:call(Pid, {set_lease_time, LeaseTime}),
	ok.
%%%%======================================================================

init([UdpPort]) ->
	% io:format("Port ~p is initialized~n",[UdpPort]),
	process_flag(trap_exit, true),
	Ets = ets:new(ets, [{keypos, #tagInfo.epc}]),
	
	Config = idc:reg_config(),
	case lists:keyfind(default_lease_time, 1, Config) of
		false ->
			{ok,#state{
				upd_port = UdpPort, 
				tags_ets = Ets, 
				default_lease_time = ?DEFAULT_LEASE_TIME}, 
			1};
		{default_lease_time, LeaseTime} ->
			{ok,#state{
			upd_port = UdpPort, 
			tags_ets = Ets, 
			default_lease_time = LeaseTime}, 
			1}
	end.
	% EtsTemp = ets:new(ets_temp, [{keypos, #tagInfo.epc}]),
	% {ok,#state{
	% 		upd_port = UdpPort, 
	% 		tags_ets = Ets, 
	% 		default_lease_time = ?DEFAULT_LEASE_TIME}, 
	% 		1}.

handle_call({send_data, BinaryData}, _From, #state{raw_data = Source, default_lease_time = LeaseTime} = State) ->
	Data = binary_to_list(BinaryData),
	NewRawData = string:concat(Source, Data),
	{ok, LeftData} = sub_command(NewRawData, State),
	Reply = ok,
	{reply, Reply, State#state{raw_data = LeftData}, 1000 * LeaseTime};
handle_call({set_lease_time, LeaseTime}, _From, State) ->
	Reply = ok,
	{reply, Reply, State#state{default_lease_time = LeaseTime}, 1000 * LeaseTime};

handle_call(get_lease_time, _From, 
				#state{default_lease_time = LeaseTime} = State) ->
	Reply = LeaseTime,
	{reply,Reply,State, 1000 * LeaseTime};
handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State}.

handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(timeout, #state{tags_ets = TagEts, default_lease_time = LeaseTime} = State) ->
	TimeMin = time_min(LeaseTime),
	FuncMatch = ets:fun2ms(fun(#tagInfo{start_time = StartTime, epc = Epc}) when StartTime =< TimeMin -> Epc end),
	case ets:select(TagEts, FuncMatch) of 
		Tags ->
			delete_tag_for_time_elapse(TagEts, Tags)
		% [] ->
			% io:format("no tag deleted for Time Elapse!!~n")
	end,
	{noreply, State, 1000 * LeaseTime};

handle_info(_Request, State) ->
	{noreply, State}.


delete_tag_for_time_elapse(_TagEts, []) -> ok;
delete_tag_for_time_elapse(TagEts, [H|Tags]) ->
	% io:format("tag ~p is deleted for time Elapse~n", [H]),
	ets:match_delete(TagEts, #tagInfo{epc = H, _ = '_'}),
	delete_tag_for_time_elapse(TagEts, Tags).


terminate(_Reason, State) ->
	Port = State#state.upd_port,
	io:format("port ~p terminate here ~n",[Port]),
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

%%%%=======================================================================

% sub_command([], _) ->
	% {ok, [""]};
sub_command(RawData, #state{upd_port = _UdpPort} = State) ->
	case splite_command(RawData) of
		{nomatch, TailList} ->
			{ok, TailList};
			% io:format("no match Source ->~p~n", [TailList]);
		{match, CommandList, TailList} ->
			dispose_command(CommandList, State),
			{ok, TailList}
			% io:format("TailList -> ~p~n", [TailList])
	end.


dispose_command([], _) -> void;
dispose_command([H|T], #state{upd_port = UdpPort} = State) ->
	% io:format("Command -> ~p~n", [H]),
	{ok, Event, #tagInfo{epc = Tag, count = Count, ant = Ant} = _TagInfo} 
		= parse_new_command_text(H, State),
	reg_event:get_new_tag(UdpPort, {Event, Tag, Ant, Count}),
	dispose_command(T, State).


parse_new_command_text(CommandList, #state{tags_ets = TagEts} = _State) ->
	{ok, #tagInfo{epc = Tag, count = Count, ant = Ant, last_read_time = LastReadTime, start_time = StartTime} = TagInfo}
		= parse_command(CommandList),
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
							% update_taginfo(TagEts, NewTagInfo),
							ets:insert(TagEts, NewTagInfo),
							{ok, tag_ant_change, TagInfo};
						false ->
							% io:format("Wrong Read ~n"),
							NewTagInfo2 = #tagInfo{epc = Tag, last_read_time = LastReadTime, count = Count, start_time = StartTime},
							% update_taginfo(TagEts, NewTagInfo2),
							ets:insert(TagEts, NewTagInfo2),
							{ok, tag_missed_read, TagInfo}
					end;
				true  ->
					case LastReadTime == LastReadTime4 of
						true  -> 
							% io:format("Nothing Changed !~n"),
							{ok, tag_nothing_changed, TagInfo};
						false ->
							 % io:format("Time updated~n"),
							 % update_taginfo(TagEts, NewTagInfo),
							 ets:insert(TagEts, NewTagInfo),
							{ok, tag_time_update, TagInfo}
					end
			end; 
		[] ->

			% insert_taginfo(TagEts, NewTagInfo),
			ets:insert(TagEts, NewTagInfo),
			{ok, tag_new, TagInfo}
	end.

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


parse_command(CommandSub) ->
	% io:format("~p~n", [CommandSub]),
	Count = string:substr(CommandSub, 59, 5),
	Ant = string:substr(CommandSub, 70, 2),
	Tag = string:substr(CommandSub, 87, 24),
	LastReadTime = string:substr(CommandSub, 32, 19),
	% io:format("Count -> ~p, Ant -> ~p, Tag -> ~p  Last Time ~p~n ",[Count, Ant, Tag, LastReadTime]),
	Now = calendar:local_time(),		
	StartTime = calendar:datetime_to_gregorian_seconds(Now),
	{ok, #tagInfo{epc = Tag, count = Count, ant = Ant, last_read_time = LastReadTime, start_time = StartTime}}.



time_min(LeaseTime) ->
	% io:format("LeaseTime -> ~p~n", [LeaseTime]),
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	% io:format("CurrentTime -> ~p~n", [CurrentTime]),
	TimeMin = CurrentTime - LeaseTime,
	% io:format("TimeMin -> ~p~n", [TimeMin]),
	TimeMin.

