-module(dc_event).

-export([start_link/0,
		 add_handler/2,
		 delete_handler/2,
		 received_data/2,
		 add_port/1,
		 delete_port/1,
		 call/2]).

-define(SERVER, ?MODULE).

start_link() ->
	% gen_event:start_link().
	gen_event:start_link({local, ?SERVER}).

add_handler(Handler, Args) ->
	gen_event:add_handler(?SERVER, Handler, Args).

delete_handler(Handler, Args) ->
	gen_event:delete_handler(?SERVER, Handler, Args).

received_data(Port, Packet) ->
	gen_event:notify(?SERVER, {data, Port, Packet}).

add_port(Port) ->
	gen_event:notify(?SERVER, {add_port, Port}).

delete_port(Port) ->
	gen_event:notify(?SERVER, {delete_port, Port}).

call(Handler, Request) ->
	gen_event:call(?SERVER, Handler, Request).