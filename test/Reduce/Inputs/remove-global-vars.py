#!/usr/bin/env python

import sys

input = open(sys.argv[1], "r")
for line in input:
  if "@interesting = global" in line:
    sys.exit(0)

sys.exit(1) # IR isn't interesting
