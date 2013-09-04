-module(icreg_event).

-export([start_link/0,
		 add_handler/2,
		 delete_handler/2,
		 tag_new/2,
		 tag_ant_change/2,
		 tag_disapear/2,
		 add_port/1,
		 delete_port/1,
		 tag_existing/2]).

-define(SERVER, ?MODULE).

start_link() ->
	% gen_event:start_link().
	gen_event:start_link({local, ?SERVER}).

add_handler(Handler, Args) ->
	% io:format("icreg_event -> add_handler ~p~n", [Handler]),
	gen_event:add_handler(?SERVER, Handler, Args).

delete_handler(Handler, Args) ->
	gen_event:delete_handler(?SERVER, Handler, Args).

tag_new(Port, {Tag, Ant, Count}) ->
	% io:format("icreg_event -> tag_new   Tag -> ~p~n", [Tag]),
	gen_event:notify(?SERVER, {tag_new, Port, {Tag, Ant, Count}}).

tag_ant_change(Port, {Tag, Ant, Count}) ->
	% io:format("icreg_event -> tag_ant_change   Tag -> ~p~n", [Tag]),
	gen_event:notify(?SERVER, {tag_ant_change, Port, {Tag, Ant, Count}}).

tag_disapear(_, []) -> void;
tag_disapear(Port, Tags) ->
	% io:format("icreg_event -> tag_disapear   Tag -> ~p~n", [Tags]),
	[H|T] = Tags,
	gen_event:notify(?SERVER, {tag_disapear, Port, H}),
	tag_disapear(Port, T).
% get_new_tag_unclear(Port, {Tag, Ant, Count}) ->
% 	gen_event:notify(?SERVER, {new_tag_unclear, Port, {Tag, Ant, Count}}).

tag_existing(_, []) -> void;
tag_existing(Port, Tags) ->
	% [H|T] = Tags,
	% {Tag, Ant, Count} = H
	% io:format("icreg_event tag_existing ->~n"),
	gen_event:notify(?SERVER, {tag_existing, Port, Tags}).
	% tag_existing(Port, T).

add_port(Port) ->
	gen_event:notify(?SERVER, {add_port, Port}).

delete_port(Port) ->
	gen_event:notify(?SERVER, {delete_port, Port}).