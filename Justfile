set shell := ["/bin/zsh", "-c"]

default:
  @just -l

lint:
  ./bin/lint

update:
  ./bin/update

services-start:
  ./bin/services start

services-stop:
  ./bin/services stop

cleanup:
  ./bin/cleanup


