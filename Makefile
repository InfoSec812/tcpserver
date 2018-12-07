ERL_RUN_ARGS:=+pc unicode -pa _build/default/lib/*/ebin -boot start_sasl -s idttcp start

compile:
	rebar3 compile skip_deps=true

compile-all:
	rebar3 compile

get-deps:
	rebar3 get-deps

clean:
	rebar3 clean skip_deps=true
	rm -f erl_crash.dump

clean-all:
	rebar3 clean
	rm -f erl_crash.dump

eunit:
	rebar3 eunit skip_deps=true

run:
	ERL_LIBS=deps erl $(ERL_RUN_ARGS)

background:
	ERL_LIBS=deps erl -detached $(ERL_RUN_ARGS)

d:
	dialyzer --src -I include src

etags:
	etags src/*

