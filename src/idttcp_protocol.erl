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
  loop(Socket, Transport, queue:new()).

loop(Socket, Transport, Queue) ->
  case process_input(Transport:recv(Socket, 0, 600000)) of
    <<"exit">> ->
      lager:log(info, self(), "TCP conn terminated"),
      ok = Transport:close(Socket);

    <<"in ", Payload/binary>> ->
      Transport:send(Socket, <<Payload/binary, "\n">>),
      loop(Socket, Transport, queue:in(Payload, Queue));

    <<"out">> ->

      {Item, NewQueue} = queue:out(Queue),

      Response = case Item of
        {value, Val} ->
          Val;
        _ ->
          <<"empty\n">>
      end,
      Transport:send(Socket, <<Response/binary, "\n">>),
      loop(Socket, Transport, NewQueue);
    error ->
      Transport:close(Socket);
    _ ->
      Transport:send(Socket, <<"Unknown command. Use: 'in *Payload*' to insert | 'out' to read | 'exit'\n">>),
      loop(Socket, Transport, Queue)
  end.

process_input({ok, Data}) ->
  binary:replace(Data,[<<"\n">>,<<"\r">>],<<"">>, [global]);
process_input(_) ->
  error.
