#!/usr/bin/bash

#./dailyformat.sh
#placed in crontab, this runs every day
#check to see if influxdb is up and running
#then formats everything newer than last time this ran (using dailyformat_cp)


#only run if docker/influxdb is running
state=$( curl --request POST "http://localhost:8086/health" \
  --header "Authorization: Token 9PVO0399Napqv2fwq-Q1TDpokavVLwO9sZjePUDeiGImJgcocFAdfJitJKbOdhB1Td_NokXm0DjZhuRQ4PAWaA==" \
  | grep -oE "ready for queries and writes" )
if [ "$state" == "ready for queries and writes" ];
then

#only format and import the files that were touched since last run
	for file in ~/DataFiles/nmslab/*.data;
	do
		if [ "$file" -nt ~/DataFiles/dailyformat_cp ];
		then
			~/DataFiles/format_influx.pl $file
  			~/DataFiles/import_lp_data.sh
  		fi
	done

	curl -X POST -H 'Content-type: application/json' --data '{"text":"Network import completed."}' https://hooks.slack.com/services/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
	touch ~/DataFiles/dailyformat_cp	
	exit 1
fi
#if docker/influxdb is not running...alert and quit, no changes
	curl -X POST -H 'Content-type: application/json' --data '{"text":"ALERT. Influxdb state: $state"}' https://hooks.slack.com/services/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
exit 0
