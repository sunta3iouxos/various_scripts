#!/bin/bash  
shopt -s nullglob

file="$1" #the file where you keep your string name
CURRENTDATE=$(date +%Y%m%d)
echo $file
echo "number of files,total size of files,path" > /scratch/ccg-ngs/reports/storage/size_number_"${CURRENTDATE}".csv
	for folder in $(find "${file}" -mindepth 1 -maxdepth 2 -type d 2>/dev/null); do
        numbers=$(find "$folder" -type f 2>/dev/null | cut -d/ -f1 | sort | uniq -c)
        sizes=$(du -sh "$folder" 2>/dev/null | cut -f1)
        echo $((numbers+0))",""$sizes"",""$folder" >> /scratch/ccg-ngs/reports/storage/size_number_"${CURRENTDATE}".csv
		sort -h -o /scratch/ccg-ngs/reports/storage/size_number_"${CURRENTDATE}".csv  /scratch/ccg-ngs/reports/storage/size_number_"${CURRENTDATE}".csv
	done



