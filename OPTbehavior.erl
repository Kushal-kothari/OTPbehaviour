% File: frequency.erl
%% Purpose gen_server call back module for the frequency
%% allocator
-module(Behaviours).
-export([start/0, stop/0, allocate/0, deallocate/1]).
-export([init/1, terminate/2, handle_cast/2, handle_call/3]).
%% The start and stop Functions
start() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop() ->
    gen_server:cast(?MODULE, stop).
%% The client Functions
allocate() ->
    gen_server:call(?MODULE, {allocate, self()}).
deallocate(Freq) ->
    gen_server:call(?MODULE, {deallocate, Freq}).
%% Callback functions
handle_call({allocate, Pid}, _From, Frequencies) ->
    {NewFrequencies, Reply} = allocate(Frequencies, Pid),
 {reply, Reply, NewFrequencies};
handle_call({deallocate, Freq}, _From, Frequencies) ->
    NewFrequencies=deallocate(Frequencies, Freq),
    {reply, ok, NewFrequencies}.
handle_cast(stop, Frequencies) ->
    {stop, normal, Frequencies}.
init(_Args) ->
    {ok, {get_frequencies(), []}}.
terminate(_Reason, _Frequencies) ->
     ok.
%% Local Functions
get_frequencies() -> [10,11,12,13,14,15].
allocate({[], Allocated}, _Pid) ->
    {{[], Allocated}, {error, no_frequencies}};
allocate({[Freq|Frequencies], Allocated}, Pid) ->
    {{Frequencies,[{Freq,Pid}|Allocated]},{ok,Freq}}.
deallocate({Free, Allocated}, Freq) ->
    {value,{Freq, _Pid}}= lists:keysearch(Freq,1,Allocated),
    NewAllocated=lists:keydelete(Freq,1,Allocated),
    {[Freq|Free], NewAllocated}.
