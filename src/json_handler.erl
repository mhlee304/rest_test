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
  %{true, Req, State}.
  {ok, ReqBody, Req2} = cowboy_req:body(Req),
  Req_Body_decoded = jsx:decode(ReqBody),
  [{<<"call">>,Call},{<<"response">>,Response}] = Req_Body_decoded,
  Call1 = binary_to_list(Call),
  Response1 = binary_to_list(Response),
  io:format("Call1 is ~p ~n ", [Call1]),
  io:format("Response1 is ~p ~n", [Response1]),
  io:format("Call is ~p ~n", [Call]),
  io:format("Response is ~p ~n", [Response]),
 Res1 = cowboy_req:set_resp_body(ReqBody, Req2),
 Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
 Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
  {true, Res3, State}.
