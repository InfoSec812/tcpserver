-module(idttcp_app).
-behaviour(application).

-export([start/2, stop/1]).

-spec(start(term(), term()) -> {ok, pid()}).
start(_StartType, _StartArgs) ->
  lager:log(info, self(), "idttcp_app started"),

  {ok, _} = ranch:start_listener(idttcp, ranch_tcp, [{port, 5555}], idttcp_protocol, []),

  idttcp_sup:start_link().

-spec(stop(term()) -> ok).
stop(_State) ->
  ranch:stop_listener(idttcp_protocol),
  ok.