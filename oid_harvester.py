#oid_harvester.py [IP address] [OID list filename]
#Repeatedly runs snmpwalk on target IP using OIDlist file if run.file exits
#Writes log events to oid_harvester.log
#Writes output to stdout formatted by lp

import sys
import os
import os.path
import re
from os import path
from datetime import datetime

#check that runfile is present
runfile = path.exists("run.file")

##Quit if runfile not present
if (not runfile):
	print("run.file not found in pwd. Exiting.", file=sys.stderr)
	exit()

#Arugments in
IPaddr = sys.argv[1]
OIDfile = open(sys.argv[2], 'r')

#load logfile and start sequence
logfile = open('oid_harvester.log', 'a')
now = datetime.now()
logfile.write(str(now) + " : Started on " + IPaddr + " using " + str(sys.argv[2]) + "\n")


#bad value list
bad_val_list = [ "NULL" , 
				 "999999999" , 
				 "No Such Instance currently exists at this OID" , 
				 "No Such Object available on this agent at this OID" ,
				 "-55.00" ,
				 ".00" ,
				 "0"]

#load oid list
OIDlist = OIDfile.readlines()
OIDfile.close()

os.environ["MIBS"] = "ALL"

while (runfile):

	for OIDquery in OIDlist:
		# Escape check
		runfile = path.exists("run.file")
		if (not runfile):
			break

		# snmpwalk command
		snmpwalk = "snmpwalk -v3 " + IPaddr + " " + OIDquery.strip() #+ " -Oqse"
		stream = os.popen(snmpwalk)
		now = datetime.now()
		output = stream.readlines()

		# lines in output format: 
		# Well Formed: [MIB]::[OID].[Instance] = [Type]: [Output]
		# Wrong Type : [MIB]::[OID].[Instance] = Wrong Type (should be *)]: [Type]: [Output]
		# Error      : [MIB]::[OID] = No Such Instance currently exists at this OID
		# Error      : [MIB]::[OID] = No Such Object available on this agent at this OID
		for line in output:
			line.strip()
			output_list = line.split(" = ")
			#Check for malformed output
			if (len(output_list) != 2):
				print("output_list fail: " + output_list[0])
				continue #Expand later for non-returns: if not returning, log time and oid fail and wait 1 minute
			raw_OID, raw_val = output_list
			
			#Retrieve value
			value = raw_val.split(": ")[-1].strip()
			value = value.strip('\"')
			if (value in bad_val_list):
				#print(str(value) + " skipped!")
				continue

			#Retrieve tags and labels
			#print(raw_OID)
			MIB, OID, instance = re.split('::|\.', raw_OID)

			MIB = MIB.split('-')[2]
			OID = OID.split('Real')[-1]

			#Convert to timestamp
			ts = int(datetime.timestamp(now)*1000000000)

			#Print lp format output to stdout
			if (instance != None):
				result = MIB + ",OID=" + OID + ",ins=" + instance + " val=" + value + " " + str(ts)
				print(result)

		### DEBUG: Run once
		#runfile = False

logfile.write(str(now) + " : run.file not found in pwd. Exiting.\n")
logfile.close()
exit()