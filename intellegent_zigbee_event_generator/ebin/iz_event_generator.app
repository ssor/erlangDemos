
%% application name
{application, iz_event_generator,
 [{description, "Intelligent Zigbee Event Generator"},
 {vsn,"0.1.0"},
 {modules,[izeg_app,izeg_sup]},
 {registered, [izeg_sup]},
 {applications, [kernel, stdlib]},
 {mod,{izeg_app,[]}}
 ]}.