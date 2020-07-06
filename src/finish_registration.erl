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
-export([init/2, fetch_response/1, allowed_methods/2, content_types_provided/2, get_json/2, go/1]).
-record(project, {call,
  response}).

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
  R= io_lib:format("~p",[Echo]),
  J = lists:flatten(R),
  O = lists:sublist(J, 4, length(J) - 6),
  E = go(O),
  io:format("Echo is ~p ~n", [O]),
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"text/plain; charset=utf-8">>
  }, E, Req);
echo(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

%Get
content_types_provided(Req, State) ->
  {[
    {<<"get/json">>, get_json}
  ], Req, State}.

get_json(Req, State) ->
  Body = go("Matthew"),
  {Body, Req, State}.


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

%erlang to json
project_to_json_encodable(#project{call = Call, response = Response}) ->
  [{call, list_to_binary(Call)}, {response, list_to_binary(Response)}].

%fetches response and converts it to json
go(Call) ->
  A = mnesia:dirty_read({project, Call}),
  [{_, _, X}] = A,
  Project = [
    #project{call = Call, response = X}
  ],
  JSON = jsx:encode(lists:map(fun project_to_json_encodable/1, Project)),
  JSON.