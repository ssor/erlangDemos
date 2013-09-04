%rfidClient.erl
-module(rfidClient3).
-export([start_server/2,add_ports/2,stop_all_ports/0, start_send_data/2,stop_send_data/1]).
-export([loop/1, send/3,random/1,startRandom/2]).

%需要首先启动udp转发服务，才能运行本模块功能


%启动服务
start_server(Port_list,File) ->
	start_server(),
	add_ports(Port_list,File).

start_server() ->
	Dic = dict:new(),
	register(rfid_client,spawn(fun() -> loop(Dic) end)).

stop_all_ports() ->
	rfid_client ! {stop_all}.

add_ports([],_File) ->
	ok;
add_ports([Port|T],File) ->
	start_send_data(Port,File),
	add_ports(T,File).

%添加一个端口
start_send_data(Port,File) ->
	%将数据读取到内存中
	{ok,Bin} = file:read_file(File),
	List = binary_to_list(Bin),
	rfid_client ! {start,List,Port,List}.

stop_send_data(Port) ->
	rfid_client ! {stop,Port}.

loop(Dic) ->
	receive
		{stop_all} ->
			Keys = dict:fetch_keys(Dic),
			close_all_port(Dic,Keys);
		{stop,Port} ->
			case dict:find(Port,Dic) of
				{ok,Value} ->
					Value ! cancel,
					Dic2 = dict:erase(Port,Dic),
					loop(Dic2);
				error ->
					loop(Dic)
			end;
		{start,List,Port,List} ->
			Pid = spawn(fun() -> send(List,Port,List) end),
			io:format("add Port pid = ~p~n",[Pid]),
			Dic2 = dict:store(Port,Pid,Dic),
			loop(Dic2)
	end.

close_all_port(_Dic,[]) ->
	ok;
close_all_port(Dic,[Key|T]) ->
	case dict:find(Key,Dic) of
		{ok,Value} ->
			Value ! cancel,
			Dic2 = dict:erase(Key,Dic),
		close_all_port(Dic2,T);
		error ->
			error,
			close_all_port(Dic,T)
	end.
	


%截取随机长度的字符串
send(List,Port,Total_list) ->
	receive
		cancel ->
			io:format("work is canceled ~n")
	after 1000 ->
			%最大长度100，如果整体长度小于100，就已整体长度为种子
			DefaultIndex = 100,
			if
				DefaultIndex > length(List) ->
					Seed = length(List);
				DefaultIndex =< length(List) ->
					Seed = DefaultIndex
			end,

			if
				Seed > 0 ->
					Length = random(Seed), 
					% Index = random(length(List)), 
					ListBefore = lists:sublist(List, Length),
					io:format("~p~n",[ListBefore]),
					send_data_via_udp(ListBefore,Port),
					if
						Length < length(List) ->
							ListAfter = lists:sublist(List, Length+1, length(List) - length(ListBefore)),
							send(ListAfter,Port,Total_list);
						Length >= length(List) ->
							io:format("one loop over!!!!~n"),
							send(Total_list,Port,Total_list)
					end;
				Seed =< 0 ->
					io:format("over !!!! ~n"),
					send(Total_list,Port,Total_list)
			end
	end.


send_data_via_udp(List,Port) ->
	udp_transmit_server:add_new_message(List,Port).
	% {ok,Socket} = gen_udp:open(0,[binary]),
	% io:format("client opened socket = ~p~n",[Socket]),
	% ok = gen_udp:send(Socket,"192.168.1.100",5000,list_to_binary(List)),
	% gen_udp:close(Socket).



%测试获取随机数，使用种子10
startRandom(N,Seed) ->
	case N > 1 of
		 true  ->  
			random(Seed),
		 	startRandom(N-1,Seed);
		 false ->
			1
	end.
	



%获取一个随机数
random(N) ->   
    %io:format("seed: ~p~n", [N]),  
    if is_integer(N) ->   
            R = random:uniform(N),  
            % io:format("~p is generated!~n", [R]),  
            R;  
        true -> ok  
    end. 
