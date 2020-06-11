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

-export([
  allowed_methods/2,
  content_types_accepted/2, post_json/2
]).

-record(project, {call,
  response}).

content_types_accepted(Req, State) ->
  {[
    {<<"application/json">>, post_json}
  ], Req, State}.

allowed_methods(Req, State) ->
  {[<<"GET">>, <<"POST">>], Req, State}.

post_json(Req, State) ->
  {ok, ReqBody, Req2} = cowboy_req:read_body(Req),
  Req_Body_decoded = jsx:decode(ReqBody, [return_maps]),
  Call_Binary = maps:get(<<"call">>, Req_Body_decoded),
  Response_Binary = maps:get(<<"response">>, Req_Body_decoded),
  Call = binary_to_list(Call_Binary),
  Response = binary_to_list(Response_Binary),
  add_username(Call, Response),
  io:format("Call is ~p ~n", [Call]),
  io:format("Response is ~p ~n", [Response]),
  io:format("ReqBody is ~p~n~n", [ReqBody]),
  io:format("Req2 is ~p~n~n", [Req2]),
  io:format("Response is ~p~n~n", [Req_Body_decoded]),
  {true, Req, State}.

%%Adds username with response into database
add_username(Call, Response) ->
  F = fun() ->
    mnesia:write(#project{call=Call,
      response=Response
    })
      end,
  mnesia:activity(transaction, F).

init(Req, Opts) ->

  {cowboy_rest, Req, Opts}.

  %io:format("The start registration started and added username Matthew"),
  %{ok, Req, Opts}.




