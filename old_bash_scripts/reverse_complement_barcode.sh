#!/bin/bash

SAMPLESHEET=$1
BARCODE=$2

function rrev() {
	case $1 in
		"T")
		echo -n A
		;;
		"A")
		echo -n T
		;;
		"G")
		echo -n C
		;;
		"C")
		echo -n G
		;;
	esac
}

DATA=0
while read LINE; do
	if [ $DATA -eq 1 ]; then
		[ $BARCODE -eq 1 ] && COLUMN=4
		[ $BARCODE -eq 2 ] && COLUMN=5		
        	DNA=`echo $LINE | cut -d , -f $COLUMN`
		REVERSED=`echo $DNA | rev`
		REVCOMP=""
		for I in $(seq 0 $((${#DNA}-1))); do
		        REVCOMP="${REVCOMP}`rrev ${REVERSED:$I:1};`"
		done
		if [ $BARCODE -eq 1 ]; then
			echo $LINE | awk -F "," -v bc=$REVCOMP '{print $1","$2","$3","bc","$5","$6","}' >> $SAMPLESHEET.revcomp
		elif [ $BARCODE -eq 2 ]; then
			echo $LINE | awk -F "," -v bc=$REVCOMP '{print $1","$2","$3","$4","bc","$6","}' >> $SAMPLESHEET.revcomp
		fi
	else
		echo $LINE >> $SAMPLESHEET.revcomp
	fi

	if [[ $LINE == Lane,* ]]; then
	        DATA=1
        fi
done < $SAMPLESHEET
