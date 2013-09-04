{application,sellarea,
	[{description,"The Area Shop"},
	 {vsn,"1.0"},
	 {modules,[sellarea_app,sellarea_supervisor,area_server]},
	 {registered,[area_server,sellaprime_super]},
	 {applications,[kernel,stdlib]},
	 {mod,{sellarea_app,[]}},
	 {start_phases,[]}
	]
}.