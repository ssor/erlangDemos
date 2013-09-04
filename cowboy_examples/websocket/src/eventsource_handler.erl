%% Feel free to use, reuse and abuse the code in this file.

-module(eventsource_handler).
-behaviour(cowboy_http_handler).
-export([init/3, handle/2, terminate/2]).

init({_Any, http}, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
	{ok, Req2} = cowboy_http_req:reply(200, [{'Content-Type', <<"text/html">>}],
<<"<!DOCTYPE html>
<html>
	<head>
		<script type=\"text/javascript\">
			function ready() {
				if (!!window.EventSource) {
					setupEventSource();
				} else {
					document.getElementById('status').innerHTML =
						\"Sorry but your browser doesn't support the EventSource API\";
				}
			}

			function setupEventSource() {
				var source = new EventSource('/eventsource/live');

				source.addEventListener('message', function(event) {
					addStatus(\"server sent the following: '\" + event.data + \"'\");
				}, false);

				source.addEventListener('open', function(event) {
					addStatus('eventsource connected.')
				}, false);

				source.addEventListener('error', function(event) {
					if (event.eventPhase == EventSource.CLOSED) {
						addStatus('eventsource was closed.')
					}
				}, false);
			}

			function addStatus(text) {
					var date = new Date();
					document.getElementById('status').innerHTML
									= document.getElementById('status').innerHTML
									+ date + \": \" + text + \"<br/>\";
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
