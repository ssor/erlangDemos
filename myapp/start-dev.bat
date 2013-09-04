@echo off
set MOCHIWEB_IP=127.0.0.1
start C:\Program Files\erl5.8.5\bin\werl.exe +A 16 -pa C:\program\erlang\myapp\ebin C:\program\erlang\myapp\deps\mochiweb-src\ebin -boot start_sasl -s reloader -s myapp