#!/usr/bin/env python3
import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), "../python"))
from cardutil import sdcard

if len(sys.argv) != 2:
    print("usage: create_fs.py <device>")
    sys.exit(1)
sd = sdcard(sys.argv[1])
sd.make_partitions()
