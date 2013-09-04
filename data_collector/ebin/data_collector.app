
%% application name
{application, data_collector,
 [{description, "The Data Collector System"},
 {vsn,"0.1.1"},
 {modules,[dc_app,dc_sup]},
 {registered, [dc_sup]},
 {applications, [kernel, stdlib]},
 {mod,{dc_app,[]}}
 ]}.