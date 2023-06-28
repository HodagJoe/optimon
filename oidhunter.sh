#!/bin/bash
#oid_hunter.sh [ip] [input] [output]

ip=$1
out_f=$3
all_oids=$(cat $2)

#Start the hunt!
reply=$(snmpwalk -v3 $ip INFINERA-ENTITY-EQPT-MIB::eqptPON)

#If no response, just quit
if [ -z "$reply" ]
then
	echo "No response...check variables and try again later?"
	exit 1
else
	echo "oid_hunter output - "${ip}" - "$(date) > $out_f
	echo "---" >> $out_f
	echo "$reply" >> $out_f
	echo "---" >> $out_f
fi

#run through the hunt
for oid in $all_oids
do
	fails=0
	reply=""
	while [ $fails -le 2 ]
	do
		reply=$(snmpwalk -v3 $ip $oid)
		if [ -z "$reply" ]
		then
			check=""
			while [ -z "$check" ]
			do
				sleep 1m
				check=$(snmpwalk -v3 $ip INFINERA-ENTITY-EQPT-MIB::eqptPON)
			done
			((fails++))
		else
        		echo "$reply" >> $out_f
        		echo "---" >> $out_f
			fails=100 #It's actually successful
		fi
	done
done
echo "Walk completed" >> $out_f
exit 0
