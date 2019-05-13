#!/usr/bin/python
# ------------------------------------------------------------
# This ugly thing is just to be able to print to stderr

from __future__ import print_function
import sys

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# ------------------------------------------------------------

# Manage a set of pushed notes

# Input : timestamped MIDI note events
# Output : timestamped note sets

# TODO : aggregate by time within x ms : https://github.com/ReactiveX/RxPY/tree/release/v1.6.x

notes = set()

# This sucks... This is python
for line in iter(sys.stdin.readline, b''):
  line = line.strip() # Dangerous : may loose spaces at the end of the line
  (ts, note, velocity) = line.split()
  if velocity == "0":
    notes.discard(note)
  else:
    notes.add(note)
  print( "%s %s" % (ts, ' '.join(notes)) )
  sys.stdout.flush()
