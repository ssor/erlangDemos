-module(icreg_store).

-export([init/0,
		 insert/2,
		 delete/1,
		 lookup/1,
		 to_list/0]).

-define(TABLE_ID, ?MODULE).

init() ->
	ets:new(?TABLE_ID, [public, named_table]),
	ok.

insert(Port, Pid) ->
	ets:insert(?TABLE_ID, {Port, Pid}).

lookup(Port) ->
	case ets:lookup(?TABLE_ID, Port) of
		[{Port, Pid}] -> {ok, Pid};
		[]			 -> {error, not_found}
	end.

delete(Port) ->
	ets:match_delete(?TABLE_ID, {Port, '_'}).

to_list() ->
	ets:tab2list(?TABLE_ID).