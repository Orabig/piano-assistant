#!/bin/sh

until ./controller.pl; do
  echo "controller crashed with exit code $?. Respawning." >&2
  sleep 1
done
