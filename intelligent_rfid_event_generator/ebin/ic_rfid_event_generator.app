
%% application name
{application, ic_rfid_event_generator,
 [{description, "Intelligent Carbinet RFID Event Generator"},
 {vsn,"0.1.0"},
 {modules,[icreg_app,icreg_sup]},
 {registered, [icreg_sup]},
 {applications, [kernel, stdlib]},
 {mod,{icreg_app,[]}}
 ]}.