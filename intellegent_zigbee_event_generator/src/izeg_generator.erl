%gen_server template
-module(izeg_generator).
-behaviour(gen_server).

-export([send_data/2, 
		 start_link/1]).

-export([get_border_config/2, set_border_config/3]).

-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		 terminate/2,code_change/3]).
-record(state,{huminity_min, huminity_max, temperature_max, temperature_min, 
				last_huminity = infinity, last_temperature = infinity, address, node_id, port}).
% -record(zigbeeInfo,{address, node_id, huminity, temperature}).
-define(DEFAULT_LEASE_TIME, 10).
-define(DEFAULT_HUMINITY_MIN, 50).
-define(DEFAULT_HUMINITY_MAX, 90).
-define(DEFAULT_TEMPERATURE_MAX, 40).
-define(DEFAULT_TEMPERATURE_MIN, 20).
%%%%======================================================================

start_link({Port, Address}) ->
	gen_server:start_link(?MODULE, [{Port, Address}], []).

send_data(Pid, Data) ->
	gen_server:call(Pid, {send_data, Data}).

get_border_config(Pid, Config) ->
	gen_server:call(Pid, Config).

set_border_config(Pid, Config, Value) ->
	gen_server:cast(Pid, {Config, Value}).

%%%%======================================================================

init([{Port, Address}]) ->
	% io:format("Port ~p is initialized~n",[UdpPort]),
	process_flag(trap_exit, true),

	Config = idc:izeg_config(),

	HuminityMin = case lists:keyfind(default_huminity_min, 1, Config) of
					false -> ?DEFAULT_HUMINITY_MIN;
					{default_huminity_min, Hum1} -> 
						Hum1
				end,
	HuminityMax = case lists:keyfind(default_huminity_max, 1, Config) of
					false -> ?DEFAULT_HUMINITY_MAX;
					{default_huminity_max, Hum2} -> 
						Hum2
				end,
	TemperatureMax = case lists:keyfind(default_temperature_max, 1, Config) of
					false -> ?DEFAULT_TEMPERATURE_MAX;
					{default_temperature_max, Tem1} -> 
						Tem1
				end,
	TemperatureMin = case lists:keyfind(default_temperature_min, 1, Config) of
					false -> ?DEFAULT_TEMPERATURE_MIN;
					{default_temperature_min, Tem2} -> 
						Tem2
				end,
	{ok,#state{address = Address, 
				huminity_min = HuminityMin, 
				huminity_max = HuminityMax,
				temperature_max = TemperatureMax,  
				temperature_min = TemperatureMin,
				port = Port}, 1}.

handle_call({send_data, {Address_in, NodeID_in, Huminity_in, Temp_in}}, _From,
	 #state{address = Address, last_huminity = Huminity, last_temperature = Temp, 
	 		huminity_min = HuminityMin, huminity_max = HuminityMax,
	 		temperature_max = TemperatureMax, temperature_min = TemperatureMin, 
	 		port = Port
	 		} = State) ->
	% io:format("last_huminity -> ~p, last_temperature -> ~p~n", [Huminity, Temp]),
	if 
		Huminity == infinity -> void;
		Huminity_in ==  Huminity ->
			void;
		Huminity_in >  Huminity ->
			izeg_event:humidity_higher(Port, {Address_in, NodeID_in, Huminity_in});
		Huminity_in <  Huminity ->
			izeg_event:humidity_lower(Port, {Address_in, NodeID_in, Huminity_in})
	end,
	if 
		Huminity_in > HuminityMax ->
			izeg_event:humidity_too_high(Port, {Address_in, NodeID_in, Huminity_in});
		Huminity_in < HuminityMin ->
			izeg_event:humidity_too_low(Port, {Address_in, NodeID_in, Huminity_in});
		true -> void
	end,
	if 
		Temp == infinity -> void;
		Temp_in == Temp ->
			void;
		Temp_in > Temp ->
			izeg_event:temperature_higher(Port, {Address_in, NodeID_in, Temp_in});
		Temp_in < Temp ->
			izeg_event:temperature_lower(Port, {Address_in, NodeID_in, Temp_in})
	end,
	if 
		Temp_in > TemperatureMax ->
			izeg_event:temperature_too_high(Port, {Address_in, NodeID_in, Temp_in});
		Temp_in < TemperatureMin ->
			izeg_event:temperature_too_low(Port, {Address_in, NodeID_in, Temp_in});
		true -> void
	end,

	Reply = ok,
	{reply, Reply, 
		State#state{last_huminity = Huminity_in, last_temperature = Temp_in, node_id = NodeID_in, address = Address_in}
		, 1000 * ?DEFAULT_LEASE_TIME};
handle_call(get_huminity_min, _From, #state{huminity_min = HuminityMin} = State) ->
	Reply = HuminityMin,
	{reply,Reply,State, 1};
handle_call(get_huminity_max, _From, #state{huminity_max = HuminityMax} = State) ->
	Reply = HuminityMax,
	{reply,Reply,State, 1};
handle_call(get_temperature_max, _From, #state{temperature_max = TemperatureMax} = State) ->
	Reply = TemperatureMax,
	{reply,Reply,State, 1};
handle_call(get_temperature_min, _From, #state{temperature_min = TemperatureMin} = State) ->
	Reply = TemperatureMin,
	{reply,Reply,State, 1};			
handle_call(_Request,_From,State) ->
	Reply = ok,
	{reply,Reply,State, 1000 * ?DEFAULT_LEASE_TIME}.

handle_cast({set_huminity_min, Value}, State) ->
	{noreply, State#state{huminity_min = Value}};
handle_cast({set_huminity_max, Value}, State) ->
	{noreply, State#state{huminity_max = Value}};
handle_cast({set_temperature_min, Value}, State) ->
	{noreply, State#state{temperature_min = Value}};
handle_cast({set_temperature_max, Value}, State) ->
	{noreply, State#state{temperature_max = Value}};
handle_cast(_Msg,State) ->
	{noreply,State}.

handle_info(timeout,
			 #state{last_temperature = LastTemperature,
			 		  last_huminity = LastHuminity,
			 		   node_id = NodeID,
			 		    address = Address} = State) ->
	case 
		LastHuminity /= infinity of
		true  -> izeg_event:interval_huminity_notify(Address, {Address, NodeID, LastHuminity});
		false -> void
	end,
	case 
		LastTemperature /= infinity of
		true  -> izeg_event:interval_temperature_notify(Address, {Address, NodeID, LastTemperature});
		false -> void
	end,	
	% {noreply, State};
	{noreply, State, 1000 * ?DEFAULT_LEASE_TIME};
handle_info(_Request, State) ->
	{noreply, State}.


terminate(_Reason, State) ->
	Address = State#state.address,
	io:format("Address ~p terminate here ~n",[Address]),
	ok.

code_change(_OldVsn,State,_Extra) ->
	{ok,State}.

%%%%=======================================================================

