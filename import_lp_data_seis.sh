#./import_lp_data.sh

for file in ~/DataFiles/lp_data/*.lp
do
	curl --request POST "http://localhost:8086/api/v2/write?org=IPS_org&bucket=seismic_bucket&precision=ns" \
  --header "Authorization: Token 9PVO0399Napqv2fwq-Q1TDpokavVLwO9sZjePUDeiGImJgcocFAdfJitJKbOdhB1Td_NokXm0DjZhuRQ4PAWaA==" \
  --data-binary @$file
  	echo $file
  	rm $file
done	
	
