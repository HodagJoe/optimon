#!/usr/bin/bash

state=$( curl --request POST "http://localhost:8086/health" \
  --header "Authorization: Token 9PVO0399Napqv2fwq-Q1TDpokavVLwO9sZjePUDeiGImJgcocFAdfJitJKbOdhB1Td_NokXm0DjZhuRQ4PAWaA==" \
  | grep -oE "ready for queries and writes" )
if [ "$state" != "ready for queries and writes" ]; then
	systemctl --user start docker
	sleep 5
	docker start influxdb
fi
./shakepull.sh quadraticFILLET0 | tee shakepull.log
./dailyformat.sh
./dailyformat_seis.sh
./backupdata.sh
./nms_clean.sh
