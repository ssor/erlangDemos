
%% application name
{application, gen_web_server,
 [{description, "The General Web Server"},
 {vsn,"0.1.1"},
 {modules,[dc_app,dc_sup]},
 {registered, [dc_sup]},
 {applications, [kernel, stdlib]},
 {mod,{dc_app,[]}}
 ]}.