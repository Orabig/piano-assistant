#!/bin/sh

while true; do
  cat $1 | grep ^MID | ./replay_events.pl | rp write midi -p
done

