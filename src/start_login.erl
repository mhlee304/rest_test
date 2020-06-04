%%%-------------------------------------------------------------------
%%% @author matthewlee
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Jun 2020 5:33 PM
%%%-------------------------------------------------------------------
-module(start_login).
-author("matthewlee").
-behaviour(gen_event).
-export([init/2]).

init(Req0, Opts) ->
  Req = cowboy_req:reply(200, #{
    <<"content-type">> => <<"text/plain">>
  }, <<"This is gonna be the start login">>, Req0),
  {ok, Req, Opts}.

