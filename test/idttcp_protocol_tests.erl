-module(idttcp_protocol_tests).

-include_lib("eunit/include/eunit.hrl").

process_message_test() ->

  Queue = queue:new(),

  {Response, NewQueue} = idttcp_protocol:process_message(<<"x">>, Queue),
  ?assertEqual(Queue, NewQueue),
  ?assertEqual(<<"Unknown command. Use: 'in *Payload*' to insert | 'out' to read | 'exit'\n">>, Response),

  {Response1, NewQueue1} = idttcp_protocol:process_message(<<"in x">>, NewQueue),
  ?assertEqual({[<<"x">>], []}, NewQueue1),
  ?assertEqual(<<"x\n">>, Response1),

  {Response2, NewQueue2} = idttcp_protocol:process_message(<<"in y">>, NewQueue1),
  ?assertEqual({[<<"y">>],[<<"x">>]}, NewQueue2),
  ?assertEqual(<<"y\n">>, Response2),

  {Response3, NewQueue3} = idttcp_protocol:process_message(<<"out">>, NewQueue2),
  ?assertEqual({[], [<<"y">>]}, NewQueue3),
  ?assertEqual(<<"x\n">>, Response3),

  {_, NewQueue4} = idttcp_protocol:process_message(<<"out">>, NewQueue3),
  {Response5, NewQueue5} = idttcp_protocol:process_message(<<"out">>, NewQueue4),
  ?assertEqual({[], []}, NewQueue5),
  ?assertEqual(<<"empty\n">>, Response5),


  ?assert(true).
