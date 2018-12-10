-module(idttcp_protocol).
-behaviour(ranch_protocol).

-export([start_link/4]).
-export([init/3]).

-type idt_queue() :: {[binary()],[binary()]}.

start_link(Ref, _Socket, Transport, Opts) ->
  Pid = spawn_link(?MODULE, init, [Ref, Transport, Opts]),
  {ok, Pid}.

init(Ref, Transport, _Opts = []) ->
  {ok, Socket} = ranch:handshake(Ref),
  lager:log(info, self(), "TCP conn established"),
  loop(Socket, Transport, queue:new()).


-spec loop(inet:socket(), atom(), idt_queue()) -> ok.
loop(Socket, Transport, Queue) ->
  case process_input(Transport:recv(Socket, 0, 600000)) of
    error ->
      lager:log(info, self(), "TCP conn terminated"),
      Transport:close(Socket);

    <<"exit">> ->
      lager:log(info, self(), "TCP conn terminated"),
      Transport:close(Socket);

    Command ->
      {Response, NewQueue} = process_message(Command, Queue),
      Transport:send(Socket, Response),
      loop(Socket, Transport, NewQueue)
  end.


-spec process_input({ok, any()} | {error, closed | atom()} ) -> binary() | error.
process_input({ok, Data}) ->
  binary:replace(Data,[<<"\n">>,<<"\r">>],<<"">>, [global]);
process_input(_) ->
  error.


-spec process_message(Command::binary(), Queue::idt_queue()) -> {Response::binary(), NewQueue::idt_queue()}.
process_message(<<"in ", Payload/binary>>, Queue) ->
  {<<Payload/binary, "\n">>,  queue:in(Payload, Queue)};

process_message(<<"out">>, Queue) ->
  {Item, NewQueue} = queue:out(Queue),

  Response = case Item of
               {value, Val} ->
                 <<Val/binary, "\n">>;
               _ ->
                 <<"empty\n">>
             end,
  {Response, NewQueue};
process_message(_, Queue) ->
  {<<"Unknown command. Use: 'in *Payload*' to insert | 'out' to read | 'exit'\n">>, Queue}.