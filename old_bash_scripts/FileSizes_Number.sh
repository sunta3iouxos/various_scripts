#!/bin/bash  
#shopt -s nullglob

file="$1" #the file where you keep your string name
CURRENTDATE=$(date +%Y%m%d)
#mkdir -p /scratch/ccg-ngs/reports/storage/
EXPORT=$2
echo "number of files,total size of files,path" > $EXPORT/size_number_"${CURRENTDATE}".csv
while IFS='' read -r directorys ; do
	echo folder= $directorys
        	folders=$(find "${directorys}" -mindepth 1 -maxdepth 2 -type d 2>/dev/null)
#	echo $folders
	for folder in $folders; do
#		echo $folder
			numbers=$(find "$folder" -type f 2>/dev/null | cut -d/ -f1 | sort | uniq -c)
#		echo $numbers
			sizes=$(du -sh "$folder" 2>/dev/null | cut -f1)
#		echo $sizes
			echo $((numbers+0))",""$sizes"",""$folder" >> $EXPORT/size_number_"${CURRENTDATE}".csv
			#sort -h -o $EXPORT/size_number_"${CURRENTDATE}".csv  $EXPORT/size_number_"${CURRENTDATE}".csv
	done
done < $file


