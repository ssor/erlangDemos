% 周期性的广播一些数据
-module(broadcaster).

-export([start/0]).


start() ->
    {ok, HostName} = inet:gethostname(),
    io:format("HostName -> ~p~n", [HostName]),
    NewAddress = case inet:getaddr(HostName, inet) of
        {ok, {IP1,IP2,IP3,_}} -> 
                {IP1, IP2, IP3, 255};
        {error, _} ->
            io:format("error occored when get IP Address~n"),
            {255,255,255,255}
    end,
    {ok, S} = gen_udp:open(12306, [{broadcast, true}]),
    gen_udp:send(S, NewAddress, 12306, "abc123"),
    gen_udp:close(S),
    Content = case file:read_file("data.txt") of 
        {error, enoent} ->
            io:format("data file does not exist~n"),
            "";
        {ok, Data} ->
            Data
    end,
    Content.
	% ok.

