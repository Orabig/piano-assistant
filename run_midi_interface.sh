#!/bin/sh

until ttymidi -s /dev/serial0 -b 31250; do
  echo "TTYMIDI crashed with exit code $?. Respawning." >&2
  sleep 1
done
