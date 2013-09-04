% Interfaces for Modules
-module(idc).

-export([dc_config/0, reg_config/0, mt_config/0, icreg_config/0
		, zeg_config/0, ut_config/0, izeg_config/0, broadcast_config/0]).
-export([test/0]).

zeg_config() ->
	get_specified_config(zeg_config).

izeg_config() ->
	get_specified_config(izeg_config).

icreg_config() ->
	get_specified_config(icreg_config).

reg_config() -> 
	% io:format("reg_config ->~n"),
	get_specified_config(reg_config).

mt_config() ->
	get_specified_config(mt_config).

dc_config() ->
	get_specified_config(dc_config).
ut_config() ->
	get_specified_config(ut_config).
broadcast_config() ->
	get_specified_config(broadcast_config).

get_specified_config(Flag) ->
	case file:consult("../../config.dat") of 
		{error, enoent} ->
			io:format("config file does not exist~n"),
			void;
		{ok, Config} ->
			loop_config(Flag, Config)
	end.

loop_config(_Flag, []) -> void;
loop_config(Flag, [FirstConfig|T]) ->
	{Term1, Config} = FirstConfig,
	case Term1 == Flag of
		true  -> Config;
		false -> 
			loop_config(Flag, T)
	end.


test() ->
	Config = reg_config(),
	Finded = lists:keyfind(sensor_port_filter, 1, Config),
	io:format("Finded -> ~p~n", [Finded]).
