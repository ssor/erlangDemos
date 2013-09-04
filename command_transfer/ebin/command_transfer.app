%% Feel free to use, reuse and abuse the code in this file.

{application, command_transfer, [
	{description, "Command Transfer"},
	{vsn, "1"},
	{modules, []},
	{registered, []},
	{applications, [
		kernel,
		stdlib,
		cowboy
	]},
	{mod, {command_transfer_app, []}},
	{env, []}
]}.
