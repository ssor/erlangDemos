%% Feel free to use, reuse and abuse the code in this file.

{application, cowboy_websocket, [
	{description, "Examples for cowboy."},
	{vsn, "0.1.0"},
	{modules, []},
	{registered, [cowboy_websocket_sup]},
	{applications, [
		kernel,
		stdlib,
		crypto,
		public_key,
		ssl,
		cowboy
	]},
	{mod, {cowboy_websocket, []}},
	{env, []}
]}.
