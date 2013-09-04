%gen_server template
-module(zeg_generator).
-behaviour(gen_server).

-export([send_data/2, start_link/1]).

-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).
-record(state,{upd_port, raw_data = " ", last_huminity = infinity, last_temperature = infinity, address, node_id = "000"}).
-record(zigbeeInfo,{address, node_id, huminity, temperature}).
-define(DEFAULT_LEASE_TIME, 10).
%%%%======================================================================

start_link(Port) ->
	gen_server:start_link(?MODULE, [Port], []).

send_data(Pid, BinaryData) ->
	gen_server:call(Pid, {send_data, BinaryData}).


%%%%======================================================================

init([UdpPort]) ->
	% io:format("Port ~p is initialized~n",[UdpPort]),
	process_flag(trap_exit, true),
	{ok,#state{upd_port = UdpPort}, 1}.

handle_call({send_data, BinaryData}, _From, #state{raw_data = Source} = State) ->
	Data = binary_to_list(BinaryData),
	NewRawData = string:concat(Source, Data),
	{ok, LeftData, StateReturn} = sub_command(NewRawData, State),
	#state{last_huminity = Huminity, last_temperature = Temp, node_id = NodeID, address = Address} = StateReturn,
	Reply = ok,
	% io:format("send_data -> Huminity = ~p  Temp = ~p ~n", [Huminity, Temp]),
	% io:format("send_data -> raw_data = ~p  ~n", [Source]),
	{reply, Reply, 
		State#state{raw_data = LeftData, last_huminity = Huminity, last_temperature = Temp, node_id = NodeID, address = Address}
		, 1000 * ?DEFAULT_LEASE_TIME};
handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State, 1000 * ?DEFAULT_LEASE_TIME}.

handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(timeout, #state{upd_port = UdpPort, last_temperature = LastTemperature, last_huminity = LastHuminity, node_id = NodeID, address = Address} = State) ->
	% io:format("zeg_generator -> timeout node_id = ~p LastHuminity = ~p  LastTemperature = ~p~n", [NodeID, LastHuminity, LastTemperature]),
	% io:format("zeg_generator -> timeout raw_data = ~p  ~n", [Source]),
	case 
		(LastHuminity /= infinity) and (LastTemperature /= infinity) of
		true  -> zeg_event:get_new_info(UdpPort, {Address, NodeID, LastHuminity, LastTemperature});
		false -> void
	end,
	% {noreply, State};
	{noreply, State, 1000 * ?DEFAULT_LEASE_TIME};
handle_info(_Request, State) ->
	{noreply, State}.


terminate(_Reason, State) ->
	Port = State#state.upd_port,
	io:format("port ~p terminate here ~n",[Port]),
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

%%%%=======================================================================
sub_command([], State) ->
	{ok, [""], State};
sub_command(RawData, State) ->
	case splite_command(RawData) of
		{nomatch, TailList} ->
			{ok, TailList, State};
			% io:format("no match Source ->~p~n", [TailList]);
		{match, CommandList, TailList} ->
			{ok, StateReturn} = dispose_command(CommandList, State),
			{ok, TailList, StateReturn}
			% io:format("TailList -> ~p~n", [TailList])
	end.

dispose_command([], State) -> {ok, State};
dispose_command([H|T], #state{upd_port = UdpPort} = State) ->
	% io:format("Command -> ~p~n", [H]),
	% {ok, EventOfTemp, EventOfHuminity, #zigbeeInfo{address = Address, node_id = NodeID, huminity = Huminity, temperature = Temp} = _ZigbeeInfo} 
	{ok, #zigbeeInfo{address = Address, node_id = NodeID, huminity = Huminity, temperature = Temp} = _ZigbeeInfo} 
		= parse_new_command_text(H, State),
	zeg_event:get_new_info(UdpPort, {Address, NodeID, Huminity, Temp}),
	% zeg_event:get_new_info(UdpPort, {EventOfTemp, EventOfHuminity, Address, NodeID, Huminity, Temp}),
	dispose_command(T, State#state{last_huminity = Huminity, last_temperature = Temp, node_id = NodeID, address = Address}).


parse_new_command_text(CommandList, _State) ->
% parse_new_command_text(CommandList, #state{last_temperature = LastTemperature, last_huminity = LastHuminity} = _State) ->
	{ok, ZigbeeInfo}
	% {ok, #zigbeeInfo{address = _Address, node_id = _NodeID, huminity = Huminity, temperature = Temp} = ZigbeeInfo}
		= parse_command(CommandList),
	% io:format("LastTemperature -> ~p  Temp -> ~p~n", [LastTemperature, Temp]),
	% EventOfTemp = get_event(temperature, LastTemperature, Temp),
	% EventOfHuminity = get_event(huminity, LastHuminity, Huminity),
	% io:format("EventOfTemp -> ~p, EventOfHuminity -> ~p~n ", [EventOfTemp, EventOfHuminity]),
 	% {ok, EventOfTemp, EventOfHuminity, ZigbeeInfo}.
 	{ok, ZigbeeInfo}.

% get_event(temperature, LastTemperature, Temp) ->
% 	if 
% 		LastTemperature == infinity ->
% 			temperature_nochange;
% 		LastTemperature > Temp ->
% 			temperature_down;
% 		LastTemperature == Temp ->
% 			temperature_nochange;
% 		LastTemperature < Temp ->
% 			temperature_up
% 	end;
% get_event(huminity, LastHuminity, Huminity) ->
% 	if 
% 		LastHuminity == infinity ->
% 			huminity_nochange;
% 		LastHuminity > Huminity ->
% 			huminity_down;
% 		LastHuminity == Huminity ->
% 			huminity_nochange;
% 		LastHuminity < Huminity ->
% 			huminity_up
% 	end.

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

	
parse_command(CommandSub) ->
	Address = string:substr(CommandSub, 5, 16),
	NodeID = string:substr(CommandSub, 21, 4),
	Huminity = string:substr(CommandSub, 25, 4),
	Temp = string:substr(CommandSub, 29, 4),
	% io:format("Address -> ~p, NodeID -> ~p, Huminity -> ~p  Temp -> ~p~n",[Address, NodeID, Huminity, Temp]),
	{ok, #zigbeeInfo{address = Address, node_id = NodeID, huminity = list_to_integer(Huminity, 16), temperature = list_to_integer(Temp, 16)}}.

% time_left(_StartTime, infinity) ->
% 	infinity;
% time_left(StartTime, LeaseTime) ->
% 	Now = calendar:local_time(),
% 	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
% 	TimeElapsed = CurrentTime - StartTime,
% 	case LeaseTime - TimeElapsed of 
% 		Time when Time =< 0 -> 0;
% 		Time 				-> Time * 1000
% 	end.
