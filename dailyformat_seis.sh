#!/usr/bin/bash

#./dailyformat_seis.sh
#check to see if influxdb is up and running
#then formats everything newer than last time this ran (using dailyformat_cp)


#only run if docker/influxdb is running
state=$( curl --request POST "http://localhost:8086/health" \
  --header "Authorization: Token 9PVO0399Napqv2fwq-Q1TDpokavVLwO9sZjePUDeiGImJgcocFAdfJitJKbOdhB1Td_NokXm0DjZhuRQ4PAWaA==" \
  | grep -oE "ready for queries and writes" )
if [ "$state" == "ready for queries and writes" ];
then

#only format and import the files that were touched since last run
	for file in ~/DataFiles/RShake/archive/2022/AM/R5C2A/**/*;
	do
		if [ "$file" -nt ~/DataFiles/dailyformat_seis_cp ];
		then
			~/DataFiles/seismic_format_1hzmax.py $file
  			~/DataFiles/import_lp_data_seis.sh
  		fi
	done

	curl -X POST -H 'Content-type: application/json' --data '{"text":"Seismic import completed."}' https://hooks.slack.com/services/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
	touch ~/DataFiles/dailyformat_seis_cp	
	exit 1
fi
#if docker/influxdb is not running...alert and quit, no changes
	curl -X POST -H 'Content-type: application/json' --data '{"text":"ALERT. Influxdb state: $state"}' https://hooks.slack.com/services/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
exit 0
