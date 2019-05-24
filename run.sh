#!/bin/sh

#
# This script should be added at the end of /etc/rc.local
#

export GOPATH=$HOME/go
export PATH=$PATH:/home/pi/go/bin

killall /usr/bin/python
killall rp

cd /home/pi/DEV/piano-assistant/

              ./capture_midi.py 2> log/midi.err   | rp write midi &
rp read midi  | ./aggr_notes.py 2> log/notes.err  | rp write notes &
rp read notes | ./find_chord.py 2> log/chords.err | rp write chords &
rp read midi notes | ./pedal_detect.pl 2> log/pedal.err | rp write control &

# This will record all MIDI events and write them into a full logfile
rp read midi >> log/midi.log &
rp read chords >> log/chords.log &
