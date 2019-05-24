#!/usr/bin/perl
#
# annotates a MIDI event logfile
#
# Usage : cat events.log | perl -pn annotate_midi.pl
#
$ALIGN=40;
$TAB=$" x ($ALIGN - length);

s/\d+\.\d+ 9 (\d+) (\d+) (\d+)/
	$3 ? "$&$TAB# Note : $2 (Ch:$1 Vel:$3)" : "$&$TAB# Note OFF : $2 (Ch:$1)"
	/e;

s/\d+\.\d+ 11 (\d+) (\d+) (\d+)/
	$3 ? "$&$TAB# Pedal : $3 (Ch:$1 ?:$2)" : "$&$TAB# Pedal OFF : (Ch:$1)"
	/e;
