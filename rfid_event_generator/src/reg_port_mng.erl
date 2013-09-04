%gen_server template
-module(reg_port_mng).
-behaviour(gen_server).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).

-export([add_port/1, delete_port/1, start_link/0, send_data/2,
		 get_lease_time/1, set_lease_time/2]).

-record(state,{}).

%%%%=========================================================================================================
add_port(UdpPort) ->
	case reg_store:lookup(UdpPort) of
		{ok, _Pid} -> 
			io:format("Pid for Port ~p already exists ~n",[UdpPort]);

		{error, not_found} ->
		 	{ok, Pid} = reg_generator_sup:start_child(UdpPort),
			io:format(" Port ~p created ~n",[UdpPort]),
			reg_store:insert(UdpPort, Pid)
			% io:format("Created Child Pid is ~p~n",[Pid])
	end.	

delete_port(UdpPort) ->
	case reg_store:lookup(UdpPort) of
		{ok, Pid} ->
			io:format("delete_port for Port ~p  ~n",[UdpPort]),
			reg_generator_sup:stop_child(Pid),
			reg_store:delete(UdpPort);
			% io:format("deleted Child Pid is ~p~n",[Pid]);
		{error, not_found} -> ok
	end.	

send_data(UdpPort, BinaryData) ->
	case reg_store:lookup(UdpPort) of
		{ok, Pid} -> reg_generator:send_data(Pid, BinaryData);
		{error, not_found} -> ok
	end.		
get_lease_time(UdpPort) ->
	case reg_store:lookup(UdpPort) of
		{ok, Pid} -> reg_generator:get_lease_time(Pid);
		{error, not_found} -> unknown
	end.
set_lease_time(UdpPort, Seconds) ->
	case Seconds >0 of
		true  ->
			case reg_store:lookup(UdpPort) of
				{ok, Pid} -> reg_generator:set_lease_time(Pid, Seconds);
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

	