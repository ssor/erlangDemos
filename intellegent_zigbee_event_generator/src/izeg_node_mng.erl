%gen_server template
-module(izeg_node_mng).
-behaviour(gen_server).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).

-export([add_node/1, delete_node/1, start_link/0, send_data/1]).

-record(state,{}).

%%%%=========================================================================================================
add_node({Port, Address}) ->
	% io:format("izeg_port_mng add_node -> ~n"),
	case izeg_store:lookup(Address) of
		{ok, Address, Pid, _Index} -> 
			% io:format("izeg_port_mng Pid for Port ~p already exists ~n",[Address]),
			{ok, Pid};

		{error, not_found} ->
		 	{ok, Pid} = izeg_generator_sup:start_child({Port, Address}),
			% io:format("izeg_port_mng Port ~p  created ~n",[Address]),
			izeg_store:insert(Address, Pid),
			{ok, Pid}
			% io:format("Created Child Pid is ~p~n",[Pid])
	end.	

delete_node(Address) ->
	case izeg_store:lookup(Address) of
		{ok, Address, Pid, _Index} ->
			io:format("delete_node for Port ~p  ~n",[Address]),
			izeg_generator_sup:stop_child(Pid),
			izeg_store:delete(Address);
			% io:format("deleted Child Pid is ~p~n",[Pid]);
		{error, not_found} -> ok
	end.	

send_data({Port, {Address, NodeID, Huminity, Temp}}) ->
	{ok, Pid} = add_node({Port, Address}),
	izeg_generator:send_data(Pid, {Address, NodeID, Huminity, Temp}).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%%=========================================================================================================

init([]) ->
	{ok,#state{}}.

handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State}.

handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(_Info,State) ->
	{noreply,State}.

terminate(_Reason,_State) ->
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

	