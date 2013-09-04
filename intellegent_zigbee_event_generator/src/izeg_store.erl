-module(izeg_store).

-export([init/0,
		 insert/2,
		 delete/1,
		 lookup/1,
		 lookup_by_index/1,
		 to_list/0]).

-define(TABLE_ID, ?MODULE).
-record(zigbeeInfo,{address, pid, index}).

init() ->
	% ets:new(?TABLE_ID, [public, named_table]),
	ets:new(?TABLE_ID, [public, named_table, {keypos, #zigbeeInfo.address}]),
	ok.

insert(Address, Pid) ->
	List = ets:tab2list(?TABLE_ID),
	Index = case get_index_max_item(List, undefined) of
		undefined -> 1;
		#zigbeeInfo{index = MaxIndex} -> MaxIndex + 1
	end,
	ets:insert(?TABLE_ID, #zigbeeInfo{address = Address, pid = Pid, index =Index}).

lookup(Address) ->
	case ets:lookup(?TABLE_ID, Address) of
		[#zigbeeInfo{address = Address, pid = Pid, index =Index}] -> {ok, Address, Pid, Index};
		[]			 -> {error, not_found}
	end.
lookup_by_index(Index_in) ->
	List = ets:tab2list(?TABLE_ID),
	case get_item_by_index(List, Index_in) of
		undefined ->
			{error, not_found};

		#zigbeeInfo{address = Address, pid = Pid, index =Index} ->
			{ok, Address, Pid, Index}
	end.


delete(Address) ->
	ets:match_delete(?TABLE_ID, #zigbeeInfo{address = Address, _ = '_'}).

to_list() ->
	ets:tab2list(?TABLE_ID).

get_index_max_item([], In) ->
	In;
get_index_max_item([H|T], undefined) ->
	get_index_max_item(T, H);
get_index_max_item([H|T], In) ->
	{zigbeeInfo, _, _, Index} = H,
	{zigbeeInfo, _, _, Index_in} = In,
	if 
		Index > Index_in ->
			get_index_max_item(T, H);
		Index =< Index_in ->
			get_index_max_item(T, In)
	end.

get_item_by_index([], _Index_in) ->
	undefined;
get_item_by_index([H|T], Index_in) ->
	{zigbeeInfo, _, _, Index} = H,
	if 
		Index == Index_in ->
			H;
		true ->
			get_item_by_index(T, Index_in)
	end.
