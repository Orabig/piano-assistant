#!/usr/bin/perl

use strict;

require "./ansi.pl";

my $main = frame_full();
frame_title($main,"MIDI EVENTS");

my $chords = frame_split_h($main,25);
frame_title($chords,"CHORDS");

my $notes = frame_split_v($main,'50%');
frame_title($notes,"NOTES");


my %output_frame;
$output_frame{MID}=$main;
$output_frame{NOT}=$notes;
$output_frame{CHD}=$chords;

frame_draw( $main );
frame_draw( $notes );
frame_draw( $chords );

while(<>) {
	# Assume that all entries are like 'MID 1560067804.76 9 1 69 65'
	next unless /^(\w+) ([\d\.]+) (.*)/;
	frame_print($output_frame{$1},$3);
}


	