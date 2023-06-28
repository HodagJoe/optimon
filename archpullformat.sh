#!/usr/bin/bash

#./archpullformat.sh
#placed in crontab, this runs every day
#check to see if influxdb is up and running
#then formats everything newer than last time this ran (using dailyformat_cp)

judgefile () {
	if grep -q "h_OCHCTP" $1;
	then
		~/DataFiles/format_archpull.pl $file
  		~/DataFiles/import_lp_data.sh	
  		echo "$1 done."
	fi
}

#only run if docker/influxdb is running
state=$( curl --request POST "http://localhost:8086/health" \
	--header "Authorization: Token 9PVO0399Napqv2fwq-Q1TDpokavVLwO9sZjePUDeiGImJgcocFAdfJitJKbOdhB1Td_NokXm0DjZhuRQ4PAWaA==" \
	| grep -oE "ready for queries and writes" )
if [ "$state" == "ready for queries and writes" ];
then

	for zfile in ~/DataFiles/archpull/*.zip;
	do
		unzip "$zfile" -d ~/DataFiles/archpull/tmp
		#only format and import the files that match our locations
		for file in ~/DataFiles/archpull/tmp/MDSNWI1_pm15min*.csv;
		do
			judgefile "$file"
		done

		for file in ~/DataFiles/archpull/tmp/MDSNWI2_pm15min*.csv;
		do
			judgefile "$file"
		done

		for file in ~/DataFiles/archpull/tmp/MlLWWl1_pm15min*.csv;
		do
			judgefile "$file"
		done

		for file in ~/DataFiles/archpull/tmp/CHCGIL1_pm15min*.csv;
		do
			judgefile "$file"
		done

		for file in ~/DataFiles/archpull/tmp/STPLMN1_pm15min*.csv;
		do
			judgefile "$file"
		done
		rm ~/DataFiles/archpull/tmp/*.*
		echo "$zfile completed."

	done
	curl -X POST -H 'Content-type: application/json' --data '{"text":"Archpull completed."}' https://hooks.slack.com/services/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
	touch ~/DataFiles/archpull_cp	
	exit 1
fi
#if docker/influxdb is not running...alert and quit, no changes
#	curl -X POST -H 'Content-type: application/json' --data '{"text":"ALERT. Influxdb state: $state"}' https://hooks.slack.com/services/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
#exit 0
