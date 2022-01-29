#!/usr/bin/perl

#
# This controller reads MIDI events from 20:0 (MIDI keyboard)
# and interprets program changes to perform actions
#

# pi@midibox:~/DEV/piano-assistant $ aseqdump -p 20:0
# Waiting for data. Press Ctrl+C to end.
# Source  Event                  Ch  Data
#  20:0   Program change          0, program 0

# Do nothing for now
exit 0;