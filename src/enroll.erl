%%%-------------------------------------------------------------------
%%% @author matthewlee
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Jun 2020 10:55 AM
%%%-------------------------------------------------------------------
-module(enroll).
-author("matthewlee").
-export([enroll/1, create/0]).

enroll(Username) ->
   Username.

create() ->
  App_id = "http://localhost:8080/enroll",
  Registered_keys = {},
  Challenge = base64:encode(crypto:strong_rand_bytes(32)),
  Version= "U2F_V2",
  Register_requests= {Version, Challenge},
  Cls = {App_id, Register_requests, Registered_keys},
  Cls.



