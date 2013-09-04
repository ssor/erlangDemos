-module(lib_misc).
-export([qsort/1,start_exit_test/0]).


% 启动测试监视进程的测试
start_exit_test() ->
	Pid = create_a_exit_thread(),
	io:format("start_exit_test pid = ~p~n",[Pid]),
	on_exit(Pid,fun output_exit/1),
	Pid ! hello.


%启动一个可能出错的进程
create_a_exit_thread() ->
		spawn(fun a_exit_fun/0).

% 可能出错的函数
a_exit_fun() ->
	receive
		X ->
		 io:format("a_exit_fun receive = ~p~n",[X]),
		 list_to_atom(X)
	end.

%进程崩溃时的回调函数
output_exit(Why) ->
	io:format(" died with : ~p~n",[Why]).

%启动一个监视进程
on_exit(Pid,Fun) ->
	spawn(fun() -> 
			process_flag(trap_exit,true),
			link(Pid),%监视这个进程
			receive 
				{'EXIT',Pid,Why} ->
					Fun(Why)
			end
		  end).

%快速排序
qsort([]) -> [];
qsort([Pivot|T]) ->
		qsort([X||X <- T,X<Pivot])
		++ [Pivot] ++
		qsort([X || X <- T,X >= Pivot]).
