#!/usr/bin/bash
#This is the primary script that pulls data in and sends it to the server

#Query influxdb server, if not running then try to boot the docker server
state=$( curl --request POST "http://localhost:8086/health" \
  --header "Authorization: Token 9PVO0399Napqv2fwq-Q1TDpokavVLwO9sZjePUDeiGImJgcocFAdfJitJKbOdhB1Td_NokXm0DjZhuRQ4PAWaA==" \
  | grep -oE "ready for queries and writes" )
if [ "$state" != "ready for queries and writes" ]; then
	systemctl --user start docker
	sleep 5
	docker start influxdb
fi
#Pull data from Raspberry Shake
./shakepull.sh quadraticFILLET0 | tee shakepull.log
#Pull data from nmslab and report it
./dailyformat.sh
#Format RShake data
./dailyformat_seis.sh
#Move older data into long term storage
./backupdata.sh
#Sanitize nmslab machine
./nms_clean.sh
