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

my %KEY;
$KEY{21}='a';
$KEY{22}='z';
$KEY{23}='e';
$KEY{24}='r';

my $key_pressed;

while (<>) {
  next unless /^(\S{3}) (\S+) ?/;
  my ($stream, $ts) = ($1,$2);
  $_ = $';

  # TODO : Corriger : pour le moment ce script s'appuie sur le flux NOT pour savoir si une touche est
  #        enfoncée ou non.
  # Il serait possible de lire seulement le flux MID et prendre les notes sur un 8/9 (note off/on)
  if ($stream eq 'NOT') {
	  $notes_pressed = /\d+/;
	  my $note = $&;
	  if ($note && $KEY{$note}) {
		$key_pressed = $KEY{$note};
	  } else {
		print "CTL $ts $key_pressed" if $key_pressed;
		$key_pressed = '';
	  }
  }
  

  # Do not listen to midi events if there are pressed notes
  # next if $notes_pressed;
  
  if ($stream eq 'MID') {
    next unless /^$MIDI_CONTROL_CHANGE\b/;
    # Usually $_='11 1 64 128' for pedal press and '11 1 64 0' for pedal release
    my $state = ! /\b0$/; # 0=depressed 1=pressed
    if (!$state && $pedal_state) {
      # User just depressed the pedal
  # This detect double-tap which is not used anymore
  #    print "CTL $ts CONTROL" if ($ts - $last_pedal_depressed < 1);
      print "CTL $ts PEDAL";
      $last_pedal_depressed = $ts;
    }
    $pedal_state = $state;
  }
}

