-module(sc_store).
-export([init/0,insert/2,delete/1,lookup/1]).

-define(TABLE_ID,?MODULE).
-record(key_to_pid,{key,pid}).

init()->
	mnesia:start(),
	mnesia:create_table(key_to_pid,
						[{index,[pid]},
						 {attributes,record_info(fields,key_to_pid)}]),
	% ets:new(?TABLE_ID,[public,named_table]),
	ok.

insert(Key,Pid)->
	% ets:insert(?TABLE_ID,{Key,Pid}).
	mnesia:dirty_write(#key_to_pid{key = Key,pid = Pid}).

lookup(Key)->
	case mnesia:dirty_read(key_to_pid,Key) of
		[{key_to_pid,Key,Pid}] ->
			case is_pid_alive(Pid) of
				true -> {ok,Pid};		
				false -> {error,not_found}
			end;
		[]			-> {error,not_found}
	end.

is_pid_alive(Pid) when node(Pid) =:= node() ->
	is_process_alive(Pid);
is_pid_alive(Pid) ->
	lists:member(node(Pid),nodes()) andalso
	(rpc:call(node(Pid),erlang,is_process_alive,[Pid]) =:= true).

delete(Pid)->
	% ets:match_delete(?TABLE_ID,{'_',Pid}).
	case mnesia:dirty_index_read(key_to_pid,Pid,#key_to_pid.pid) of 
		[#key_to_pid{} = Record] ->
			mnesia:dirty_delete_object(Record);
		_ -> 
			ok
	end.

