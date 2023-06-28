#!/usr/bin/bash

for file in /home/wej/joec/longhaul/*.data;
	do
		if [[ $(find "$file" -mtime +5 -print) ]]; then
	  			rm -f "${file}"
		fi
	done
echo "doneskis."
