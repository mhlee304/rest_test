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
-export([init/2]).

-export([
  allowed_methods/2,
  content_types_accepted/2, post_json/2, is_username_in_table/1,
  add_user_skeleton/1, convert_to_json/1,
  hello_to_json/2, echo/1, handle/2

]).



-record(project, {username, app_id, u2f_device, challenge}). %, u2f_enroll, u2f_device , u2f_enroll

%has to contain cowboy_rest
init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.

handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  case Method of
    <<"POST">> ->
      Body = <<"<h1>This is a response for POST</h1>">>;
    <<"GET">> ->
      Body = <<"<h1>This is a response for GET</h1>">>;
    _ ->
      Body = <<"<h1>This is a response for other methods</h1>">>
  end,
  {ok, Req3} = cowboy_req:reply(200, [], Body, Req2),
  {ok, Req3, State}.

echo(Req) ->
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"text/plain; charset=utf-8">>
  },  <<"Hello world!">>, Req).


content_types_accepted(Req, State) ->
  {[
    {<<"application/json">>, post_json}
  ], Req, State}.

allowed_methods(Req, State) ->
  {[<<"GET">>, <<"POST">>], Req, State}.

hello_to_json(Req, State) ->
  Body = <<"{\"rest\": \"Hello World!\"}">>,
  {Body, Req, State}.

post_json(Req, State) ->
  {ok, ReqBody, Req2} = cowboy_req:read_body(Req),
  Req_Body_decoded = jsx:decode(ReqBody, [return_maps]),
  Username_Binary = maps:get(<<"username">>, Req_Body_decoded),
  Username = binary_to_list(Username_Binary),
  is_username_in_table(Username),
  create_challenge(Username),
  User_Data_Json = convert_to_json(Username),
  io:format("Username is ~p ~n", [Username]),
  io:format("ReqBody is ~p~n~n", [ReqBody]),
  io:format("Req2 is ~p~n~n", [Req2]),
  io:format("Response is ~p~n~n", [Req_Body_decoded]),
  io:format("User Data in Json is ~p~n~n", [User_Data_Json]),
  case cowboy_req:method(Req2) of
    <<"POST">> ->
      {{true, User_Data_Json}, Req2, State};
    _ ->
      {true, Req2, State}
  end.



%check if user is in table, if yes -> return true;
% if not, add user into database with no values for enroll and device
is_username_in_table(Username) ->
  case mnesia:dirty_read({project, Username}) of
    [] -> add_user_skeleton(Username);
    _ -> true
  end.

%if user is not in mnesia, add a user into the table with empty values for enroll and device
add_user_skeleton(Username) ->
  App_ID = "App_ID123",
  U2F_Device = "U2F_device123",
  F = fun() ->
    mnesia:write(#project{username=Username,
      app_id = App_ID,
      u2f_device = U2F_Device})
      end,
  mnesia:activity(transaction, F).

create_challenge(Username) ->

  Challenge = base64:encode(crypto:strong_rand_bytes(32)),
  Update = fun() ->
    [P] = mnesia:wread({project, Username}),
    mnesia:write(P#project{challenge =  Challenge})
           end,
  mnesia:transaction(Update).

%fetches response and converts it to json
convert_to_json(Username) ->
  A = mnesia:dirty_read({project, Username}),
  [{_, _, X, _, _}] = A,
  [{_, _, _, Y, _}] = A,
  [{_, _, _, _, Z}] = A,
  Project = [
    #project{username = Username, app_id = X, u2f_device = Y, challenge = Z}
  ],
  JSON = jsx:encode(lists:map(fun project_to_json_encodable/1, Project)),
  JSON.

%erlang to json
project_to_json_encodable(#project{username=Username, app_id = App_ID, u2f_device=U2F_Device, challenge=Challenge}) ->
  [{username, list_to_binary(Username)}, {app_id, list_to_binary(App_ID)},
    {u2f_device, list_to_binary(U2F_Device)}, {challenge, Challenge}].







