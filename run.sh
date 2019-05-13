#!/bin/sh
sudo killall /usr/bin/python

cd /home/pi/DEV/piano-assistant/

              ./capture_midi.py 2> log/midi.log   | rp write midi &
rp read midi  | ./aggr_notes.py 2> log/notes.log  | rp write notes &
rp read notes | ./find_chord.py 2> log/chords.log | rp write chords &

./read_chords.sh
