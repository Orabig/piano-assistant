#!/usr/bin/python
# ------------------------------------------------------------
# This ugly thing is just to be able to print to stderr

from __future__ import print_function
import sys

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# ------------------------------------------------------------

import serial
import time

ser = serial.Serial('/dev/ttyAMA0', baudrate=31250, timeout=0.050)    

message = [0, 0, 0]
while True:
  i = 0
  while i < 3:
    data = ord(ser.read(1)) # read a byte
    if data >> 7 != 0:  
      i = 0      # status byte!   this is the beginning of a midi message!
    message[i] = data
    i += 1
    if i == 2 and message[0] >> 4 == 12:  # program change: don't wait for a
      message[2] = 0                      # third byte: it has only 2 bytes
      i = 3

  messagetype = message[0] >> 4
  messagechannel = (message[0] & 15) + 1
  note = message[1] if len(message) > 1 else None
  velocity = message[2] if len(message) > 2 else None

  message[0] = messagechannel

  ts = time.time()
  print("MID %.2f %d %s" % (ts, messagetype , ' '.join(map(str, message))))
  sys.stdout.flush()

#  if messagetype == 9:    # Note on
#    eprint("Note on : ch:%d note=%d  v=%d" % (messagechannel, note, velocity)) # ATTENTION, Ecrit sur STDOUT ?
#    ts = time.time()
#    print("%.2f %d %d" % (ts, note, velocity))
#    sys.stdout.flush()
#  elif messagetype == 8:  # Note off
#    print 'Note off'            
#  elif messagetype == 12: # Program change
#    print 'Program change'
#  elif messagetype == 15: # System exclusive. Ignored for now
#    continue
#  else:
#    print "message:%d" % messagetype


