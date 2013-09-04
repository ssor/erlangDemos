%socket_example
-module(socket_example).
-export([start_nano_server/0,nano_client_eval/1]).


nano_client_eval(Str)->
	{ok,Socket} = 
		gen_tcp:connect("localhost",9005,
						[binary,{packet,4}]),
	ok = gen_tcp:send(Socket,term_to_binary(Str)),
	receive
		{tcp,Socket,Bin}->
			io:format("client received binary = ~p~n",[Bin]),
			Val = binary_to_term(Bin),
			io:format("client result = ~p~n",[Val]),
			gen_tcp:close(Socket)
	end.

start_nano_server()->
	{ok,Listen} = gen_tcp:listen(9005,
							[binary,
							 {packet,4},
							 {reuseaddr,true},
							 {active,true}]),
	{ok,Socket} = gen_tcp:accept(Listen),
	gen_tcp:close(Listen),
	loop(Socket).


loop(Socket)->
	receive
		{tcp,Socket,Bin} ->
				io:format("server received binary = ~p~n",[Bin]),
				Str = binary_to_term(Bin),
				io:format("server (unpacked)  ~p~n",[Str]),
				%Reply = lib_misc:string2value(Str),
				io:format("Server replying = ~p~n",[Str]),
				gen_tcp:send(Socket,term_to_binary(Str)),
				loop(Socket);
		{tcp_closed,Socket} ->
				io:format("server socket closed ~n")
	end.