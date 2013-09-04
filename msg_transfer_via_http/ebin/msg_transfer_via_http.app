%% Feel free to use, reuse and abuse the code in this file.

{application, msg_transfer_via_http, [
	{description, "A Message Transfer Via HTTP"},
	{vsn, "1"},
	{modules, []},
	{registered, []},
	{applications, [
		kernel,
		stdlib,
		cowboy
	]},
	{mod, {msg_transfer_via_http_app, []}},
	{env, []}
]}.
