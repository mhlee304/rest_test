%%%-------------------------------------------------------------------
%%% @author matthewlee
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Jun 2020 3:20 PM
%%%-------------------------------------------------------------------
-module(json_handler).
-author("matthewlee").
-export([init/2]).

-export([
  allowed_methods/2,
  content_types_accepted/2,
  content_types_provided/2
]).

-export([get_json/2, post_json/2]).

init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
  {[<<"GET">>, <<"POST">>], Req, State}.

%Get
content_types_provided(Req, State) ->
  {[
    {<<"get/json">>, get_json}
  ], Req, State}.

get_json(Req, State) ->
  {<<"{ \"hello\": \"there\" }">>, Req, State}.


%Post
content_types_accepted(Req, State) ->
  {[
    {<<"application/json">>, post_json}
  ], Req, State}.

post_json(Req, State) ->
  {ok, ReqBody, Req2} = cowboy_req:read_body(Req),
  Req_Body_decoded = jsx:decode(ReqBody, [return_maps]),
  Call_Binary = maps:get(<<"call">>, Req_Body_decoded),
  Response_Binary = maps:get(<<"response">>, Req_Body_decoded),
  Call = binary_to_list(Call_Binary),
  Response = binary_to_list(Response_Binary),
  io:format("Call is ~p ~n", [Call]),
  io:format("Response is ~p ~n", [Response]),
  io:format("ReqBody is ~p~n~n", [ReqBody]),
  io:format("Req2 is ~p~n~n", [Req2]),
  io:format("Response is ~p~n~n", [Req_Body_decoded]),
  {true, Req, State}.

