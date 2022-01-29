#!/bin/sh

while true; do
  (aconnect -l | grep -q Connecting) || aconnect 20:0 $(perl -e '$_=qx"aconnect -l";/(\d+):.*ttymidi/;print$1'):1
  sleep 1
done
