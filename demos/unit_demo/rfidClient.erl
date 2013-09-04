%rfidClient.erl
-module(rfidClient).
-export([initialData/1, getSubData/2,random/1,startRandom/2]).

%需要首先启动udp转发服务，才能运行本模块功能

%将数据读取到内存中
initialData(Port) ->
	{ok,Bin} = file:read_file("data.txt"),
	List = binary_to_list(Bin),
	% udp_transmit_server:stop(),
	% udp_transmit_server:start_local_server([5000]),
	getSubData(List,Port).

%截取随机长度的字符串
getSubData(List,Port) ->
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
					getSubData(ListAfter,Port);
				Length >= length(List) ->
					io:format("over!!!!")
			end;
		Seed =< 0 ->
			io:format("over !!!!")
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
            io:format("~p is generated!~n", [R]),  
            R;  
        true -> ok  
    end. 
