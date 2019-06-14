#!/usr/bin/perl

$| = 1;
$\ = $/;

# Manage MID and NOT events to detect actions from user
# double-tap = CONTROL

# Input : timestamped MIDI events + Notes (NOT) stream 
# Output : control events (eg. user tapping pedal twice in less than one second without note pressed = CONTROL event)

my $MIDI_CONTROL_CHANGE = 11; # MIDI specification

# Boolean : are there any pressed notes ?
my $notes_pressed;

my $pedal_state;
my $last_pedal_depressed;

while (<>) {
  next unless /^(\S{3}) (\S+) ?/;
  my ($stream, $ts) = ($1,$2);
  $_ = $';

  # TODO : Corriger : pour le moment ce script s'appuie sur le flux NOT pour savoir si une touche est
  #        enfoncée ou non.
  # Il serait possible de lire seulement le flux MID et prendre les notes sur un 8/9 (note off/on)
  $notes_pressed = /\d/ if ($stream eq 'NOT');

  # Do not listen to midi events if there are pressed notes
  next if $notes_pressed;

  if ($stream eq 'MID') {
    next unless /^$MIDI_CONTROL_CHANGE\b/;
    # Usually $_='11 1 64 128' for pedal press and '11 1 64 0' for pedal release
    my $state = ! /\b0$/; # 0=depressed 1=pressed
    if (!$state && $pedal_state) {
      # User just depressed the pedal
      print "CTL $ts CONTROL" if ($ts - $last_pedal_depressed < 1);
      $last_pedal_depressed = $ts;
    }
    $pedal_state = $state;
  }
}

