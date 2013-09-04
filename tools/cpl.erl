-module(cpl).
-export([c/0, c/1, mc/0, mc/1]).

c() -> 
	FileList = filelib:wildcard("*.erl"),
	lists:foreach(fun(F) -> c:c(F) end, FileList).

% compile_file(File) ->
% 	c:c(File).

c(FilePrefix) ->
	FileList = filelib:wildcard(erlang:atom_to_list(FilePrefix) ++ "*.erl"),
	lists:foreach(fun(F) -> c:c(F) end, FileList).


mc() ->
	c(),
	% move from folder src  to ebin
	move().

mc(FilePrefix) ->
	c(FilePrefix),
	move().

move() -> 
	FileList = filelib:wildcard("*.beam"),
	lists:foreach(fun(F) -> file:copy(F, "../ebin/" ++ F) end, FileList).
