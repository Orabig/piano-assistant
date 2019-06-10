#!/bin/sh

export GOPATH=$HOME/go
export PATH=$PATH:/home/pi/go/bin

cd /home/pi/DEV/piano-assistant/ihm/

rp read midi notes chords controle | ./main.pl
