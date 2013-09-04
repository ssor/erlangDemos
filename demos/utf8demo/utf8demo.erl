%% -*- coding: utf-8 -*-
-module(utf8demo).
-export([server/1]).

server(Port) ->
	{ok, Socket} = gen_udp:open(Port, [binary]),
	loop(Socket).

loop(Socket) ->
	receive
		{udp, Socket, Host, Port, Bin} ->
			% 接收，处理，返回中文测试
			BinReply = unicode:characters_to_list(Bin, utf8),
			io:format("receiveed -> ~ts~n", [BinReply])
			% gen_udp:send(Socket, Host, Port, BinReply),
			% loop(Socket)
	end.