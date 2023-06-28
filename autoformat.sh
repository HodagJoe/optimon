#./autoformat.sh

for file in ~/DataFiles/nmslab/*19.data;
do
	./format_influx.pl $file
  	./import_lp_data.sh
done	
