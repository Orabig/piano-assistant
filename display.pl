#!/usr/bin/perl

use strict;
use IO::Select;

$|=1;
require "./ihm/ansi.pl";

my $main = frame_full();
frame_title($main,"MIDI EVENTS (midi)");

my $control = frame_split_v($main,-3);
frame_title($control,"CONTROL (ihm)");

my $tabs = frame_split_h($main,'25');
frame_title($tabs,"-");

my $chords = frame_split_v($main,'50%');
frame_title($chords,"CHORDS (chords)");

my %output_frame;
$output_frame{MID}=$main;
$output_frame{TAB}=$tabs;
$output_frame{CHD}=$chords;
$output_frame{IHM}=$control;

open STREAM, "-|", "rp read midi notes chords tabs ihm"; #	or die "Can't open redis streams";
my $s = IO::Select->new(\*STREAM);
my %tainted_frames; # Will know which frame need to be refreshed
my @tainted_frames;
while(1) {
	if ($s->can_read(0.25)) {
		$_='';
		while (sysread(STREAM, my $nextbyte, 1)) {
                last if $nextbyte eq "\n";
                $_ .= $nextbyte;
        }
		if (/^CLEAR (.*)/) {
			frame_clear( $output_frame{$1} );
			next;
		}
		if (/^TITLE (\w*) (.*)/) {
			frame_title( $output_frame{$1}, $2 );
			next;
		}
		# Assume that all entries are like 'MID 1560067804.76 9 1 69 65'
		# (first field is required to know where to print this)
		next unless /^(\w+) ([\d\.]+) (.*)/;
		my $frame = $output_frame{$1};
		frame_print_no_draw($frame,$3) if $frame;
		push @tainted_frames, $frame unless $tainted_frames{$frame}++;
	} else {
		foreach my $tainted (@tainted_frames) {
			frame_draw($tainted);
		}
		undef %tainted_frames;
		undef @tainted_frames;
	}
}

sub get_unbuf_line {
        my $line="";
        while (sysread(STREAM, my $nextbyte, 1)) {
                return $line if $nextbyte eq "\n";
                $line .= $nextbyte;
        }
        return(undef);
}


	