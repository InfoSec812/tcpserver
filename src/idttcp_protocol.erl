-module(idttcp_protocol).
-behaviour(ranch_protocol).

-export([start_link/4]).
-export([init/3]).

start_link(Ref, _Socket, Transport, Opts) ->
  Pid = spawn_link(?MODULE, init, [Ref, Transport, Opts]),
  {ok, Pid}.

init(Ref, Transport, _Opts = []) ->
  {ok, Socket} = ranch:handshake(Ref),
  lager:log(info, self(), "TCP conn established"),
  loop(Socket, Transport).

loop(Socket, Transport) ->
  case Transport:recv(Socket, 0, 60000) of
    {ok, <<"exit\r\n">>} ->
      lager:log(info, self(), "TCP conn terminated"),
      ok = Transport:close(Socket);
    {ok, Data} when Data =/= <<4>> ->
      Transport:send(Socket, Data),
      loop(Socket, Transport);
    _ ->
      ok = Transport:close(Socket)
  end.