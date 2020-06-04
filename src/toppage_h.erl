%%%-------------------------------------------------------------------
%%% @author matthewlee
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. May 2020 8:51 AM
%%%-------------------------------------------------------------------
-module(toppage_h).
-author("matthewlee").
-export([init/2]).
-export([content_types_provided/2]).
-export([start_registration/2]).
-export([end_registration/2]).
-export([start_authentication/2]).
-export([end_authentication/2]).


init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
  {[
    {<<"start_registration/json">>, start_registration},
    {<<"end_registration/json">>, end_registration},
    {<<"start_authentication/json">>, start_authentication},
    {<<"end_authentication/json">>, end_authentication}
  ], Req, State}.


start_registration(Req, State) ->
  Body = <<"{\"rest\": \"I think the Registration Started!\"}">>,
  {Body, Req, State},
  {ok, Username} = io:read("Enter username: "),
  io:format("The username you entered is: ~w~n", [Username]).


end_registration(Req, State) ->
  {Req, State}.


start_authentication(Req, State) ->
  Body = <<"{\"rest\": \"I think the Authentication Started!\"}">>,
  {Body, Req, State}.
  %%hello_world(),


end_authentication(Req, State) ->
  Body = <<"{\"rest\": \"I think the Authentication Ended!\"}">>,
  {Body, Req, State}.