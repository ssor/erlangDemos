
%% application name
{application, zigbee_event_generator,
 [{description, "Zigbee Event Generator"},
 {vsn,"0.1.0"},
 {modules,[zeg_app,zeg_sup]},
 {registered, [zeg_sup]},
 {applications, [kernel, stdlib]},
 {mod,{zeg_app,[]}}
 ]}.