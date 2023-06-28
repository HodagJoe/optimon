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
	max_val = 0
	
	for p, value in enumerate(tr.data):
		data_cal = value * calibration
		abs_data = abs(data_cal)
		if (abs_data > max_val):
			max_val = abs_data
		
		if (p % int(tr.stats.sampling_rate) == 0 and p != 0): 
			f.write("Seis1HZ,station=%s,channel=%s value=%f %d\n" % (station, channel, max_val, time_ns))
			max_val = 0
			dp_ctr += 1
			if (dp_ctr >= dp_limit):
				f.close()
				f_ctr += 1
				dp_ctr = 0
				f = open("lp_data/%s_%d.lp" % (out_file, f_ctr), "w")
				print("Writing outfile/%s_%d.lp ..." %(out_file, f_ctr))
		time_ns += rate

f.close()
print("done")
