#!/usr/bin/perl
#
# Receive control event and manage states
#
# Usage : ./key_control.pl | rp write control
#

use strict;
use Time::HiRes qw(time);

$\=$/; $|=1;

my $KEY_LEFT='a';
my $KEY_RIGHT='e';
my $KEY_ACTION='z';
my $KEY_BACK='r';

my $SONG_DIR = './scores';

open CONTROL, "-|", "rp read control";
open IHM, "|-", "rp write ihm";
select IHM; $|=1;

my @state_stack;

my $main_menu = ['GORECORD::Record song', 'GOLOAD::Load song'];
my $record_menu = ['CHANGE_TAB::Change tab', 'CHANGE_BEAT'];
my $load_menu = '_files_';

# Initialize first menu
my $choice = 0; # TODO : choice should be a stack too
push @state_stack, $main_menu;


sub GO_RECORD {
	unshift @state_stack, $record_menu;
	$choice=0;
}
sub GO_LOAD {
	unshift @state_stack, $load_menu;
	$choice=0;
}
sub DO_LOAD {
	my $song = getMenuItemText(@_[0]);
	my $songfile = "$SONG_DIR/$song.song";
	print STDERR qx!./do_load_song.sh $songfile!
}

sub BACK {
	shift @state_stack if (@state_stack>1);
}

my $actions =
{
	'GOLOAD' => \&GO_LOAD,
	'GORECORD' => \&GO_RECORD,
	'LOAD' => \&DO_LOAD,
};

sub getFiles {
	opendir DIR, $SONG_DIR or return ("Error : Can't read song dir");
	my @files = map { s/\.song$//; "LOAD::$_" } grep { !/^\./ && -f "$SONG_DIR/$_" } readdir DIR;
	closedir DIR;
	return @files;
}

sub getCurrentMenuItems {
	my $menu = $state_stack[0];
	
	my @menu_items;
	if ($menu eq $load_menu) {
		@menu_items = getFiles();
	} else {
		# The menu is a list of item
		@menu_items	= @$menu;
	}
	return @menu_items;
}

sub getMenuItemText {
	$_=$_[0];
	s/.*:://;
	$_
}

sub getMenuItemId {
	$_=$_[0];
	s/::.*//;
	$_
}

sub printState {
	my @menu_items = getCurrentMenuItems();
	
	my $idx=0; my @entries = map {
		$idx++==$choice ? ">$_<" : " $_ "
	} map getMenuItemText($_), @menu_items;	
	
	$_ = '    ' . (join '    ', @entries) . '    ';
	my $now = time;
	print IHM "IHM $now $_";	
}

printState();

#
# Main control loop
#
while (<CONTROL>) {	
	next unless /^CTL \S+ (.)/; $_=$1;
	my $top_menu = $state_stack[0];
	my @entries = getCurrentMenuItems();
	if (/$KEY_LEFT/) {
		$choice--; $choice%=+@entries;
	} elsif (/$KEY_RIGHT/) {
		$choice++; $choice%=+@entries;
	} elsif (/$KEY_ACTION/) {
		my $chosen = $entries[$choice];
		my $action = $actions->{getMenuItemId($chosen)};
		&{$action}($chosen) if $action;
	} elsif (/$KEY_BACK/) {
	    BACK();
	}
	printState();
}
