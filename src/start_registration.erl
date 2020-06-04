%%%-------------------------------------------------------------------
%%% @author matthewlee
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Jun 2020 1:36 PM
%%%-------------------------------------------------------------------
-module(start_registration).
-author("matthewlee").
-behaviour(gen_event).
-export([init/2, add_username/2]).
-record(project, {call,
  response}).

%%Adds username with response into database
add_username(Call, Response) ->
  F = fun() ->
    mnesia:write(#project{call=Call,
      response=Response
    })
      end,
  mnesia:activity(transaction, F).

init(Req, Opts) ->
  add_username("Matthew", "Does this work?"),
  io:format("The start registration started and added username Matthew"),
  {ok, Req, Opts}.




