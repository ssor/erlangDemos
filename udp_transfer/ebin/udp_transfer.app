
%% application name
{application, udp_transfer,
 [{description, "A UDP Data Transfer"},
 {vsn,"0.1.0"},
 {modules,[ut_app,ut_sup]},
 {registered, [ut_sup]},
 {applications, [kernel, stdlib]},
 {mod,{ut_app,[]}}
 ]}.