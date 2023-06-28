#!/usr/bin/bash

#./hourlypull.sh
#placed in crontab, this runs every hour
#pull from the lab machine, and compare hashes of last modified file
#alert if there is no change

cd ~/DataFiles
#create time touchpoint
touch hourlypull_cp -d "1 minute ago"

#cron runs in different environment than CLI and needs path to key
rsync -av -e "ssh -i /u/c/a/catudal/.ssh/id_rsa_np -T -l wej" wej@nms-lab.boreas.net:~/joec/longhaul/ ~/DataFiles/nmslab/

	for file in ~/DataFiles/nmslab/lab1_*.data;
	do
		if [ ~["$file" -nt hourlypull_cp] ];
		then
			#VERBOSE notice when confirmed working
			curl -X POST -H 'Content-type: application/json' --data '{"text":"Lab1 not reporting!"}' https://hooks.slack.com/services/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
  		fi
	done
	
	for file in ~/DataFiles/nmslab/*.data;
	do
		if [ "$file" -nt hourlypull_cp ];
		then
			#VERBOSE notice when confirmed working
			#curl -X POST -H 'Content-type: application/json' --data '{"text":"Pull successful."}' https://hooks.slack.com/services/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
			rm hourlypull_cp
			exit 1
  		fi
	done

#If script hasn't exited, then no files were changed in rsync
	curl -X POST -H 'Content-type: application/json' --data '{"text":"ALERT: Pull not made."}' https://hooks.slack.com/services/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

rm hourlypull_cp
