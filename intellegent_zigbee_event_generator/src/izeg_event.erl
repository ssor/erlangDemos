-module(izeg_event).

-export([start_link/0,
		 add_handler/2,
		 delete_handler/2
		 , call/2
		 , notify/2
		 , interval_humidity_notify/2
		 , interval_temperature_notify/2
		 , humidity_lower/2
		 , humidity_higher/2
		 , temperature_lower/2
		 , temperature_higher/2
		 , humidity_too_low/2
		 , humidity_too_high/2
		 , temperature_too_low/2
		 , temperature_too_high/2]).

-define(SERVER, ?MODULE).

start_link() ->
	% gen_event:start_link().
	gen_event:start_link({local, ?SERVER}).

add_handler(Handler, Args) ->
	gen_event:add_handler(?SERVER, Handler, Args).

delete_handler(Handler, Args) ->
	gen_event:delete_handler(?SERVER, Handler, Args).

interval_humidity_notify(Port, {Address, NodeID, Humidity}) ->
	io:format("interval_humidity_notify  Address ~p, NodeID ~p, Humidity ~p~n", [Address, NodeID, Humidity]),
	gen_event:notify(?SERVER, {interval_humidity_notify, Port, {Address, NodeID, Humidity}}).

interval_temperature_notify(Port, {Address, NodeID, Temp}) ->
	io:format("interval_temperature_notify Address -> ~p Address ~p, NodeID ~p, Temp ~p~n", [Address, Address, NodeID, Temp]),
	gen_event:notify(?SERVER, {interval_temperature_notify, Port, {Address, NodeID, Temp}}).

humidity_lower(Port, {Address, NodeID, Humidity}) ->
	% io:format("humidity_lower Address -> ~p Address ~p, NodeID ~p, Humidity ~p~n", [Address, Address, NodeID, Humidity]),
	gen_event:notify(?SERVER, {humidity_lower, Port, {Address, NodeID, Humidity}}).

humidity_higher(Port, {Address, NodeID, Humidity}) ->
	% io:format("humidity_higher Address -> ~p Address ~p, NodeID ~p, Humidity ~p~n", [Address, Address, NodeID, Humidity]),
	gen_event:notify(?SERVER, {humidity_higher, Port, {Address, NodeID, Humidity}}).

humidity_too_low(Port, {Address, NodeID, Humidity}) ->
	% io:format("humidity_too_low Address -> ~p Address ~p, NodeID ~p, Humidity ~p~n", [Address, Address, NodeID, Humidity]),
	gen_event:notify(?SERVER, {humidity_too_low, Port, {Address, NodeID, Humidity}}).

humidity_too_high(Port, {Address, NodeID, Humidity}) ->
	% io:format("humidity_too_high Address -> ~p Address ~p, NodeID ~p, Humidity ~p~n", [Address, Address, NodeID, Humidity]),
	gen_event:notify(?SERVER, {humidity_too_high, Port, {Address, NodeID, Humidity}}).

temperature_lower(Port, {Address, NodeID, Temp}) ->
	% io:format("temperature_lower Address -> ~p Address ~p, NodeID ~p, Temp ~p~n", [Address, Address, NodeID, Temp]),
	gen_event:notify(?SERVER, {temperature_lower, Port, {Address, NodeID, Temp}}).

temperature_higher(Port, {Address, NodeID, Temp}) ->
	% io:format("temperature_higher Address -> ~p Address ~p, NodeID ~p, Temp ~p~n", [Address, Address, NodeID, Temp]),
	gen_event:notify(?SERVER, {temperature_higher, Port, {Address, NodeID, Temp}}).

temperature_too_low(Port, {Address, NodeID, Temp}) ->
	% io:format("temperature_too_low Address -> ~p Address ~p, NodeID ~p, Temp ~p~n", [Address, Address, NodeID, Temp]),
	gen_event:notify(?SERVER, {temperature_too_low, Port, {Address, NodeID, Temp}}).

temperature_too_high(Port, {Address, NodeID, Temp}) ->
	% io:format("temperature_too_high Address -> ~p Address ~p, NodeID ~p, Temp ~p~n", [Address, Address, NodeID, Temp]),
	gen_event:notify(?SERVER, {temperature_too_high, Port, {Address, NodeID, Temp}}).

call(Handler, Request) ->
	gen_event:call(?SERVER, Handler, Request).
notify(Handler, Request) ->
	gen_event:notify(?SERVER, Handler, Request).


% add_port(Port) ->
% 	gen_event:notify(?SERVER, {add_port, Port}).

% delete_port(Port) ->
% 	gen_event:notify(?SERVER, {delete_port, Port}).