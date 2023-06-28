#!/usr/bin/env python3
"""
USAGE: seismic_format.py in_file
"""
from __future__ import print_function
from pyrfc3339 import parse
from datetime import datetime

import sys

import numpy as np
import obspy

import pytz
import os.path



try:
	in_file = sys.argv[1]
	out_file = os.path.basename(sys.argv[1])
	calibration = float(.5)
except:
	print(__doc__)
	raise

#setup initial file data
dp_limit = 4990
dp_ctr = 0
f_ctr = 0
f = open("lp_data/%s_%d.lp" % (out_file, f_ctr), "w")
print("Writing outfile: %s_%d.lp ..." %(out_file, f_ctr))

st = obspy.read(in_file)


## done in tuple form
for i, tr in enumerate(st):
	station = tr.stats.station
	channel = tr.stats.channel
	timejunk = parse(str(tr.stats.starttime))
	time_ns = int(datetime.timestamp(timejunk)*1000000) * 1000
	rate = int(1000000000 / tr.stats.sampling_rate)
	print("New trace identified ...")

	for p, value in enumerate(tr.data):
		#if (p > tr.stats.npts): 
		#	break
		data_cal = value * calibration
		f.write("Seismic,station=%s,channel=%s value=%f %d\n" % (station, channel, data_cal, time_ns))
		time_ns += rate
		dp_ctr += 1
		if (dp_ctr >= dp_limit):
			f.close()
			f_ctr += 1
			dp_ctr = 0
			f = open("lp_data/%s_%d.lp" % (out_file, f_ctr), "w")
			print("Writing outfile/%s_%d.lp ..." %(out_file, f_ctr))

f.close()
print("done")
