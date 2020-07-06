%%%-------------------------------------------------------------------
%% @doc rest_test public API
%% @end
%%%-------------------------------------------------------------------

-module(rest_test_app).
-behaviour(application).
-record(project, {user_id,
    username, u2f_enroll, u2f_device}).
%% API.
-export([start/2, install/0] ).
-export([stop/1]).


start(_Type, _Args) ->

    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", toppage_h, []},
            {"/start_registration", start_registration, []},
            {"/finish_registration", finish_registration, []},
            {"/start_login", start_login, []},
            {"/finish_login", finish_login, []},
            {"/enroll", enroll, []},
            {"/json_handler", json_handler, []}


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