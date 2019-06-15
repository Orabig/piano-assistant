#!/usr/bin/perl

use strict;
use IO::Select;

$|=1;
$\=$/;

my $autostartForDebug = 1;

my $recording = 0;
my $filename;
my $lastChordPlayed;

# Start recording
sub start {
	my ($name)=@_;
	$filename = "scores/$name.song";
	qx!echo $filename > in_edit!;
	open FILE, ">$filename";
	print FILE "T:$1
R:4/4
B:4
S:A

>_A_";
	close(FILE);
	$recording = 1;
	qx!echo "CTL 1234 REFRESH SONG" | rp write control!;
}

start('Song_000') if $autostartForDebug;

open STREAM, "-|", "rp read command chords notes"; #	or die "Can't open redis streams";
while(<STREAM>) {
	if ($recording && /CHD \S+ (.*)/) {
		$lastChordPlayed = $1;
		next;
	}
	if ($recording && /NOT \S+ *$/) {
		# Silence
		print STDERR "Append $lastChordPlayed";
		qx!echo "$lastChordPlayed" >> $filename!;
		qx!echo "CTL 1234 REFRESH SONG" | rp write control!;

	}
	next unless /^CMD \S+ RECORD (.*)/;
	$_ = $1;
	print STDERR "> $_";
	if (/^START (.*)/) {
		start($1);
	}
}
