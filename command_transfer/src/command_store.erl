-module(command_store).
-behaviour(gen_server).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).

-export([insert_command_list/1,
		 insert_command/2,
		 get_command_list/2,
		 % insert/2,
		 % delete/1,
		 % lookup/1,
		 to_list/0,
		 start_link/0]).

-define(TABLE_ID, ?MODULE).
-record(command, {flag, binary_content, name, arg, time_stamp}).
-include("ms_transform.hrl").
-record(state,{command_ets}).
% -define(DEFAULT_LEASE_TIME, 10).
-define(DEFAULT_LEASE_TIME, 60 * 30).


insert_command(Flag, Content) ->
	Now = calendar:local_time(),		
	StartTime = calendar:datetime_to_gregorian_seconds(Now),	
	ets:insert(?TABLE_ID, #command{flag = Flag, binary_content = Content, time_stamp = StartTime}),
	ok.


insert_command_list(CommandList) ->
	Now = calendar:local_time(),		
	StartTime = calendar:datetime_to_gregorian_seconds(Now),
	FuncInsert = fun(Command) ->
					ets:insert(?TABLE_ID, Command#command{time_stamp = StartTime})
					% ets:insert(?TABLE_ID, Command#command{time_stamp = integer_to_list(StartTime, 10)}),
					% io:format("Add Command -> ~p~n", [Command])
				 end,
	lists:map(FuncInsert, CommandList),
	ok.
get_command_list(undefined, _) ->
	{ok, format_response_command([], [])};
get_command_list(Flag, TimeStampPara) ->
	FuncMatch = ets:fun2ms(fun(#command{time_stamp = TimeStamp, name = Name, flag = CommandFlag, binary_content = Content}) 
								when (TimeStampPara =< TimeStamp) and (CommandFlag == Flag) 
									-> Content
						   end),
	Commands = ets:select(?TABLE_ID, FuncMatch),
	{ok, format_response_command(Commands, [])}.


start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
	% io:format("command_store init -> ~n"),
	Ets = ets:new(?TABLE_ID, [public, named_table, {keypos, #command.flag}, bag]),
	{ok, #state{command_ets = Ets}, ?DEFAULT_LEASE_TIME}.

handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State}.

handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(timeout, State) ->
	TimeMin = time_min(?DEFAULT_LEASE_TIME),
	FuncMatch = ets:fun2ms(fun(#command{time_stamp = TimeStamp}) 
							 % ITimeStamp = ,
							-> TimeStamp < TimeMin
						   end),
	NumDeleted = ets:select_delete(?TABLE_ID, FuncMatch),
	io:format("Number ~p Commands have been deleted!!~n", [NumDeleted]),
	% Objects = to_list(),
	% io:format("TimeMin -> ~p~n", [TimeMin]),
	% io:format("Ets -> ~p~n", [Objects]),
	% delete_tag_for_time_elapse(TagEts, Tags),
	{noreply, State, 1000 * ?DEFAULT_LEASE_TIME};

handle_info(_Info,State) ->
	{noreply,State}.

terminate(_Reason,_State) ->
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

	
% insert(Port, Pid) ->
% 	ets:insert(?TABLE_ID, {Port, Pid}).

% lookup(Port) ->
% 	case ets:lookup(?TABLE_ID, Port) of
% 		[{Port, Pid}] -> {ok, Pid};
% 		[]			 -> {error, not_found} 
% 	end.

% delete(Port) ->
% 	ets:match_delete(?TABLE_ID, {Port, '_'}).

to_list() ->
	ets:tab2list(?TABLE_ID).


time_min(LeaseTime) ->
	% io:format("LeaseTime -> ~p~n", [LeaseTime]),
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	% io:format("CurrentTime -> ~p~n", [CurrentTime]),
	TimeMin = CurrentTime - LeaseTime,
	% io:format("TimeMin -> ~p~n", [TimeMin]),
	TimeMin.


format_response_command([], String) ->
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	"[" ++ integer_to_list(CurrentTime) ++ "]" ++ String;
format_response_command([H|T], String) ->
	% {Name, Args, TimeStamp} = H,
	% FormatedCommand = "[" ++ Flag ++ "," ++ Name ++ "," ++ Args ++ "," ++ integer_to_list(TimeStamp) ++ "]",
	% io:format("FormatedCommand -> ~p~n", [FormatedCommand]),
	format_response_command(T, "[" ++ binary_to_list(H) ++ "]" ++ String).
