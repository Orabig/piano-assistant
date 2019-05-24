#!/usr/bin/python
# ------------------------------------------------------------
# This ugly thing is just to be able to print to stderr

from __future__ import print_function
import sys

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# ------------------------------------------------------------

# Figure out what chord it is

# Removes the bass from the chord and return new set with offset values
def normalize_chord(notes,bass):
  offsets = set()
  for note in notes:
    offset = (note - bass) % 12
    if offset != 0:
      offsets.add( offset )
  return offsets

# Convert note (int) into a name (C C#...)
def decode_note(note):
  if note == '':
    return ''
  note = note % 12
  names = [ 'C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
  return names[note]

def guess_chord(ts, notes):
  if len(notes)==0:
    return
  tonique = min(notes)
  offsets = normalize_chord(notes, tonique)
  # Try to recognize chords
  # eg. 4,7==3,8==5,9==Major
  
  # Name of the chord is
  # Tone - color - alt - sus  - bass
  # eg. :
  # C      m       7
  # G              7     sus4  / D
  # Ab     m       maj7     5-
  
  tone=''
  color=''
  alt=''
  sus=''
  bass=''
  
  if 10 in offsets:
	alt="7"
	offsets.discard(10)

  if (offsets == set([4,7]) or offsets == set([3,8]) or offsets == set([5,9])):
	color='MAJOR'
  elif (offsets == set([3,7]) or offsets == set([5,8]) or offsets == set([4,9])):
	color='m'
  elif (offsets == set([5,7])):
	sus='sus4'
  elif (offsets == set([4,7,11])):
	alt='maj7'
  elif (offsets == set([2,7,11])):
	bass='/4'
  elif (offsets == set([4,6])):
	sus='5-'
  elif (offsets == set([3,6,9])):
	color='dim'
  elif (offsets == set([3,6])):
        color='m'
	sus='5-'
  else:
    if (len(offsets)>1):
	  print(offsets)
	  sys.stdout.flush()

  tonal = decode_note(tonique)
  
  name="%s%s%s%s"%(color,alt,sus,bass)
  if name!='':
    if color=='MAJOR':
	  name="%s%s%s"%(alt,sus,bass)
    print("CHD %s %s%s%s"%(ts,tonal,tone,name))
    sys.stdout.flush()

# ------------------------------------------------------------

# This sucks... This is python
for line in iter(sys.stdin.readline, b''):
  line = line.strip() # Dangerous : may loose spaces at the end of the line
  notes = line.split()
  stream = notes.pop(0)
  if stream != 'NOT':
    continue
  ts = notes.pop(0)
  guess_chord(ts, map(int, notes))
