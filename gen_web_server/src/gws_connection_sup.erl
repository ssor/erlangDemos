-module(gws_connection_sup).
-behaviour(supervisor).

% API
-export([start_link/4, start_child/1]).

%% Supervisor callbacks
-export([init/1]).
-define(SERVER,?MODULE).

start_link(Callback, IP, Port, UserArgs) ->
% ?SERVER : used to register as a name

	{ok, Pid} =	supervisor:start_link(?MODULE, [Callback, IP,
												Port, UserArgs]),
	start_child(Pid),
	{ok, Pid}.

	
start_child(Server) ->
	supervisor:start_child(Server, []).
	% supervisor:start_link({local,?SERVER}, ?MODULE, [Port]).

%% and the passed para will be appended to it permanent
% temporary
init([Callback, IP, Port, UserArgs]) ->
	BasicSockOpts = [binary,
					 {active, false},
					 {packet, http_bin},
					 {reuseaddr, true}],
	SockOpts = case IP of 
					undefined -> BasicSockOpts;
					_		  -> [{ip, IP} | BasicSockOpts]
				end,
	{ok, LSock} = gen_tcp:listen(Port, SockOpts),
	Server = {gws_server, {gws_server, start_link,
							[Callback, LSock, UserArgs]},
			  temporary, brutal_kill, worker, [gws_server]},

	RestartStrategy = {simple_one_for_one, 4, 3600},
	{ok, {RestartStrategy, [Server]}}.