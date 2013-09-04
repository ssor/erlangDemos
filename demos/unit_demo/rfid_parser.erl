%rfid_parser.erl

-module(rfid_parser).
-compile(export_all).

parse_data() ->
	Data = "Disc:2002/02/29 03:30:47, Last:2000/02/29 03:31:09, Count:00008, Ant:02, Type:04, Tag:3005FB63AC1F3841EC88017",
	% Data = "Disc:2002/02/29 03:30:47, Last:2000/02/29 03:31:09, Count:00008, Ant:02, Type:04, Tag:3005FB63AC1F3841EC880172",
	DiscIndex = string:str(Data,"Disc"),
	% TagIndex = string:str(Data,"Tag"),
	if
		(DiscIndex > 0) and (length(Data) >= 110) ->
			
		Tokens = string:tokens(Data,","),
		if  length(Tokens) > 5 ->
				Items = lists:map(fun parse_item/1,Tokens),
				io:format("length of Tokens is ~p~n",[length(Items)]),
				% Items;
				[{'Disc',Disc},{'Last',Last},{'Count',Count},{'Ant',Ant},{'Type',Type},{'Tag',Tag}] =
					Items,
				io:format("Disc is ~p Count is ~p, Ant is ~p , Tag is ~p~n",[Disc,Count,Ant,Tag]);
			length(Tokens) =< 5 ->
				io:format("parsed data is error")
		end;
		(DiscIndex =< 0) or (length(Data) < 110)   ->
			io:format("input data is not comprehensive~n")
	end.
	
parse_item(Item) ->
	Index_of_separator = string:str(Item,":"),
	Key =string:strip(string:substr(Item,1,Index_of_separator-1)),
	Value = string:substr(Item,Index_of_separator+1),
	KeyAtom = list_to_atom(Key),
	{KeyAtom,Value}.
	