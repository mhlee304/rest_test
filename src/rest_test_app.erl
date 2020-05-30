%%%-------------------------------------------------------------------
%% @doc rest_test public API
%% @end
%%%-------------------------------------------------------------------

-module(rest_test_app).
-behaviour(application).

-record(project, {call,
    response}).


%% API.
-export([start/2, install/0, add_username/2, fetch_response/1] ).
-export([stop/1]).


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

%%creates table called project
install() ->
    mnesia:create_schema([node()]),
    mnesia:start(),

    mnesia:create_table(project,
        [{attributes, record_info(fields, project)}]).

%%Adds username with response into database
add_username(Call, Response) ->
    F = fun() ->
        mnesia:write(#project{call=Call,
            response=Response
            })
        end,
    mnesia:activity(transaction, F).

%%Finds reponse associated with call
fetch_response(Call) ->
    Pattern = #project{_ = '_',
        call = Call},
    F = fun() ->
        Res = mnesia:match_object(Pattern),
        [{Call,R} ||
            #project{call=Call,
                response=R
                } <- Res]
        end,
    mnesia:activity(transaction, F).

stop(_State) ->
    ok = cowboy:stop_listener(http).