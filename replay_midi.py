#!/usr/bin/python
# ------------------------------------------------------------
# This ugly thing is just to be able to print to stderr

from __future__ import print_function
import sys

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# ------------------------------------------------------------

import datetime
import time

eprint("====================================================")
eprint(__file__)
eprint(datetime.datetime.now())
eprint("--------> Starting replay");

# This offset is the difference between actual timestamp and original one (in the file)
offset = 0

for line in sys.stdin:
  timestamp, note, velocity = line.split()
  timestamp=float(timestamp)
  
  now = time.time()
  if offset == 0:
    offset=now-timestamp

  # Wait for the right time to publish the event
  while now < offset+timestamp:
    now = time.time()

  print("%.2f %s %s" % (timestamp+offset,note,velocity))

