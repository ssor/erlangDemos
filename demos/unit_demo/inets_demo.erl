-module(inets_demo).
-export([start/0]).

start() ->
	{ok,{{Version,200,ReasonPhrase},Headers,Body}} = 
		 httpc:request(post,{"http://192.168.1.100:9002/index.php/Inventory/Inventory/getProduct",[],[],
		 	"{\"productID\":\"15\",\"productName\":\"\",\"produceDate\":\"2012-03-28 08:22:21\",\"productCategory\":\"\",\"descript\":\"\",\"state\":null}"}
		 	,[],[]),
	io:format(Body).