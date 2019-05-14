#!/bin/sh

#
# This script should be added at the end of /etc/rc.local
#

export GOPATH=$HOME/go
export PATH=$PATH:/home/pi/go/bin

cd /home/pi/DEV/piano-assistant/

              ./capture_midi.py 2> log/midi.log   | rp write midi &
rp read midi  | ./aggr_notes.py 2> log/notes.log  | rp write notes &
rp read notes | ./find_chord.py 2> log/chords.log | rp write chords &

# This will record all MIDI events and write them into a full logfile
rp read midi >> log/all_midi.log &
