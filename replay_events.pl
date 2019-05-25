#!/usr/bin/perl
#
# Replay events sent to STDIN with same exact timings
#
# Usage : ./replay_events.pl < events.log
#

use strict;
use Time::HiRes qw(time);
$\=$/; $|=1;

# This offset is the difference between actual timestamp and original one (in the file)
my $offset;

while (<>) {
	chomp;
	next unless /^\w+ (\S+)/;
	my $timestamp=$1;
	
	my $now = time;
	print STDERR ($now-$timestamp) unless $offset;
	$offset |= $now-$timestamp;
	# Wait for the right time to publish the event
	$now = time while $now < $offset+$timestamp;

	s/$timestamp/$timestamp+$offset/e;
	print;
}
