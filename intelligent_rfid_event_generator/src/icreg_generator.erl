%gen_server template
-module(icreg_generator).
-behaviour(gen_server).

-export([handle_rfid_event/2, start_link/1
		,get_lease_time/1
		,set_lease_time/2
		,get_check_time/1
		,set_check_time/2]).

-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).
-record(state,{upd_port, tags_ets, tags_temp_ets, 
				last_check_time, is_first_check, 
				default_lease_time, default_check_time}).
-record(tagInfo,{epc, ant, count, last_read_time, start_time}).
-define(DEFAULT_LEASE_TIME, 5).
-define(DEFAULT_CHECK_TIME, 15).
-include("ms_transform.hrl").

%%%%======================================================================

start_link(Port) ->
	gen_server:start_link(?MODULE, [Port], []).

handle_rfid_event(Pid, {Event, Port, {Tag, Ant, Count}}) ->
	gen_server:call(Pid, {new_event, {Event, Port, {Tag, Ant, Count}}}).

get_lease_time(Pid) ->
	gen_server:call(Pid, get_lease_time).
set_lease_time(Pid, LeaseTime) ->
	gen_server:call(Pid, {set_lease_time, LeaseTime}),
	ok.
get_check_time(Pid) ->
	gen_server:call(Pid, get_check_time).
set_check_time(Pid, CheckTime) ->
	gen_server:call(Pid, {set_check_time, CheckTime}),
	ok.
%%%%======================================================================

