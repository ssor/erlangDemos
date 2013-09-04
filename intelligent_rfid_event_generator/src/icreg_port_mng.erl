%gen_server template
-module(icreg_port_mng).
-behaviour(gen_server).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).

-export([add_port/1, delete_port/1, start_link/0, handle_rfid_event/2
		, get_lease_time/1, get_check_time/1, set_lease_time/2
		, set_check_time/2]).

-record(state,{}).

%%%%=========================================================================================================
add_port(UdpPort) ->
	case icreg_store:lookup(UdpPort) of
		{ok, _Pid} -> 
			io:format("icreg_port_mng Pid for Port ~p already exists ~n",[UdpPort]);

		{error, not_found} ->
		 	{ok, Pid} = icreg_generator_sup:start_child(UdpPort),
			io:format("icreg_port_mng Port ~p  created ~n",[UdpPort]),
			icreg_store:insert(UdpPort, Pid)
			% io:format("Created Child Pid is ~p~n",[Pid])
	end.	

delete_port(UdpPort) ->
	case icreg_store:lookup(UdpPort) of
		{ok, Pid} ->
			io:format("icreg_port_mng delete_port for Port ~p  ~n",[UdpPort]),
			icreg_generator_sup:stop_child(Pid),
			icreg_store:delete(UdpPort),
			% io:format("deleted Child Pid is ~p~n",[Pid]);
		{error, not_found} -> ok
	end.	

handle_rfid_event(UdpPort, {Event, Port, {Tag, Ant, Count}}) ->
	case icreg_store:lookup(UdpPort) of
		{ok, Pid} -> icreg_generator:handle_rfid_event(Pid, {Event, Port, {Tag, Ant, Count}});
		{error, not_found} -> ok
	end.		

get_lease_time(UdpPort) ->
	case icreg_store:lookup(UdpPort) of
		{ok, Pid} ->
			icreg_generator:get_lease_time(Pid);
		{error, not_found} -> unknown
	end.	
get_check_time(UdpPort) ->
	case icreg_store:lookup(UdpPort) of
		{ok, Pid} ->
			icreg_generator:get_check_time(Pid);
		{error, not_found} -> unknown
	end.	
set_lease_time(UdpPort, Seconds) ->
	case Seconds > 0 of 
		true  -> 
			case icreg_store:lookup(UdpPort) of
				{ok, Pid} ->
					icreg_generator:set_lease_time(Pid, Seconds);
				{error, not_found} -> void
			end;
		false ->
			void
	end.		
set_check_time(UdpPort, Seconds) ->
	case Seconds > 0 of 
		true  -> 
			case icreg_store:lookup(UdpPort) of
				{ok, Pid} ->
					icreg_generator:set_check_time(Pid, Seconds);
				{error, not_found} -> void
			end;
		false ->
			void
	end.

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

	