-module(lib_primes).
-export([make_prime/1,make_prime/2]).

make_prime(1)->
	lists:nth(random:uniform(5),[1,2,3,5,7]);
make_prime(K) when K>0 ->
	new_seed(),
	N = make_random_int(K),
	if N >3 ->
		io:format("Generating a ~w digit prime ",[K]),
		MaxTries = N -3,
		P1 = make_prime(MaxTries,N+1),
		io:format("~n",[]),
		P1;
	true ->
		make_prime(K)
	end.

make_prime(0,_)->
	exit(impossible);
make_prime(K,P)->
	io:format(".",[]),
	case is_prime(P) of
         true -> P;
         false -> make_prime(K-1,P+1)
	end.

is_prime(D)->
	new_seed(),
	is_prime(D,100).

is_prime(D,Ntests)->
	N = length(integer_to_list(D)) -1,
	is_prime(Ntests,D,N).

is_prime(0,_,_)-> true;
is_prime(Ntests,N,Len)->
	K = random:uniform(Len),
	A = make_random_int(K),
	if
		A < N ->
			case lib_lin:pow(A,N,N) of
				A -> is_prime(Ntests-1,N,Len);
				_ -> false
			end;
		true ->
		    is_prime(Ntests,N,Len)

	end.


