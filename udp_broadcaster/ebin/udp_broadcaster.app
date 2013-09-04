%% Feel free to use, reuse and abuse the code in this file.

{application, udp_broadcaster, [
	{description, "udp Broadcaster"},
	{vsn, "1"},
	{modules, []},
	{registered, []},
	{applications, [
		kernel,
		stdlib
	]},
	{mod, {udp_broadcaster_app, []}},
	{env, []}
]}.
