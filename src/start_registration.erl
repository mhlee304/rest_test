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
-export([init/2, add_user/4]).

-export([
  allowed_methods/2,
  content_types_accepted/2, post_json/2
]).

-record(project, {user_id,
  username, u2f_enroll, u2f_device}). %, u2f_enroll, u2f_device , u2f_enroll

init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.

content_types_accepted(Req, State) ->
  {[
    {<<"application/json">>, post_json}
  ], Req, State}.

allowed_methods(Req, State) ->
  {[<<"GET">>, <<"POST">>], Req, State}.

post_json(Req, State) ->
  {ok, ReqBody, Req2} = cowboy_req:read_body(Req),
  Req_Body_decoded = jsx:decode(ReqBody, [return_maps]),
  User_ID_Binary = maps:get(<<"user_id">>, Req_Body_decoded),
  Username_Binary = maps:get(<<"username">>, Req_Body_decoded),
  U2F_Enroll_Binary = maps:get(<<"u2f_enroll">>, Req_Body_decoded),
  U2F_Device_Binary = maps:get(<<"u2f_device">>, Req_Body_decoded),
  User_ID = binary_to_list(User_ID_Binary),
  Username = binary_to_list(Username_Binary),
  U2F_Enroll = binary_to_list(U2F_Enroll_Binary),
 U2F_Device = binary_to_list(U2F_Device_Binary),
  add_user(User_ID, Username, U2F_Enroll, U2F_Device),% , , U2F_Device),, U2F_Enroll
  io:format("User_ID is ~p ~n", [User_ID]),
  io:format("Username is ~p ~n", [Username]),
  io:format("U2F_Enroll is ~p ~n", [U2F_Enroll]),
  io:format("U2F_Device is ~p ~n", [U2F_Device]),
  io:format("ReqBody is ~p~n~n", [ReqBody]),
  io:format("Req2 is ~p~n~n", [Req2]),
  io:format("Response is ~p~n~n", [Req_Body_decoded]),
  Req1 = cowboy_req:set_resp_body("Data sent to Mnesia Table!", Req), %send back json string
  {true, Req1, State}.

add_user(User_ID, Username, U2F_Enroll, U2F_Device) ->
  F = fun() ->
    mnesia:write(#project{user_id=User_ID,
      username=Username,
      u2f_enroll=U2F_Enroll,
      u2f_device = U2F_Device})
      end,
  mnesia:activity(transaction, F).







