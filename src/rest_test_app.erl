%%%-------------------------------------------------------------------
%% @doc rest_test public API
%% @end
%%%-------------------------------------------------------------------

-module(rest_test_app).
-behaviour(application).
-record(project, {
    username, app_id, u2f_device, challenge}).
%% API.
-export([start/2, install/0] ).
-export([stop/1]).


start(_Type, _Args) ->

    Dispatch = cowboy_router:compile([
        {'_', [
            {"/start_registration", start_registration, []}

        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}
    }),
    install(),
    rest_test_sup:start_link().

%%creates table called project
install() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(project,
        [{attributes, record_info(fields, project)}]).

stop(_State) ->
    ok = cowboy:stop_listener(http).