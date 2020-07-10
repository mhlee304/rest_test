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
-export([init/2,  allowed_methods/2, is_username_in_table/1, add_user_skeleton/1]).
-export([go/1,project_to_json_encodable/1, update_challenge/1]). % fetch_response/1,update_u2f_enroll/1]). add_challenge_to_table/0
-record(project, {username, app_id, u2f_device, challenge}).


allowed_methods(Req, State) ->
  {[<<"GET">>, <<"POST">>], Req, State}.
init(Req, Opts) ->
  Method = cowboy_req:method(Req),
  #{echo := Echo} = cowboy_req:match_qs([{echo, [], undefined}], Req),
  Req1 = echo(Method, Echo, Req),
  {cowboy_rest, Req1, Opts}.


echo(<<"GET">>, undefined, Req) ->
  cowboy_req:reply(400, #{}, <<"Missing echo parameter.">>, Req);
echo(<<"GET">>, Echo, Req) ->
  %%change erlang term to string to pass into go
  Input= io_lib:format("~p",[Echo]), J = lists:flatten(Input), Username = lists:sublist(J, 4, length(J) - 6),
  is_username_in_table(Username),
  %add_challenge_to_table(),
  update_challenge(Username),
  E = go(Username),
  io:format("Challenge created!"),
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"text/plain; charset=utf-8">>
  }, E, Req);
echo(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

%%Finds response associated with call
%fetch_response(Username) ->
%  Pattern = #project{_ = '_',
%    username = Username},
 % F = fun() ->
 %   Res = mnesia:match_object(Pattern),
 %   [{Username,U2F_Enroll, U2F_Device} ||
 %     #project{username=Username,
 %       u2f_enroll=U2F_Enroll,
 %       u2f_device=U2F_Device
 %     } <- Res]
 %     end,
  %mnesia:activity(transaction, F).

%erlang to json
project_to_json_encodable(#project{username=Username, app_id = App_ID, u2f_device=U2F_Device, challenge=Challenge}) ->
  [{username, list_to_binary(Username)}, {app_id, list_to_binary(App_ID)},
    {u2f_device, list_to_binary(U2F_Device)}, {challenge, Challenge}].

%fetches response and converts it to json
go(Username) ->
  A = mnesia:dirty_read({project, Username}),
  [{_, _, X, _, _}] = A,
  [{_, _, _, Y, _}] = A,
  [{_, _, _, _, Z}] = A,
  Project = [
    #project{username = Username, app_id = X, u2f_device = Y, challenge = Z}
  ],
  JSON = jsx:encode(lists:map(fun project_to_json_encodable/1, Project)),
  JSON.

%check if user is in table, if yes -> return true;
% if not, add user into database with no values for enroll and device
is_username_in_table(Username) ->
  case mnesia:dirty_read({project, Username}) of
    [] -> add_user_skeleton(Username);
    _ -> true
  end.

%if user is not in mnesia, add a user into the table with empty values for enroll and device
add_user_skeleton(Username) ->
  App_ID = "App_ID",
  U2F_Device = "U2F_device123",
  F = fun() ->
    mnesia:write(#project{username=Username,
      app_id = App_ID,
      u2f_device = U2F_Device})
      end,
  mnesia:activity(transaction, F).

update_challenge(Username) ->

  Challenge = base64:encode(crypto:strong_rand_bytes(32)),
  Update = fun() ->
    [P] = mnesia:wread({project, Username}),
    mnesia:write(P#project{challenge =  Challenge})
           end,
  mnesia:transaction(Update).
