
%% application name
{application, msg_transfer,
 [{description, "A Message Transfer Via UDP"},
 {vsn,"0.1.0"},
 {modules,[mt_app,mt_sup]},
 {registered, [mt_sup]},
 {applications, [kernel, stdlib]},
 {mod,{mt_app,[]}}
 ]}.