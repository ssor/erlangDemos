-module(zeg_event).

-export([start_link/0,
		 add_handler/2,
		 delete_handler/2,
		 get_new_info/2
		 , call/2
		 , notify/2
		 , add_port/1
		 , delete_port/1]).

-define(SERVER, ?MODULE).

start_link() ->
	% gen_event:start_link().
	gen_event:start_link({local, ?SERVER}).

add_handler(Handler, Args) ->
	gen_event:add_handler(?SERVER, Handler, Args).

delete_handler(Handler, Args) ->
	gen_event:delete_handler(?SERVER, Handler, Args).

% get_new_info(Port, {EventOfTemp, EventOfHuminity, Address, NodeID, Huminity, Temp}) ->
get_new_info(Port, {Address, NodeID, Huminity, Temp}) ->
	% io:format("zeg_event -> Huminity -> ~p, Temp -> ~p~n",
				% [Huminity, Temp]),
	% gen_event:notify(?SERVER, {event, Port, {EventOfTemp, EventOfHuminity, Address, NodeID, Huminity, Temp}}).
	gen_event:notify(?SERVER, {event, Port, {Address, NodeID, Huminity, Temp}}).

add_port(Port) ->
	gen_event:notify(?SERVER, {add_port, Port}).

delete_port(Port) ->
	gen_event:notify(?SERVER, {delete_port, Port}).


call(Handler, Request) ->
	gen_event:call(?SERVER, Handler, Request).
notify(Handler, Request) ->
	gen_event:notify(?SERVER, Handler, Request).

% get_new_tag_unclear(Port, {Tag, Ant, Count}) ->
% 	gen_event:notify(?SERVER, {new_tag_unclear, Port, {Tag, Ant, Count}}).

% add_port(Port) ->
% 	gen_event:notify(?SERVER, {add_port, Port}).

% delete_port(Port) ->
% 	gen_event:notify(?SERVER, {delete_port, Port}).