%% Feel free to use, reuse and abuse the code in this file.

%% @doc GET echo handler.
-module(post_cmd_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/2]).
-record(state,{}).
-include("http.hrl").

init(_Transport, Req, []) ->
	% io:format("init ->  ~n"),
	{ok, Req, #state{}}.

handle(Req, State) ->
	% io:format("handle post 1 -> ~p~n", [Req]),
	{Method, _Req2} = cowboy_http_req:method(Req),
	{Path, _Req3} = cowboy_http_req:path(Req),
	{Length, _Req5} = cowboy_http_req:body_length(Req),
	HasBody =  Length > 0,
	% io:format("Method -> ~p~n", [Method]),
	case Method of
				'POST' ->
					case HasBody of 
						true -> 
							case cowboy_http_req:qs_val(<<"flag">>, Req) of 
								{undefined, _} -> 
									io:format("Url format is not supported!~n");
								{Value, _Req4}  ->
									io:format("flag value -> ~p path ->~p~n", [binary_to_list(Value), Path]),
									echo_post_cmd(Path, binary_to_list(Value), Req)
							end;
						false -> 
							cowboy_http_req:reply(400, [], <<"Body Needed!">>, Req)
					end;
					% io:format("headers -> ~p~n", [Req#http_req.headers]),
					% io:format("All -> ~p~n", [Req]),
					% QsValue = cowboy_http_req:qs_val(<<"flag">>, Req),
					% io:format("QsValue -> ~p~n", [QsValue]),
					% QsValue2 = cowboy_http_req:qs_val(<<"key">>, Req),
					% io:format("QsValue -> ~p~n", [QsValue2]);
					% dispatch_path(Path, Req);
					% {HasBody, Req3} = cowboy_http_req:has_body(Req2),
					% io:format("headers -> ~p~n", [Req#http_req.headers]),
					% Has = lists:keymember('Content-Length', 1, Req#http_req.headers),
					% {Length, _Req4} = cowboy_http_req:body_length(Req),
					% HasBody =  Length > 0 ,
					% io:format("body_length -> ~p~n", [Length]),
					% io:format("handle post 2 -> ~p  ~p ~n", [Method, HasBody]),
					% {ok, Req5} = maybe_echo(Method, HasBody, Req2);
					% io:format("Path  -> ~p~n", [Path]),
				'GET' ->
					case cowboy_http_req:qs_val(<<"flag">>, Req) of 
						{undefined, _} -> 
							% io:format("Url format is not supported!~n");
							echo_get_cmd(Path, undefined, Req);
						{Value, _Req6}  ->
							io:format("flag value -> ~p~n", [Value]),
							echo_get_cmd(Path, binary_to_list(Value), Req)
					end
					% echo_get_cmd(HasBody, Req)
					% io:format("GET -> ~n"),
					% cowboy_http_req:reply(400, [], <<"Not Supported!">>, Req),
					% echo(<<"Not Supported!">>, Req)
					% echo(undefined, Req)
	end,
	{ok, Req, State}.

echo_post_cmd(Path, Flag, Req) ->
	io:format("echo_post_cmd/3 -> Path -> ~p~n", [Path]),
	{ok, Body, _Req2} = cowboy_http_req:body(Req),
	case Path of 
		[<<"post_cmd">>] ->
				io:format("post_cmd Flag -> ~p  Body -> ~p~n", [Flag, binary_to_list(Body)]),
				command_store:insert_command(Flag, Body),
				echo("[ok]" ++ Body, Req);
		_ ->
			io:format("post_cmd Not Supported!~n"),
			cowboy_http_req:reply(400, [], <<"Not Supported!">>, Req)
	end.

echo_get_cmd(Path, undefined, Req) ->
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	case Path of
		[<<"check_time">>] ->
			echo("[" ++ integer_to_list(CurrentTime) ++ "]", Req);				
		_ ->
				cowboy_http_req:reply(400, [], <<"Not Supported!">>, Req)
	end;
	 		
echo_get_cmd(Path, Flag, Req) ->
	Now = calendar:local_time(),
	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
	case Path of 
		[<<"get_cmd">>] ->
			io:format("get_cmd Flag -> ~p ", [Flag]),
			% Flag = case cowboy_http_req:qs_val(<<"flag">>, Req) of 
			% 	{undefined, _} -> undefined;
			% 	{Value, _} -> Value
			% end,
			TimeStamp = case cowboy_http_req:qs_val(<<"check_time">>, Req) of 
				{undefined, _} -> 
					CurrentTime;
				{Value, _} -> 
					I = try list_to_integer(binary_to_list(Value)) of Int -> Int  catch _:_ -> CurrentTime end,
					I
			end,
			{ok, Response} = command_store:get_command_list(Flag, TimeStamp),
			echo(Response, Req);

		% [<<"check_time">>] ->
		% 	echo("[" ++ integer_to_list(CurrentTime) ++ "]", Req);				
		_ ->
				cowboy_http_req:reply(400, [], <<"Not Supported!">>, Req)
	end.

% echo_get_cmd(false, Req) ->
% 	% cowboy_http_req:reply(400, [], <<"parameter needed!">>, Req);
% 	Now = calendar:local_time(),
% 	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
% 	echo(integer_to_list(CurrentTime), Req);
% echo_get_cmd(true, Req) ->
% 	{ok, Body, Req2} = cowboy_http_req:body(Req),
% 	Echo = case dispose_command_string(binary_to_list(Body)) of 
% 			{match, [Command|_]} ->
% 				#command{falg = CommandFlag, time_stamp = CommandTimeStamp} = Command,

% 				Commands = command_store:get_command_list(CommandFlag, CommandTimeStamp),
% 				% io:format("Flag = ~p  Get Commands -> ~p~n", [CommandFlag, Commands]),
% 				format_response_command(CommandFlag, Commands, []);
% 				% format_command(CommandList, []);
% 			{nomatch, []} ->
% 				<<"">>
% 				% void
% 	end,
% 	echo(Echo, Req2).	


% dispatch_path([Path], Req) ->
% 	{Length, _Req2} = cowboy_http_req:body_length(Req),
% 	HasBody =  Length > 0,
% 	case Path of 
% 		<<"post_cmd">> ->
% 			% {ok, _} = maybe_echo('POST', HasBody, Req);
% 			echo_post_cmd(HasBody, Req);
% 		<<"get_cmd">>  ->
% 			echo_get_cmd(HasBody, Req)
% 	end.


% echo_post_cmd(true, Req) ->
% 	{ok, Body, Req2} = cowboy_http_req:body(Req),
% 	case dispose_command_string(binary_to_list(Body)) of 
% 			{match, CommandList} ->
% 				command_store:insert_command_list(CommandList),
% 				ok;
% 			{nomatch, []} ->
% 				void
% 	end,
% 	echo(Body, Req2);	
% echo_post_cmd(false, Req) ->
% 	cowboy_http_req:reply(400, [], <<"Not Supported!">>, Req).


% maybe_echo('POST', true, Req) ->
% 	{ok, Body, Req2} = cowboy_http_req:body(Req),
% 	Echo = case dispose_command_string(binary_to_list(Body)) of 
% 				{match, CommandList} ->
% 					format_command(CommandList, []);
% 				{nomatch, []} ->
% 					<<"">>
% 			end,
% 	echo(Echo, Req2);
% 	% 这里只是返回一个当前服务器的时间，作为命令请求的初始参数
% maybe_echo('POST', false, Req) ->
% 	Now = calendar:local_time(),
% 	CurrentTime = calendar:datetime_to_gregorian_seconds(Now),
% 	echo(integer_to_list(CurrentTime), Req);
% 	% cowboy_http_req:reply(400, [], <<"Missing body.">>, Req);
% maybe_echo(_, _, Req) ->
% 	%% Method not allowed.
% 	cowboy_http_req:reply(405, Req).

echo(undefined, Req) ->
	cowboy_http_req:reply(400, [], <<"Missing echo parameter.">>, Req);
echo(Echo, Req) ->
	% io:format("echo ~p~n", [Echo]),
	cowboy_http_req:reply(200,
		[{<<"Content-Encoding">>, <<"utf-8">>}], Echo, Req).

terminate(_Req, _State) ->
	ok.

% format_response_command(_, [], String) ->
% 	String;
% format_response_command(Flag, [H|T], String) ->
% 	{Name, Args, TimeStamp} = H,
% 	FormatedCommand = "[" ++ Flag ++ "," ++ Name ++ "," ++ Args ++ "," ++ integer_to_list(TimeStamp) ++ "]",
% 	% io:format("FormatedCommand -> ~p~n", [FormatedCommand]),
% 	format_response_command(Flag, T, FormatedCommand ++ String).

% format_command([], String) ->
% 	String;
% format_command([H|T], String) ->
% 	#command{falg = CommandFlag, name = CommandName, arg = CommandArgs, time_stamp = TimeStamp} = H,
% 	FormatedCommand = "[" ++ CommandFlag ++ "," ++ CommandName ++ "," ++ CommandArgs ++ "," ++ integer_to_list(TimeStamp) ++ "]",
% 	format_command(T, FormatedCommand ++ String).

% dispose_command_string(StringList) ->
% 	ReList = "\\[\\w{1,},\\w{1,},\\w{1,},\\w{1,}\\]",
% 	case re:run(StringList, ReList, [global]) of
% 		{match, Captured} ->
% 			{ok, CommandList} = parse_command(Captured, StringList),
% 			{match, CommandList};
% 		nomatch	->
% 			% io:format("no match~n")
% 			{nomatch, []}
% 	end.
% parse_command(Captured, StringList) ->
% 	FuncNewCommand = fun([{StartIndex, Length}]) -> 
% 						SubString = string:substr(StringList, StartIndex + 2, Length -2),
% 						[CommandFlag, CommandName, CommandArgs, TimeStamp] = string:tokens(SubString, ","),
% 						I = try list_to_integer(TimeStamp) of Int -> Int  catch _:_ -> undefined end,
% 						#command{falg = CommandFlag, name = CommandName, arg = CommandArgs, time_stamp = I} 
% 					end,
% 	CommandList = lists:map(FuncNewCommand, Captured),
% 	% io:format("CommandList -> ~p~n", [CommandList]),
% 	{ok, CommandList}.
