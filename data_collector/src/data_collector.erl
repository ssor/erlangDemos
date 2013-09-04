% edoc:files(["data_collector.erl"],[{dir, "../doc/data_collector"}]).

%% @doc This application is used to collect all data from available sources
%%
%% Now,UDP protocol is supported,and others will be added
%%
%% Each data is seperated by Port,and subscriber shouled get
%% data from event through the ports
-module(data_collector).

-export([add_port/1, delete_port/1, config/0, 
		list_current_ports/0,
		 add_handler/2, delete_handler/2
		 , event_call/2]).

% -export ([crash/1]).

%% @doc This will read config file and add new port from config file
%% if it not yet added in application
%% @spec config() -> ok
config() ->
	case idc:dc_config() of 
		void ->
			io:format("config does not exist~n");
		PortList ->
			lists:foreach(fun({Port}) -> add_port(Port) end, PortList)
	end.

%% @doc List all ports used in application
%% @spec list_current_ports() -> ok
list_current_ports() ->
	Lists = dc_store:to_list(),
	lists:foreach(fun({Port, _}) -> io:format("Port -> ~p~n", [Port]) end, Lists).
	% io:format("~p~n", [Lists]).

%% @doc Add a port to application
%%
%% If this port is alread added,it will be ignored
%% @spec add_port(integer()) -> ok
add_port(Port) ->
	case dc_store:lookup(Port) of
		{ok, _Pid} -> 
			io:format("Port ~p already created~n", [Port]);
		{error, not_found} -> 
			{ok, ChildPid} = dc_sup:start_child(Port),
			dc_store:insert(Port, ChildPid)
	end,
	notify_add_port(Port).

%% @doc Remove a port to application
%%
%% If this port is not yet added,it will be ignored
%% @spec delete_port(integer()) -> ok	
delete_port(Port) ->
	case dc_store:lookup(Port) of
		{ok, Pid} -> dc_sup:stop_child(Pid),
					 dc_store:delete(Port),
					 io:format("stop port ~p~n", [Port]),
					 notify_delete_port(Port);
		{error, not_found} -> io:format("exception occored",[])
	end.

%% @doc Subscribe the event from data_collector
%% @spec add_handler(atom(), term()) -> ok
add_handler(Handler, Args) ->
	dc_event:add_handler(Handler, Args).

%% @doc Unsubscribe the event from data_collector
%% @spec delete_handler(atom(), term()) -> ok
delete_handler(Handler, Args) ->
	dc_event:delete_handler(Handler, Args).

event_call(Handler, Request) ->
	dc_event:call(Handler, Request).

% crash(Port) ->
% 	case dc_store:lookup(Port) of
% 		{ok, Pid} -> dc_data_receiver:crash_me(Pid);
% 		{error, not_found} -> io:format("exception occored",[])
% 	end.

%%%%================================================================
%%%% Internal API	
notify_add_port(Port) ->
	dc_event:add_port(Port),
	ok.
notify_delete_port(Port) ->
	dc_event:delete_port(Port),
	ok.


	