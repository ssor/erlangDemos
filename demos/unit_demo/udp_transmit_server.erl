-module(udp_transmit_server).
-export([loop/3,server_loop/2, start/1,stop/0,add_new_message/2,start_local_server/1,add_port/1,close_all_sockets/2]).
-export([stop_port/1,stop_all_prot/0]).


%以一系列端口为参数启动本地为目标地址的服务
start_local_server([]) ->
	start("192.168.1.100");
start_local_server(Port_list) ->
	start_local_server([]),
	add_port(Port_list).

	% start("localhost").

%以特定IP为目标发送数据启动服务
start(Host) -> 
% start(Host,Port) -> 
	% {ok,Socket} = gen_udp:open(Port,[binary]),
	% register(udp_transmit,spawn(fun() -> loop(Socket,Host,Port) end)).
	Dic = dict:new(),
	register(udp_transmit,spawn(fun() -> server_loop(Dic,Host) end)).
stop() ->
	case whereis(udp_transmit) of
		undefined ->
			ok;
		Pid ->
			Pid ! {stop_server},
			unregister(udp_transmit)
	end.
	% udp_transmit ! {stop_server}.

%关闭某个端口的socket
stop_port(Port) ->
	udp_transmit ! {stop,Port}.
%关闭所有端口的socket
stop_all_prot() ->
	udp_transmit ! {stop_all}.
%添加某个端口
% add_port(Port) ->
	% udp_transmit ! {add,Port}.
add_port([]) ->
	ok;
add_port([Port|T]) ->
	udp_transmit ! {add,Port},
	add_port(T).


%发送消息给服务
add_new_message(List,Port) ->
	udp_transmit ! {message,Port,List}.

server_loop(Dic,Host) ->
	receive
		{add,Port} ->%接收到消息后，添加该端口的socket到列表中
			io:format("add port ~p~n",[Port]),
			case gen_udp:open(Port,[binary]) of
				{ok,Socket} ->
					% {ok,Socket} = gen_udp:open(Port,[binary]),
					Pid = spawn(fun() -> loop(Socket,Host,Port) end),
					io:format("add Port pid = ~p~n",[Pid]),
					Dic2 = dict:store(Port,Pid,Dic),
					{ok,Value} = dict:find(Port,Dic2),
					io:format("fetch  from Dic value = ~p~n",[Value]),
					server_loop(Dic2,Host);

				{error, Reason} ->
					io:format("add port error ~p~n",[Reason]),
					server_loop(Dic,Host)
			end;

		{message,Port,List} ->%向指定端口发送数据
			case dict:find(Port,Dic) of
				{ok,Value} ->
					% {ok,Value} = dict:find(Port,Dic),
					io:format("sending message to  ~p~n",[Value]),
					Value ! {message,list_to_binary(List)};
				error ->
					io:format("sending message to  error~n")
			end,
			server_loop(Dic,Host);

		{stop,Port} ->%关闭端口
			case dict:find(Port,Dic) of
				{ok,Value} ->
					% {ok,Value} = dict:find(Port,Dic),
					Value ! {stop},
					Dic2 = dict:erase(Port,Dic),
					server_loop(Dic2,Host);
				error ->
					server_loop(Dic,Host)
			end;
		{stop_all} ->%关闭所有端口
			Keys = dict:fetch_keys(Dic),
			close_all_sockets(Keys,Dic);
		{stop_server} ->
			io:format("server exit ~n"),
			ok;
		Other ->
			io:format("a new server request is missed ~p~n",[Other]),
			server_loop(Dic,Host)
	end.

close_all_sockets([],_Dic) ->
	ok;
close_all_sockets(Keys,Dic) ->
	[H|T] = Keys,
		case dict:find(H,Dic) of
		{ok,Value} ->
			Value ! {stop},
			Dic2 = dict:erase(H,Dic),
			% server_loop(Dic2,Host);
		close_all_sockets(T,Dic2);
		error ->
			error,
			close_all_sockets(T,Dic)
			% server_loop(Dic,Host)
	end.

loop(Socket,Host,Port) ->
	io:format("~p wait for message...~n",[Port]),
       receive 
	 	{message,Data} ->
            io:format("port ~p receive data ~p~n",[Port,Data]),
			gen_udp:send(Socket,Host,Port,Data),
	    	loop(Socket,Host,Port);
	    {stop} ->
			gen_udp:close(Socket),
	    	io:format("stop work!!!~n");
	 	Other ->
	    	io:format("receive unknown format data of ~p is ~n",[Other])
		end.    
