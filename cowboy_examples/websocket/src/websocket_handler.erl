%% Feel free to use, reuse and abuse the code in this file.

-module(websocket_handler).
-behaviour(cowboy_http_handler).
-behaviour(cowboy_http_websocket_handler).
-export([init/3, handle/2, terminate/2]).
-export([websocket_init/3, websocket_handle/3,
	websocket_info/3, websocket_terminate/3]).

init({_Any, http}, Req, []) ->
	case cowboy_http_req:header('Upgrade', Req) of
		{undefined, Req2} -> {ok, Req2, undefined};
		{<<"websocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket};
		{<<"WebSocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket}
	end.

handle(Req, State) ->
	{ok, Req2} = cowboy_http_req:reply(200, [{'Content-Type', <<"text/html">>}],
%% HTML code taken from misultin's example file.
<<"<html>
<head>
<script type=\"text/javascript\">
function addStatus(text){
	var date = new Date();
	document.getElementById('status').innerHTML
		= document.getElementById('status').innerHTML
		+ date + \": \" + text + \"<br/>\";
}
function ready(){
	if (\"MozWebSocket\" in window) {
		WebSocket = MozWebSocket;
	}
	if (\"WebSocket\" in window) {
		// browser supports websockets
		var ws = new WebSocket(\"ws://localhost:8080/websocket\");
		ws.onopen = function() {
			// websocket is connected
			addStatus(\"websocket connected!\");
			// send hello data to server.
			ws.send(\"hello server!\");
			addStatus(\"sent message to server: 'hello server'!\");
		};
		ws.onmessage = function (evt) {
			var receivedMsg = evt.data;
			addStatus(\"server sent the following: '\" + receivedMsg + \"'\");
		};
		ws.onclose = function() {
			// websocket was closed
			addStatus(\"websocket was closed\");
		};
	} else {
		// browser does not support websockets
		addStatus(\"sorry, your browser does not support websockets.\");
	}
}
</script>
</head>
<body onload=\"ready();\">
Hi!
<div id=\"status\"></div>
</body>
</html>">>, Req),
	{ok, Req2, State}.

terminate(_Req, _State) ->
	ok.

websocket_init(_Any, Req, []) ->
	timer:send_interval(1000, tick),
	Req2 = cowboy_http_req:compact(Req),
	{ok, Req2, undefined, hibernate}.

websocket_handle({text, Msg}, Req, State) ->
	{reply, {text, << "You said: ", Msg/binary >>}, Req, State, hibernate};
websocket_handle(_Any, Req, State) ->
	{ok, Req, State}.

websocket_info(tick, Req, State) ->
	{reply, {text, <<"Tick">>}, Req, State, hibernate};
websocket_info(_Info, Req, State) ->
	{ok, Req, State, hibernate}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.
