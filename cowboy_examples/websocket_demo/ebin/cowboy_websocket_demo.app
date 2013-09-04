%% Feel free to use, reuse and abuse the code in this file.

{application, cowboy_websocket_demo, [
	{description, "Examples for cowboy websocket."},
	{vsn, "0.1.0"},
	{modules, []},
	{registered, [cowboy_websocket_demo_sup]},
	{applications, [
		kernel,
		stdlib,
		crypto,
		public_key,
		ssl,
		cowboy
	]},
	{mod, {cowboy_websocket_demo, []}},
	{env, []}
]}.
