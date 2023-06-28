#./import_ac1200_data.sh
#Import testing data from AC1200 into influxdb

for file in ~/DataFiles/AC1200_data/*.txt
do
	awk '{ sub("\r$", ""); print }' $file > input.txt
	curl --request POST "http://localhost:8086/api/v2/write?org=IPS_org&bucket=ac1200_bucket&precision=ns" \
  --header "Authorization: Token 9PVO0399Napqv2fwq-Q1TDpokavVLwO9sZjePUDeiGImJgcocFAdfJitJKbOdhB1Td_NokXm0DjZhuRQ4PAWaA==" \
  --data-binary @input.txt
  	echo "${file} done"
  	rm $file
done	
	
#curl --request POST "http://localhost:8086/api/v2/write?org=IPS_org&bucket=longhaul_bucket&precision=ns" \
