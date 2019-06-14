#!/usr/bin/perl

use strict;

$|=1;
# ANSI definitions
# https://en.wikipedia.org/wiki/ANSI_escape_code#Example_of_use_in_shell_scripting

my $CSI = "\033[";

sub get_term_width {
	return `tput cols`;
}

sub get_term_height {
	return `tput lines`;
}

sub ansi_cursor_pos {
  my ($y,$x)=@_;
  print "$CSI${x};${y}H";
}
sub ansi_clear_screen {
  print "${CSI}2J";
}
sub ansi_hide_cursor {
  print "${CSI}?25l";
}
sub ansi_show_cursor {
  print "${CSI}?25h";
}

sub ansi_set {
   my ($x)=@_;
   print "$CSI${x}m";
}

sub ansi_fg {
   my ($x)=@_;
   ansi_set("38;5;$x");
}

sub frame_draw {
	my ($x,$y,$w,$h) = @_;
	ansi_cursor_pos($x,$y);
	print '┌' . ('─' x $w) . '┐';
	map {
		ansi_cursor_pos($x,$y+$_);
		print '│' . (' ' x $w) . '│';
		} 1..$h;
	ansi_cursor_pos($x,$y+$h+1);
	print '└' . ('─' x $w) . '┘';
}

#############################################################
#
#  frame_*
#

sub frame_line {
	my ($me,$pos) = @_;
	my $content = $me->{-content};
	my $w = $me->{-w};
	my $line=$content->[$pos-1];
	
	# This is meant to know the REAL size of the string which is not handled as utf8 by Perl
	use Encode;
	Encode::_utf8_on($line);
	my $len = length($line);
	Encode::_utf8_off($line);
	
	$line .= ' ' x ($w-$len);
}

sub frame_draw {
	my ($me) = @_;
	$|=0;	
	ansi_hide_cursor();
	my ($x,$y,$w,$h) = @$me{qw!-x -y -w -h!};

	my $topbar;
	my $title = $me->{ -title };
	if ($title) {
		my $len = 3+length $title;
		$topbar = "┌─ $title " . ('─' x ($w-$len)) . '┐';
	} else {
		$topbar = '┌' . ('─' x $w) . '┐';
	}

	ansi_cursor_pos($x,$y);
	print $topbar;

	map {
		ansi_cursor_pos($x,$y+$_);
		my $line = frame_line($me, $_);
		print "│$line│";
		} 1..$h;

	ansi_cursor_pos($x,$y+$h+1);
	print '└' . ('─' x $w) . '┘';

	ansi_show_cursor();
	$|=1;
}

sub frame_print {
	my ($me, $text) = @_;
	push @{$me->{-content}}, $text;
	my $h = $me->{-h};
	splice @{$me->{-content}},0,-$h;
	frame_draw($me); # TODO : do NOT draw after each call... Set a background forked process ?
}

sub frame_title {
	my ($me, $text) = @_;
	$me->{ -title } = $text;
	frame_draw( $me );
}

sub new_frame {
  my $me = {};
  @$me{ qw!-x -y -w -h! } = @_;
  $me->{-content}=[];
  return $me;
}

# Creates a frame having the full terminal screen size
sub frame_full {
  my $me = new_frame(1, 1, get_term_width()-2, get_term_height()-2);
  frame_draw($me);
  $me;
}

sub get_per {
  my ($value, $per)=@_;
  return int($value * $1 / 100) if $per=~/(.*)%/;
  return $value+$per if $per<0;
  return $per;
}
# Splits a frame horizontally and creates a new one
sub frame_split_h {
	my ($oldf, $per) = @_;
	my ($x,$y,$oldw,$h) = @$oldf{qw!-x -y -w -h!};
	my $w1 = get_per($oldw, $per); # New width for $oldf
	$oldf->{-w}=$w1;
	frame_draw($oldf);
	my $newx = $x + $w1 + 2;
	my $neww = $oldw - $w1 - 2;
	my $newf = new_frame($newx,$y,$neww,$h);
	frame_draw($newf);
	return $newf;
}

# Splits a frame vertically and creates a new one
sub frame_split_v {
	my ($oldf, $per) = @_;
	my ($x,$y,$w,$oldh) = @$oldf{qw!-x -y -w -h!};	
	my $h1 = get_per($oldh, $per); # New height for $oldf
	$oldf->{-h}=$h1;
	frame_draw($oldf);
	my $newy = $y + $h1 + 2;
	my $newh = $oldh - $h1 - 2;
	my $newf = new_frame($x,$newy,$w,$newh);
	frame_draw($newf);
	return $newf;
}

1;