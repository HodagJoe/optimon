#pulse_checker.py
#Will query influxDB and list every Measurement::OID::instance with a distinct value count > 1

import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS



#Setup InfluxDB API
bucket = "MADSN1"
org = "boreasnet"
token = "9gJ5vddPNPoiak9b4s4PVvW3DJDkP0jZSiGuL7xDVj7MkaEUrLjiNEmggpJaVULTw7-3cqb0bXJKuv6nTUqp0g=="
url="http://localhost:8086"

client = influxdb_client.InfluxDBClient(
   url=url,
   token=token,
   org=org
)


query_api = client.query_api()

measurement_dict = {	'BANDCTP' : 'bandCtp',
						'BMMOCGPTP' : 'bmmOcgPtp',
						'DCFPTP' : 'dcfPtp',
						'FEEDPTP' : 'feedPtp',
						'GIGECLINETCTP' : "gigeClientCtp", 
						'LMOCGPTP' : 'lmOcgPtp', 
						'OCHCTP' : 'ochCtp', 
						'ODU' : 'odu', 
						'ODUI' : 'odui',
						'OSCCTP' : 'oscCtp', 
						'OTSPTP' : 'otsPtp', 
						'OTUKI' : 'otuKi'}

for measurement, name in measurement_dict.items():
	query = ' from(bucket: "MADSN1")\
	  |> range(start: -7d)\
	  |> filter(fn: (r) => r["_measurement"] == "'+measurement+'")\
	  |> distinct()\
	  |> yield(name: "distinct") '

	result = query_api.query(org=org, query=query)

	for table in result:
	  for count, record in enumerate (table.records):
	    if (count==0):
	    	continue
	    print('INFINERA-PM-' + measurement + '-MIB::' + name + 'PmReal' + record.values.get('OID') + "." + record.values.get('ins'))
	    break
