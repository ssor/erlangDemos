-module(test).

-export([test1/0, test2/0]).
-record(command, {falg, name, arg, time_stamp}).

test2() ->

	List = "123",
	I = try list_to_integer(List) of Int -> Int  catch _:_ -> undefined end,
	io:format("I => ~p~n", [I]).

test1() ->
	Command = "[falg1,name1,arg1,1234567][falg2,name2,arg24,12345678][falg3,name31,arg31,123456789]",
	% ReList = "\\[\\w{1,},\\w{1,}\\]",
	Echo = case dispose_command(Command) of 
			{match, CommandList} ->
				format_command(CommandList, []);
			{nomatch, []} ->
				<<"">>
		end,
	io:format("Echo -> ~p~n", [Echo]).

format_command([], String) ->
	String;
format_command([H|T], String) ->
	#command{falg = CommandFlag, name = CommandName, arg = CommandArgs, time_stamp = TimeStamp} = H,
	FormatedCommand = "[" ++ CommandFlag ++ "," ++ CommandName ++ "," ++ CommandArgs ++ "," ++ TimeStamp ++ "]",
	format_command(T, FormatedCommand ++ String).

dispose_command(StringList) ->
	ReList = "\\[\\w{1,},\\w{1,},\\w{1,},\\w{1,}\\]",
	case re:run(StringList, ReList, [global]) of
		{match, Captured} ->
			{ok, CommandList} = parse_command(Captured, StringList),
			{match, CommandList};
		nomatch	->
			% io:format("no match~n")
			{nomatch, []}
	end.
parse_command(Captured, StringList) ->
	FuncNewCommand = fun([{StartIndex, Length}]) -> 
						SubString = string:substr(StringList, StartIndex + 2, Length -2),
						[CommandFlag, CommandName, CommandArgs, TimeStamp] = string:tokens(SubString, ","),
						I = try list_to_integer(TimeStamp) of Int -> Int  catch _:_ -> undefined end,
						#command{falg = CommandFlag, name = CommandName, arg = CommandArgs, time_stamp = I} 
					end,
	CommandList = lists:map(FuncNewCommand, Captured),
	io:format("CommandList -> ~p~n", [CommandList]),
	{ok, CommandList}.

% parse_command([], _, CommandList) ->
% 	io:format("CommandList -> ~p~n", [CommandList]),
% 	ok;
% parse_command([H|T], StringList, CommandList) ->
% 	io:format("parse_command -> ~p~n", [H]),
% 	[{StartIndex, Length}] = H,
% 	SubString = string:substr(StringList, StartIndex + 2, Length -2),
% 	io:format("sub string -> ~p~n", [SubString]),
% 	Tokens = string:tokens(SubString, ","),
% 	io:format("Tokens ->~p~n", [Tokens]),
% 	[CommandName, CommandArgs] = Tokens,
% 	NewCommand = #command{name = CommandName, arg = CommandArgs}, 
% 	% FuncNewCommand = fun({CommandName, CommandArgs}) -> 
% 						% #command{name = CommandName, arg = CommandArgs} 
% 					% end,
% 	% CommandList = lists:map(FuncNewCommand, Tokens)
% 	parse_command(T, StringList, CommandList ++ [NewCommand]).
	

