-module(reg_event).

-export([start_link/0,
		 add_handler/2,
		 delete_handler/2,
		 get_new_tag/2,
		 add_port/1,
		 delete_port/1
		 , call/2
		 , notify/2]).

-define(SERVER, ?MODULE).

start_link() ->
	% gen_event:start_link().
	gen_event:start_link({local, ?SERVER}).

add_handler(Handler, Args) ->
	gen_event:add_handler(?SERVER, Handler, Args).

delete_handler(Handler, Args) ->
	gen_event:delete_handler(?SERVER, Handler, Args).

get_new_tag(Port, {Event, Tag, Ant, Count}) ->
	% io:format("event -> ~p   Tag -> ~p~n", [Event, Tag]),
	gen_event:notify(?SERVER, {Event, Port, {Tag, Ant, Count}}).
	% case Event of
	% 	tag_ant_change -> 

	% 	tag_missed_read ->


	% end.
	
% get_new_tag_unclear(Port, {Tag, Ant, Count}) ->
% 	gen_event:notify(?SERVER, {new_tag_unclear, Port, {Tag, Ant, Count}}).

add_port(Port) ->
	% io:format("reg_event -> add_port  ~p~n", [Port]),
	gen_event:notify(?SERVER, {add_port, Port}).

delete_port(Port) ->
	gen_event:notify(?SERVER, {delete_port, Port}).

call(Handler, Request) ->
	gen_event:call(?SERVER, Handler, Request).
notify(Handler, Request) ->
	gen_event:notify(?SERVER, Handler, Request).
