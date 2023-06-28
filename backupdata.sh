#!/usr/bin/bash

#./backupdata.sh
##TODO: place in crontab, run every ten days

## Copies over all files in nmslab and in RShake
## Removes files in home older than 21 days



## nmslab backup
for nmsfile in ~/DataFiles/nmslab/*.data;
do
	fname=$(basename -- "$nmsfile")
	fname1="${fname%.*}"
	fdate="${fname1: -6: 4}"
	backdir="/data/nmslab_archive/${fdate}"
	if [ ! -d "$backdir" ] ; then
		mkdir -p -- $backdir
	fi

	{
		cp -u "$nmsfile" "${backdir}/${fname}" &&
		echo "File backed up: ${nmsfile}" &&
		if [[ $(find "$nmsfile" -mtime +10 -print) ]]; then
  			rm "${nmsfile}"
  			echo "...and removed."
		fi

	} || {
		echo "File not copied: ${nmsfile}"
	}
done

## Rshake backup
year="2022"
shakes=( "EHE.D" "EHN.D" "EHZ.D" )
for shake in "${shakes[@]}";
do
	shakedir="/u/c/a/catudal/DataFiles/RShake/archive/${year}/AM/R5C2A/${shake}/*.*"
	for shakefile in ${shakedir};
	do
		fname=$(basename -- "$shakefile")
		fdate=${fname:23}
		#echo "fdate: ${fdate}"
		fdir=$((( 10#${fdate} / 30) * 30))
		backdir="/data/RShake_archive/${year}/${fdir}/${shake}"
		[ -d "$backdir" ] || mkdir -p "$backdir"
		{	

			cp -u "$shakefile" "${backdir}/${fname}" &&
			echo "File backed up: ${fname}" &&
			if [[ $(find "$shakefile" -mtime +10 -print) ]]; then
  				rm "$shakefile" 
  				echo "...and removed."
			fi

		} || {
			echo "File not copied: ${shakefile}"
		}
	done
done
curl -X POST -H 'Content-type: application/json' --data '{"text":"Backup done."}' https://hooks.slack.com/services/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
