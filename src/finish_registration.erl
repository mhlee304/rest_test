%%%-------------------------------------------------------------------
%%% @author matthewlee
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Jun 2020 5:33 PM
%%%-------------------------------------------------------------------
-module(finish_registration).
-author("matthewlee").
-behaviour(gen_event).
-export([init/2, fetch_response/1]).
-record(project, {call,
  response}).

%%Finds response associated with call
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


init(Req, Opts) ->
  io:format("Fetched string associated with Matt"),
  fetch_response("Matthew"),
  {ok, Req , Opts}.