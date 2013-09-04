
%% application name
{application, rfid_event_generator,
 [{description, "RFID Event Generator"},
 {vsn,"0.1.0"},
 {modules,[reg_app,reg_sup]},
 {registered, [reg_sup]},
 {applications, [kernel, stdlib]},
 {mod,{reg_app,[]}}
 ]}.