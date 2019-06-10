#!/usr/bin/perl
$\=$/;
$|=1;

use strict;
use Data::Dumper;

sub get_term_width {
	return `tput cols`;
}
my $SCREEN_WIDTH = get_term_width();

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
sub get_tabs {
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


sub print_tabs {
	my ($t)=@_;
	my @lines;
	my $cells = 0+@{$t->[0]};
	foreach my $group (@$t) {
		push @lines, get_measures_string(undef,$cells,$SCREEN_WIDTH,@lines ? 2:0);
		push @lines, get_measures_string($group,$cells,$SCREEN_WIDTH,1);
	}
	push @lines, get_measures_string(undef,$cells,$SCREEN_WIDTH,3);
	print join "\n", @lines;
}

my @input;
push @input,$_ while <DATA>;
my $song = readSong(@input);

my $A = get_tabs($song,'A');
my $B = get_tabs($song,'T');
my $C = get_tabs($song,'C');

print "A:";
print_tabs($A);
print "B:";
print_tabs($B);
print "C:";
print_tabs($C);

__DATA__
T:Le coeur grenadine
A:Laurent Voulzy
I:G
R:4/4 ; Chaque mesure est en 4/4
B:4 ; Afficher les mesures par 4 (sauf si indiqué autrement)
S:A,A,T,C,A,A,T,C

>_A_
G
l:J'ai laissé dans une mandarine
Bm7
C7M
/2/Am7
l:Une coquille de noix bleue marine
/2/D
G
Bm7
C7M
/2/Am7
/2/D
G
F#7
Am7
/2/Esus4
/2/E7
C
G/B
Am7
D
<_A_

>_T_
D
<_T_

>_C_
G
Bm7
/3/C
/1/C7M
/2/Am
/2/D : ; Repeter 2 fois depuis début du PART

Am
B7
/2/Em
/2/D
G
/8/C7M
/8/Bm7
/8/Am7
/8/D7
<_C_
