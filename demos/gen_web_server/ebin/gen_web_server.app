{application,gen_web_server,
	[
		{discription,"A Web Sever"},
		{vsn,"1.0"},
		{modules,[
					gen_web_server,
					gws_connection_sup.erl,
					gws_server.erl
				 ]
		},
		{registered,[gws_connection_sup]},
		{applications,[kernel,stdlib]},
		{mod,{gws_connection_sup,[]}}
	]
}.