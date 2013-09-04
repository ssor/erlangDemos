%% -*- erlang -*-
{application, myapp,
 [{description, "myapp"},
  {vsn, "1.0"},
  {modules, []},
  {registered, []},
  %%{mod, {'myapp_app', []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
