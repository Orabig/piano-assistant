#!/usr/bin/perl

use strict;
$|=1;
require "./ihm/ansi.pl";

my $main = frame_full();
frame_title($main,"MIDI EVENTS (midi)");

my $control = frame_split_v($main,-3);
frame_title($control,"CONTROL (ihm)");

my $tabs = frame_split_h($main,'25');
frame_title($tabs,"SONG (tabs)");

my $chords = frame_split_v($main,'50%');
frame_title($chords,"CHORDS (chords)");


my %output_frame;
$output_frame{MID}=$main;
$output_frame{TAB}=$tabs;
$output_frame{CHD}=$chords;
$output_frame{IHM}=$control;

open STREAM, "-|", "rp read midi notes chords tabs ihm"; #	or die "Can't open redis streams";

while(<STREAM>) {
	# Assume that all entries are like 'MID 1560067804.76 9 1 69 65'
	# (first field is required to know where to print this)
	next unless /^(\w+) ([\d\.]+) (.*)/;
	my $frame = $output_frame{$1};
	frame_print($frame,$3) if $frame;	
}


	