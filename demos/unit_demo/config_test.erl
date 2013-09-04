%config_test.erl

-module(config_test).
-compile(export_all).

load_config(ConfigFile) ->
	{ok,ConfigList} = file:consult(ConfigFile),
	ConfigList.