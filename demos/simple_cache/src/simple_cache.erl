-module(simple_cache).
-export([insert/2,lookup/1,delete/1]).

insert(Key,Value)->
	case sc_store:lookup(Key) of
		{ok,Pid} ->		
			sc_element:replace(Pid,Value),
			sc_event:replace(Key,Value);
		{error,_}->
			{ok,Pid} = sc_element:create(Value),
			sc_store:insert(Key,Pid),
			sc_event:create(Key,Value)
	end.

lookup(Key) ->
	try
		{ok,Pid} = sc_store:lookup(Key),
		{ok,Value} = sc_element:fetch(Pid),
		sc_event:lookup(Key),
		{ok,Value}
	catch
		_Class:_Exception ->
			{error,not_found}
	end.

delete(Key) ->
	case sc_store:lookup(Key) of
		{ok,Pid} ->
			sc_element:delete(Pid),
			sc_event:delete(Key);
		{error,_Reason} ->
			ok
	end.

