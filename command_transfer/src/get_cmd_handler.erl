%% Feel free to use, reuse and abuse the code in this file.

%% @doc GET echo handler.
-module(get_cmd_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/2]).
% -include("http.hrl").

init(_Transport, Req, []) ->
	{ok, Req, state}.

handle(Req, State) ->
	io:format("get_cmd_handler handle post 1 -> ~p~n", [Req]),
	io:format("get_cmd_handler handle State 1 -> ~p~n", [State]),
	{Method, Req2} = cowboy_http_req:method(Req),
	% {HasBody, Req3} = cowboy_http_req:has_body(Req2),
	% io:format("headers -> ~p~n", [Req#http_req.headers]),
	% Has = lists:keymember('Content-Length', 1, Req#http_req.headers),
	{Length, _Req3} = cowboy_http_req:body_length(Req),
	HasBody =  Length > 0 ,
	% io:format("body_length -> ~p~n", [Length]),
	% io:format("handle post 2 -> ~p  ~p ~n", [Method, HasBody]),
	{ok, Req4} = maybe_echo(Method, HasBody, Req2),
	{ok, Req4, State}.

maybe_echo('POST', true, Req) ->
	{PostVals, Req2} = cowboy_http_req:body_qs(Req),
	io:format("PostVals -> ~p~n", [PostVals]),
	Echo = proplists:get_value(<<"echo">>, PostVals),
	echo(Echo, Req2);
	% 这里只是返回一个当前服务器的时间，作为命令请求的初始参数
maybe_echo('POST', false, Req) ->
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	echo(integer_to_list(CurrentTime), Req);
	% cowboy_http_req:reply(400, [], <<"Missing body.">>, Req);
maybe_echo(_, _, Req) ->
	%% Method not allowed.
	cowboy_http_req:reply(405, Req).

echo(undefined, Req) ->
	cowboy_http_req:reply(400, [], <<"Missing echo parameter.">>, Req);
echo(Echo, Req) ->
	cowboy_http_req:reply(200,
		[{<<"Content-Encoding">>, <<"utf-8">>}], Echo, Req).

terminate(_Req, _State) ->
	ok.
