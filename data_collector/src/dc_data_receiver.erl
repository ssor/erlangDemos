%gen_server template
-module(dc_data_receiver).
-behaviour(gen_server).
%%%====================================
%% callbacks
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).
-export([crash_me/1]).
%%%====================================
%%% API
-export([start_link/1, stop/0]).

-define(SERVER, ?MODULE).
-record(state,{port,lsock}).

%%%==========================================
%%% API
start_link(Port) ->
	% io:format("Data Collector New Port -> ~p~n",[Port]),
	gen_server:start_link(?MODULE, [Port], []).
	% gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).

% start_link() ->
	% gen_server:start_link(?MODULE, [1156], []).

stop() ->
	% io:format("stop pid ~p~n",[Pid]),
	% Only works when the process is registered!!!!!!!!!
	gen_server:cast(?MODULE, stop).

crash_me(Pid) ->
	gen_server:cast(Pid, crash).
% The return should be a ok		
% replace(Pid, Value) ->
% 	gen_server:cast(Pid, {replace, Value}).


%%%======================================================================================

init([Port]) ->
% If the gen_server is part of a supervision tree, no stop function is needed.
%  The gen_server will automatically be terminated by its supervisor. 
% If it is necessary to clean up before termination, 
% the shutdown strategy must be a timeout value and 
% the gen_server must be set to trap exit signals in the init function.
	% io:format("dc_data_receiver init Port ~p ~n", [Port]),
	process_flag(trap_exit, true),
	{ok, Socket} = gen_udp:open(Port, [binary]),
	{ok,#state{port = Port, lsock = Socket},0}.

handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State}.


% handle_cast(crash, State) ->
% 	io:format("I crash here~n"),
% 	a = b,
% 	{noreply, State};
handle_cast(stop, State) ->
	{stop,normal,State}.
% handle_cast(stop, #state{lsock = Socket} = State) ->
% 	io:format("close socket ~n",[]),
% 	gen_udp:close(Socket),
% 	{stop,normal,State}.

handle_info({udp, _Socket, _IP, _InPortNo, Packet}, State) ->
	% io:format("~p: ~p~n",[State#state.port,Packet]),
	dc_event:received_data(State#state.port, Packet),
	{noreply,State};

handle_info(timeout,State) ->
	{noreply,State}.

terminate(_Reason,#state{lsock = Socket} = State) ->
	Port = State#state.port,
	io:format("port ~p terminate here ~n",[Port]),
	gen_udp:close(Socket),
	ok.
% terminate(_Reason, _State) ->
% 	io:format("terminate here~n",[]),
% 	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

	