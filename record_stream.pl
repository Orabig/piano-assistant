#!/usr/bin/perl

$| = 1;

# Record stream sent on the input to files given by commandline (timestamp is added as prefix)
# CTL (control) stream is also recorded but the file is changed each time a "CONTROL" event is received on it

# TODO : should also start a new record if no event for several seconds ?

my $PREFIX=$ARGV[0];

sub openNewFile() {
  close OUTPUT;
  my $now = time;
  my $file = "$PREFIX$now.session";
  open OUTPUT, ">$file" or die "could not open $file";
  print STDERR "Recording to $file\n";
}

openNewFile();

while (<STDIN>) {
  print OUTPUT;
  print STDERR;
  openNewFile() if /CTL .* CONTROL/;
}

