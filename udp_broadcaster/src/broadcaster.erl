%gen_server template
-module(broadcaster).
-behaviour(gen_server).

-export([start_link/0, get_broadcast_content/0, set_broadcast_interval/1, get_broadcast_interval/0,
			refresh_broadcast_content/0]).

-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).
-record(state,{info = "", ip = {255,255,255,255}, lease_time = 0, broadcast_port}).
-define(DEFAULT_LEASE_TIME, 3).
-define(DEFAULT_BROADCAST_PORT, 12306).

%%%%======================================================================

start_link() ->
	gen_server:start_link({local, ?MODULE},?MODULE, [], []).

get_broadcast_content() ->
	ReplyBinary = gen_server:call(?MODULE, get_broadcast_content),
	{ok, binary_to_list(ReplyBinary)}.
refresh_broadcast_content() ->
	gen_server:call(?MODULE, refresh_broadcast_content).

set_broadcast_interval(Interval) ->
	gen_server:call(?MODULE, {set_broadcast_interval, Interval}).

get_broadcast_interval() ->
	gen_server:call(?MODULE, get_broadcast_interval).
% get_lease_time(Pid) ->
% 	gen_server:call(Pid, get_lease_time).
% set_lease_time(Pid, LeaseTime) ->
% 	gen_server:call(Pid, {set_lease_time, LeaseTime}),
% 	ok.
%%%%======================================================================

init([]) ->
	process_flag(trap_exit, true),
	Content = case file:read_file("../../data.txt") of 
		{error, enoent} ->
			io:format("data file does not exist~n"),
			"";
		{ok, Data} ->
			Data
	end,
	Config = idc:broadcast_config(),

	BroadAddr = case lists:keyfind(broadaddr, 1, Config) of
					false -> 
					    {ok, HostName} = inet:gethostname(),
					    NewAddress = case inet:getaddr(HostName, inet) of
					        {ok, {IP1,IP2,IP3,_}} -> 
					                {IP1, IP2, IP3, 255};
					        {error, _} ->
					            io:format("error occored when get IP Address~n"),
					            {255,255,255,255}
					    end,
					    NewAddress;
					
					{broadaddr, IP} -> IP
						
	end,

	{ok,#state{ip = BroadAddr, info = Content,
		 lease_time = ?DEFAULT_LEASE_TIME,
		  broadcast_port = ?DEFAULT_BROADCAST_PORT}, 1}.


handle_call(get_broadcast_content, _From, #state{info = InfoToSend, lease_time = Interval} = State) ->
	Reply = InfoToSend,
	{reply, Reply,
		State, 
		1000 * Interval};
handle_call({set_broadcast_interval, Interval}, _From, State) ->
	{reply, ok, State#state{lease_time = Interval }, Interval * 1000};
handle_call(get_broadcast_interval, _From, #state{lease_time = Interval} = State) ->
	{reply, Interval, State, Interval * 1000};
handle_call(refresh_broadcast_content, _From, #state{lease_time = Interval} = State) ->
	Content = case file:read_file("../data.txt") of 
		{error, enoent} ->
			io:format("data file does not exist~n"),
			"";
		{ok, Data} ->
			Data
	end,
	{reply, ok, State#state{info = Content}, Interval * 1000};
	
handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State}.

handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(timeout, 
		#state{info = InfoToSend, ip = NewAddress, lease_time = Interval, broadcast_port = BroadcastPort} = State) ->
	% io:format("timeout -> ~p Interval -> ~p~n ", [binary_to_list(InfoToSend), Interval]),
	% io:format("Socket -> ~p  Address -> ~p ~n", [Socket, NewAddress]),
    Socket = case gen_udp:open(BroadcastPort, [{broadcast, true}]) of
	    {ok, S} -> S;
	    {error, _Reason} ->
	    	io:format("Open Udp error~n"),
	    	undefined
	 end,
	% case gen_udp:send(Socket, NewAddress, 12307, InfoToSend) of 
	case gen_udp:send(Socket, NewAddress, BroadcastPort, InfoToSend) of 
		ok -> void;
		{error, Reason} ->
			io:format("send error!Reason -> ~p~n", [Reason])
	end,
    gen_udp:close(Socket),
	{noreply, State, Interval * 1000};

handle_info(_Request, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	% io:format("broadcaster -> terminate~n"),
    % gen_udp:close(Socket),
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

%%%%=======================================================================
