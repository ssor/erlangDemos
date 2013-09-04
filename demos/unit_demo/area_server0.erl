-module(area_server0).
-export([loop/0,loop2/0,area/2,start/0]).

start() -> spawn(fun loop2/0).

area(Pid,What) ->
	rpc(Pid,What).

rpc(Pid,Request) ->
	Pid ! {self(),Request},
	receive
		{Pid,Response} ->
			Response
	after 2000 ->
		io:format("no Response From Server")

	end.


loop() ->
       receive 
        {rectangle,Width,Ht} ->
            io:format("Area of rectangle is ~p~n",[Width * Ht]),
	    	loop();
	 	{circle,R} ->
            io:format("Area of circle is ~p~n",[3.14159 * R * R]),
	    	loop();
	 	Other ->
	    	io:format("no answer of ~p is ~n",[Other]),
	    	loop()
		end.    

loop2() ->
	receive
	{From,{rectangle,Width,Ht}} ->
		io:format("Area of rectangle is ~p~n",[Width * Ht]),
		From! {From, Width * Ht},
		loop2();
	{From,{circle,R}} ->
        io:format("Area of circle is ~p~n",[3.14159 * R * R]),
        From! {From,3.14 * R * R},
    	loop2();
    {From,Other} ->
    	io:format("no answer of ~p is ~n",[Other]),
    	From ! {From,"no Response"},
    	loop2()
    end.