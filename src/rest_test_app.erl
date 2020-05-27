%%%-------------------------------------------------------------------
%% @doc rest_test public API
%% @end
%%%-------------------------------------------------------------------

-module(rest_test_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", toppage_h, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}
    }),
    rest_test_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).