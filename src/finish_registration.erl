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
-export([init/2, fetch_response/1, allowed_methods/2, go/1, project_to_json_encodable/1, update_u2f_enroll/1, is_username_in_table/1, add_user_skeleton/1]).
-record(project, {username, u2f_enroll = [], u2f_device}).

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
  update_u2f_enroll(Username),
  E = Username,
  %E = go(O),
  io:format("Echo is ~p ~n", [Username]),
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"text/plain; charset=utf-8">>
  }, E, Req);
echo(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

%%Finds response associated with call
fetch_response(Username) ->
  Pattern = #project{_ = '_',
    username = Username},
  F = fun() ->
    Res = mnesia:match_object(Pattern),
    [{Username,U2F_Enroll, U2F_Device} ||
      #project{username=Username,
        u2f_enroll=U2F_Enroll,
        u2f_device=U2F_Device
      } <- Res]
      end,
  mnesia:activity(transaction, F).

%erlang to json
project_to_json_encodable(#project{username=Username, u2f_enroll=U2F_Enroll, u2f_device=U2F_Device}) ->
  [{username, list_to_binary(Username)}, {u2f_enroll, list_to_binary(U2F_Enroll)},
    {u2f_device, list_to_binary(U2F_Device)}].

%fetches response and converts it to json
go(Username) ->
  A = mnesia:dirty_read({project, Username}),
  [{_, _, X, _}] = A,
  [{_, _, _, Y}] = A,
  Project = [
    #project{username = Username, u2f_enroll = X, u2f_device = Y}
  ],
  JSON = jsx:encode(lists:map(fun project_to_json_encodable/1, Project)),
  JSON.



%key = matthew
update_u2f_enroll(Key) ->
  App_id = "http://localhost:8080/enroll",
  %Registered_keys = {},
  Challenge = base64:encode(crypto:strong_rand_bytes(32)),
  Version = "U2F_V2",
  %Register_requests= {Version, Challenge},
  %Cls= {App_id, Register_requests, Registered_keys},

  Update = fun() ->
    [P] = mnesia:wread({project, Key}),
    mnesia:write(P#project{u2f_enroll = [{app_id, App_id},{version, Version}, {challenge, Challenge}]})
  end,
  mnesia:transaction(Update).

%check if user is in table, if yes -> return true;
% if not, add user into database with no values for enroll and device
is_username_in_table(Username) ->
  case mnesia:dirty_read(project, Username) of
    [] -> add_user_skeleton(Username);
    _ -> true
  end.

%if user is not in mnesia, add a user into the table with empty values for enroll and device
add_user_skeleton(Username) ->
  F = fun() ->
    mnesia:write(#project{username=Username,
      u2f_enroll=[],
      u2f_device = []})
      end,
  mnesia:activity(transaction, F).

