{application,tcp_interface,
	[
		{discription,"A TCP Inferface System"},
		{vsn,"1.0"},
		{modules,[
					ti_app,
					ti_sup,
					ti_server
				 ]
		},
		{registered,[ti_sup]},
		{applications,[kernel,stdlib]},
		{mod,{ti_app,[]}}
	]
}.