init([UdpPort]) ->
	io:format("Port ~p is initialized~n",[UdpPort]),
	process_flag(trap_exit, true),
	Ets = ets:new(ets, [{keypos, #tagInfo.epc}]),
	EtsTemp = ets:new(ets_temp, [{keypos, #tagInfo.epc}]),
	Now = calendar:local_time(),		
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),

	Config = idc:icreg_config(),
	DefaultLeaseTime = case lists:keyfind(default_lease_time, 1, Config) of
		false ->
			?DEFAULT_LEASE_TIME;
		{default_lease_time, LeaseTime} ->
			LeaseTime
	end,
	DefaultCheckTime = case lists:keyfind(default_check_time, 1, Config) of
		false ->
			?DEFAULT_CHECK_TIME;
		{default_check_time, CheckTime} ->
			CheckTime
	end,
	{ok,#state{upd_port = UdpPort, 
				tags_ets = Ets, 
				tags_temp_ets = EtsTemp, 
				last_check_time = CurrentTime,
				default_lease_time = DefaultLeaseTime,
				default_check_time = DefaultCheckTime, 
				is_first_check = true}, 1}.

handle_call({new_event, {Event, _Port, {Tag, Ant, Count}}}, _From,
			 #state{default_lease_time = _LeaseTime} = State) ->
	case Event of
		tag_nothing_changed -> tag_event_handler({Tag, Ant, Count}, State);
		tag_new -> tag_event_handler({Tag, Ant, Count}, State);
		tag_time_update -> tag_event_handler({Tag, Ant, Count}, State);
		tag_missed_read -> tag_event_handler({Tag, Ant, Count}, State);
		tag_ant_change ->  tag_event_handler({Tag, Ant, Count}, State)
	end,
	Reply = ok,
	{reply, Reply, State, 1};
handle_call(get_lease_time, _From, #state{default_lease_time = LeaseTime} = State) ->
	Reply = LeaseTime,
	{reply, Reply, State, 1000 * LeaseTime};
handle_call(get_check_time, _From, 
				#state{default_lease_time = LeaseTime, default_check_time = CheckTime} = State) ->
	Reply = CheckTime,
	{reply, Reply, State, 1000 * LeaseTime};
handle_call({set_lease_time, NewLeaseTime}, _From, State) ->
	Reply = ok,
	{reply, Reply, 
		State#state{default_lease_time = NewLeaseTime}, 
		1000 * NewLeaseTime};
handle_call({set_check_time, NewCheckTime}, _From, #state{default_lease_time = LeaseTime} = State) ->
	Reply = ok,
	{reply, Reply,
		State#state{default_check_time = NewCheckTime}, 
		1000 * LeaseTime};
handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State}.


handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(timeout, 
		#state{tags_ets = TagEts, 
		upd_port = UdpPort, 
		last_check_time = LastCheckTime, 
		is_first_check = IsFirstCheck,
		default_lease_time = LeaseTime,
		default_check_time = CheckTime} = State) ->

	
	TimeMin = time_min(LeaseTime),
	% io:format("TimeMin -> ~p~n", [TimeMin]),
	% FuncMatch2 = ets:fun2ms(fun(#tagInfo{last_read_time = LastReadTime2, epc = Epc2}) when LastReadTime2 =< TimeMin -> {Epc2,LastReadTime2} end),
	% Tags2 = ets:select(TagEts, FuncMatch2),
	% FunPrint = fun({Epc3, LastReadTime3}) -> 
	% 				io:format("Epc -> ~p, LastReadTime -> ~p~n", [Epc3, LastReadTime3]) end,
	% lists:foreach(FunPrint, Tags2),
	FuncMatch = ets:fun2ms(fun(#tagInfo{last_read_time = LastReadTime, epc = Epc}) when LastReadTime =< TimeMin -> Epc end),
	case ets:select(TagEts, FuncMatch) of 
		Tags ->
			delete_tag_for_time_elapse(TagEts, Tags),
			icreg_event:tag_disapear(UdpPort, Tags)
		% [] ->
			% io:format("no tag deleted for Time Elapse!!~n")
	end,
	% io:format("IsFirstCheck -> ~p~n", [IsFirstCheck]),
	case IsFirstCheck of
		true  -> {noreply, State#state{is_first_check = false}, 1000 * LeaseTime};
		false -> 
			TimeMin2 = time_min(CheckTime),
			% io:format("LastCheckTime -> ~p, TimeMin2 -> ~p~n", [LastCheckTime, TimeMin2]),
			case LastCheckTime =< TimeMin2 of
				true  -> 
					FuncMatchAll = ets:fun2ms(fun(#tagInfo{ epc = Epc, ant = Ant, count = Count}) -> {Epc, Ant, Count} end),
					AllTags = ets:select(TagEts, FuncMatchAll),
					% io:format("LastCheckTime =< TimeMin2 Tags-> ~p~n", [AllTags]),
					icreg_event:tag_existing(UdpPort, AllTags),
					Now = calendar:local_time(),		
					CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
					{noreply, State#state{last_check_time = CurrentTime, is_first_check = false}, 1000 * LeaseTime};
				false -> 
					{noreply, State#state{is_first_check = false}, 1000 * LeaseTime}
			end
	end;

	% io:format("timeout...~n"),

handle_info(_Request, State) ->
	{noreply, State}.

terminate(_Reason, State) ->
	Port = State#state.upd_port,
	io:format("port ~p terminate here ~n",[Port]),
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

%%%%=======================================================================

tag_event_handler({Tag, Ant, Count}, #state{upd_port = UdpPort, tags_ets = TagEts, tags_temp_ets = EtsTemp} = State) ->
	% io:format("tag_event_handler   Tag -> ~p, Ant -> ~p~n", [Tag, Ant]),
	Now = calendar:local_time(),		
	CurrentReadTime = calendar:datetime_to_gregorian_seconds(Now),
	NewTagInfo = #tagInfo{epc = Tag, last_read_time = CurrentReadTime, count = Count, ant = Ant},
	NewTagInfoTemp = #tagInfo{epc = Tag, start_time = CurrentReadTime, count = Count, ant = Ant},
	FuncMatch = ets:fun2ms(fun(#tagInfo{ant = Ant1, epc = Epc1}) when (Ant1 == Ant) and (Tag == Epc1) -> Epc1 end),
	case ets:select(TagEts, FuncMatch) of 
	% case ets:lookup(TagEts, Tag)
		[_H|_T] ->
		% [#tagInfo{ant = Ant2}]
			% io:format("tag_event_handler   TagEts Not Null ~n"),
			ets:insert(TagEts, NewTagInfo);
			% case Ant2 == Ant of 
			% 	true  -> void;
			% 	false -> icreg_event:tag_ant_change(UdpPort, {Tag, Ant, Count})
			% end;
		[] ->
			% check if ant 
			% io:format("tag_event_handler   TagEts  Null ~n"),
			case ets:lookup(EtsTemp, Tag) of
				[#tagInfo{start_time = StartTime, ant = Ant2}] ->
					% io:format("tag_event_handler   EtsTemp Not Null ~n"),
					% io:format("tag_event_handler   Ant2 == Ant -> ~p ~n", [Ant2]),
					case Ant2 == Ant of
						true  ->
							% io:format("tag_event_handler   Ant2 == Ant -> ~p ~n", [Ant2]),
							TimeMin = time_min(?DEFAULT_LEASE_TIME),
							case TimeMin =< StartTime of
								true  ->
									void;
								false ->
									% io:format("tag_event_handler   match_delete ~n"),
									ets:match_delete(EtsTemp, #tagInfo{epc = Tag, _ = '_'}),
									ets:insert(TagEts, NewTagInfo),
									icreg_event:tag_new(UdpPort, {Tag, Ant, Count})
									% case ets:lookup(TagEts, Tag) of 
									% 	[#tagInfo{ant = Ant3}] ->
									% 		case Ant == Ant3 of 
									% 			false ->
									% 				ets:insert(TagEts, NewTagInfo),
									% 				icreg_event:tag_ant_change(UdpPort, {Tag, Ant, Count})
									% 		end;
									% 	[] ->
									% 		ets:insert(TagEts, NewTagInfo),
									% 		icreg_event:tag_new(UdpPort, {Tag, Ant, Count})
									% end
							end;							
						false ->
						% The Ant changed, Now we should reset the tag's start_time
							% io:format("tag_event_handler   reset the tag's start_time ~n"),
							ets:insert(EtsTemp, NewTagInfoTemp)
					end;

				[] ->
					% io:format("tag_event_handler   EtsTemp Null ~n"),
					ets:insert(EtsTemp, NewTagInfoTemp)
			end
	end,
	{ok, State}.


delete_tag_for_time_elapse(_TagEts, []) -> ok;
delete_tag_for_time_elapse(TagEts, [H|Tags]) ->
	% io:format("tag ~p is deleted for time Elapse~n", [H]),
	ets:match_delete(TagEts, #tagInfo{epc = H, _ = '_'}),

	delete_tag_for_time_elapse(TagEts, Tags).





time_min(LeaseTime) ->
	% io:format("LeaseTime -> ~p~n", [LeaseTime]),
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	% io:format("CurrentTime -> ~p~n", [CurrentTime]),
	TimeMin = CurrentTime - LeaseTime,
	% io:format("TimeMin -> ~p~n", [TimeMin]),
	TimeMin.

