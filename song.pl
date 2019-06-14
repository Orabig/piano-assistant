#!/usr/bin/perl
$\=$/;
$|=1;

use strict;
use Data::Dumper;

my %parts;

sub uniq {
  my %a;
  map$a{$_}++,@_;
  keys%a;
}


sub readSong {
	my $song = {};
	my $part='';
	foreach (@_) {
		chomp;
		s/ *(;.*)$//; # remove comments and trailing spaces
		if ($part) {
			if (/<$part/) {
				$part='';
				next;
			}
			push @{$song->{$part}},$_;
			next;
		}
		$song->{$1}=$2 if /^(.):(.*)/;
		if (/>(_.*_)/) {
			$part=$1;
		}		
	}
	return $song;
}

#
# Returns a 3-dimansion array containing the tabs
#
# Dim 1 : measure groups (generally containing 4 measures) 
# Dim 2 : measure (generally 4 beats)
# Dim 3 : Chords (struct containing name + length in quarters) eg. {c=>"Bm7",b=>"16"}
sub decode_tabs {
	my ($song,$part) = @_;
	my $rythm = $song->{R};
	$rythm=~m!(\d+)/(\d+)! or die "Incorrect rythm : $rythm";
	my $BeatInMeasure = $1;
	my $baseBeat = $2;
	my $BeatInMeasureInQuarters = $1*$2;
	my $groupSize = $song->{B};
	my $input = $song->{"_${part}_"};
	# First grab a list of chords (list of {b:"chord name" q:"quarters"}
	my @unsplit_chords = map {
			my $beat = s!^/(\d+)/!! ? $1 : $BeatInMeasure;
			# TODO : h/q pour 1/2 et 1/4
			$beat *= $baseBeat;
			{b=>$_, q=>$beat};
		} grep {
			! /^l:/ && $_
		} @$input;
	# Second, split chords that overlap multiple measures
	my @chords;
	foreach (@unsplit_chords) {
		while ($_->{q} >$BeatInMeasureInQuarters ) {
			push @chords, {b=>$_->{b}, q=>$BeatInMeasureInQuarters};
			$_->{b} = '-';
			$_->{q}-=$BeatInMeasureInQuarters;
		}
		push @chords, $_;
	}
	# Then, regroup by measures (each measure is $BeatInMeasureInQuarters quarters)
	my @measures;
	my $current = [];
	my $qCount=0;
	foreach (@chords) {
		my $q=$_->{q};
		die "Unsupported multi-measure chord : $_" if $q>$BeatInMeasureInQuarters;
		$qCount+=$q;
		die "Unsupported overlapping chord : $_" if $qCount>$BeatInMeasureInQuarters;
		push @$current, $_;
		if ($qCount==$BeatInMeasureInQuarters) {
			push @measures, $current;
			$current = [];
			$qCount=0;
		}
	}
	die "Unfinished measure at the end of $part" if ($qCount>0);
	# Lastly, regroup measures by "lines" of $groupSize (generally 4)
	my @groups;
	while (@measures) {
		my @group;
		@group = splice @measures,0,4;		
		push @groups, \@group;
	}
	return \@groups;
}


sub space_to {
	return $_[0] . (' ' x ($_[1] - length $_[0]));
}

sub get_measure_string {
	my ($m,$size)=@_;
	my @tabs = @$m;
	if (@tabs==1) {
		return space_to($tabs[0]->{b}, $size);
	}
	if (@tabs==2) {
		my $b1 = $tabs[0]->{b};
		my $b2 = $tabs[1]->{b};
		return space_to($b1, $size-length($b2)).$b2;
	}
	my $cat = join " ", map {$_->{b}} @tabs;
	return space_to($cat, $size);
}

my @GRID_BLOCKS = qw!
	┌ ┬ ┐
	│ │ │
	├ ┼ ┤
	└ ┴ ┘
!;


# Returns a string showing a group of measures
# m : array of measures (ref)
# w : width of the screen to fill
# t : type of line : 0=top, 1=name of the chord, 2=middle, 3=bottom
sub get_measures_string {
	my ($m,$num_cell,$w,$t)=@_;
	my $size=int(($w - 4 - ($num_cell-1)*3) / $num_cell);
	$_=$GRID_BLOCKS[3*$t];
	foreach my $idx (0..$num_cell-1) {
		my $measure = $m->[$idx];
		if ($t == 1) {
			$_.= ' ' . get_measure_string($measure,$size) . ' ';
		} else {
			$_.= '─' x ($size+2);
		}		
		$_.= $GRID_BLOCKS[3*$t+1] if $idx<$num_cell-1;
	}
	$_.= $GRID_BLOCKS[3*$t+2];
	return $_;
}


sub get_score_strings {
	my ($t,$width)=@_;
	my @lines;
	my $cells = 0+@{$parts{$t}->[0]};
	foreach my $group (@{$parts{$t}}) {
		push @lines, get_measures_string(undef,$cells,$width,@lines ? 2:0);
		push @lines, get_measures_string($group,$cells,$width,1);
	}
	push @lines, get_measures_string(undef,$cells,$width,3);
	return @lines;
}


sub get_term_width {
	return `tput cols`;
}

my @input;
push @input,$_ while <>;
my $song = readSong(@input);
my @structure = split ',', $song->{S}; # A,B,A,B,V,A,V,B...
my @parts = uniq(@structure);
map {
	$parts{$_} = decode_tabs($song,$_);
} @parts;


my $SCREEN_WIDTH = get_term_width();

my %seen; # Mark the parts already displayed
foreach (@structure) {
	next if $seen{$_}++;
	print "TAB 0.0 ...";
	print join "\n", map "TAB 0.0 $_", get_score_strings($_,$SCREEN_WIDTH);
}
