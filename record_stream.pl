#!/usr/bin/perl

$| = 1;

# Record stream sent on the input to files given by commandline (timestamp is added as prefix)
# CTL (control) stream is also recorded but the file is changed each time a "CONTROL" event is received on it

my $PREFIX="records/file";

sub openNewFile() {
  close OUTPUT;
  my $now = time;
  my $file = "${PREFIX}_$now.session";
  open OUTPUT, ">$file" or die "could not open $file";
  print STDERR "Recording to $file\n";
}

openNewFile();

while (<>) {
  print OUTPUT;
  openNewFile() if /CTL .* CONTROL/;
}

