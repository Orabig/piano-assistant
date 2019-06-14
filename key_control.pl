#!/usr/bin/perl
#
# Sends control event from keyboard inputs
#
# Usage : ./key_control.pl | rp write control
#

use strict;
use Time::HiRes qw(time);
use IO::Prompt;

$\=$/; $|=1;

open CONTROL, "|-", "rp write control";
select CONTROL; $|=1;

while ($_=prompt '', -1) {
	next unless /[azer]/;
	my $now = time;
	print CONTROL "CTL $now $_";
}
