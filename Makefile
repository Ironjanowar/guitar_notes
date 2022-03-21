env:
export MIX_ENV=dev

secret_key_base: env
export SECRET_KEY_BASE = $(shell mix phx.gen.secret)

deps: env
	mix deps.get
	mix deps.compile
compile: deps
	mix compile

start: env secret_key_base
	_build/dev/rel/guitar_notes/bin/guitar_notes daemon

iex: env secret_key_base
	iex -S mix

clean:
	rm -rf _build

purge: clean
	rm -rf deps
	rm mix.lock

stop:
	_build/dev/rel/guitar_notes/bin/guitar_notes stop

attach:
	_build/dev/rel/guitar_notes/bin/guitar_notes remote

release: deps compile
	mix release

debug: secret_key_base
	_build/dev/rel/guitar_notes/bin/guitar_notes console

logs:
	tail -n 20 -f log/debug.log

db_setup: compile
	mix ecto.create
	mix ecto.migrate

db_reset: compile
	mix ecto.drop
	mix ecto.create
	mix ecto.migrate

code_check: compile
	mix credo --strict

.PHONY: deps compile release start clean purge iex stop attach debug db_setup db_reset code_check secret_key_base
