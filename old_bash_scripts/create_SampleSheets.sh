#!/bin/bash
echo "Please enter the runfolder name"
echo "script will output new samplesheets with prefix"
parsejson(){

        JSON=$1
        TAG=$2

        if [ $(echo "$JSON" | grep \"$TAG\":{ | wc -l) -eq 1 ]; then
        VALUE=${JSON#*\"$TAG\":{}}
        VALUE=${VALUE%%\}*}
        elif [ $(echo "$JSON" | grep \""$TAG"\": | wc -l) -eq 1 ]; then
        VALUE=${JSON#*\"$TAG\":}
        VALUE=${VALUE%%,*}
        else
        VALUE="Error: $TAG not found in $JSON"
        fi
        echo "$VALUE"
	}
# this one will only provide number
#parsejson(){
#
#	JSON=$1
#	TAG=$2
#	if [ $(echo $JSON | grep \"$TAG\":{ | wc -l) -eq 1 ]; then
#		VALUE=${JSON#*\"$TAG\":{}}
#		VALUE=${VALUE%%\}*}
#		VALUE=$(echo $VALUE | grep -oP "\"[0-9]+\"" | cut -d'"' -f 2)
#	elif [ $(echo $JSON | grep \"$TAG\": | wc -l) -eq 1 ]; then
#		VALUE=${JSON#*\"$TAG\":}
#		VALUE=${VALUE%%,*}
#	VALUE=$(echo $VALUE | grep -oP "\"[0-9]+\"" | cut -d'"' -f 2)
#	else
#		VALUE="Error: $TAG not found in $JSON"
#	fi
#	echo $VALUE
#}

RUNFOLDER=$1/CCG_Pipeline
echo $RUNFOLDER
rm $RUNFOLDER/SampleSheet_*
DATA=0
while read LINE; do
	if [ $DATA -eq 1 ]; then
	EXTENSION=""
	HEADER="./header_no_trimming.txt"
	BARCODE1=`echo $LINE | cut -d , -f 4`
	BARCODE2=`echo $LINE | cut -d , -f 5`
	PROJECT=`echo $LINE | cut -d , -f 6`
	DESCRIPTION=`echo $LINE | awk '{split($0,a,",{"); print "{"a[2]}'`
	#description=$(grep ",$SID," /data/tmp/delivery/${RUNFOLDER}_SampleSheet.csv | awk '{split($0,a,",{"); print "{"a[2]}' | uniq)
	PIP_ID=`parsejson $DESCRIPTION PIP_ID`
	SAMPLE_TYPE_IDS=`parsejson $DESCRIPTION SAMPLE_TYPE_IDS`
	MPX_KIT_IDS=`parsejson $DESCRIPTION MPX_KIT_IDS`
#		echo $DESCRIPTION
#		echo PIP_ID=$PIP_ID
#		echo SAMPLE_TYPE_IDS=$SAMPLE_TYPE_IDS
#		echo MPX_KIT_IDS=$MPX_KIT_IDS
			
		if [ $PIP_ID == \"8\" ]; then	
			EXTENSION="ATLAS_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"50\":1* ]]; then
			EXTENSION="scRNAv2_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"77\":1* ]]; then
			EXTENSION="TellSeq_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"81\":1* ]] || [[ $SAMPLE_TYPE_IDS == *\"86\":1* ]]; then
			EXTENSION="SmartSeq3_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"61\":1* ]] || [[ $SAMPLE_TYPE_IDS == *\"72\":1* ]] || [[ $SAMPLE_TYPE_IDS == *\"102\":1* ]] || [[ $SAMPLE_TYPE_IDS == *\"84\":1* ]] ; then	
			EXTENSION="scRNAv3_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"67\":1* ]]; then	
			EXTENSION="scATAC_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"90\":1* ]] || [[ $SAMPLE_TYPE_IDS == *\"91\":1* ]] || [[ $SAMPLE_TYPE_IDS == *\"92\":1* ]] || [[ $SAMPLE_TYPE_IDS == *\"93\":1* ]]; then
			EXTENSION="scRNAv2prime5_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"113\":1* ]]; then	
			EXTENSION="SCRBseq_"
		i
		if [[ $MPX_KIT_IDS == *\"17\":1* ]] || [[ $MPX_KIT_IDS == *\"27\":1* ]] || [[ $MPX_KIT_IDS == *\"53\":1* ]]; then	
			EXTENSION="miRNA_"
		fi
		if [[ $MPX_KIT_IDS == *\"42\":1* ]]; then	
			EXTENSION="nugenSOLO_"
		fi
		if [[ $MPX_KIT_IDS == *\"61\":1* ]] || [[ $MPX_KIT_IDS == *\"62\":1* ]] ; then
			EXTENSION="IDT_UMI_"
		fi
		if [[ $MPX_KIT_IDS == *\"94\":1* ]] ; then
			EXTENSION="NEB_UMI_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"98\":1* ]]; then	
			EXTENSION="noMismatch_"
		fi
		if [[ $SAMPLE_TYPE_IDS == *\"99\":1* ]]; then
			EXTENSION="scmultiATAC_"
		fi
		if ([[ $MPX_KIT_IDS == *\"89\":1* ]] || [[ $MPX_KIT_IDS == *\"91\":1* ]] || [[ $MPX_KIT_IDS == *\"92\":1* ]] || [[ $MPX_KIT_IDS == *\"93\":1* ]]) && [[ SAMPLE_TYPE_IDS != *\"105\":1* ]] ; then
			EXTENSION="AGENTtrim_"
		fi
		if [ -z $BARCODE2 ]; then
			[ ! -f $RUNFOLDER/SampleSheet_${EXTENSION}${#BARCODE1}.csv ] && cp $HEADER $RUNFOLDER/SampleSheet_${EXTENSION}${#BARCODE1}.csv
			echo ${LINE%%\{*} >> $RUNFOLDER/SampleSheet_${EXTENSION}${#BARCODE1}.csv
		elif [ $BARCODE2 == "NNNNNNNNNN" ]; then
			[ ! -f $RUNFOLDER/SampleSheet_UMI1_${#BARCODE1}.csv ] && cp $HEADER $RUNFOLDER/SampleSheet_UMI1_${#BARCODE1}.csv
			echo ${LINE%%\{*} | awk '{gsub(",N*,",",,"); print}' >> $RUNFOLDER/SampleSheet_UMI1_${#BARCODE1}.csv
		elif [[ $EXTENSION = "IDT_UMI_" ]]; then
			[ ! -f $RUNFOLDER/SampleSheet_IDT_UMI_${#BARCODE1}-${#BARCODE2}.csv ] && cp $HEADER $RUNFOLDER/SampleSheet_IDT_UMI_${#BARCODE1}-${#BARCODE2}.csv
			echo ${LINE%%\{*} | awk '{gsub(/N/,""); print}' >> $RUNFOLDER/SampleSheet_IDT_UMI_${#BARCODE1}-${#BARCODE2}.csv
		elif [[ $EXTENSION = "NEB_UMI_" ]]; then
			[ ! -f $RUNFOLDER/SampleSheet_NEB_UMI_${#BARCODE1}-${#BARCODE2}.csv ] && cp $HEADER $RUNFOLDER/SampleSheet_NEB_UMI_${#BARCODE1}-${#BARCODE2}.csv
			echo ${LINE%%\{*} | awk '{gsub(/N/,""); print}' >> $RUNFOLDER/SampleSheet_NEB_UMI_${#BARCODE1}-${#BARCODE2}.csv
		else
			[ ! -f $RUNFOLDER/SampleSheet_${EXTENSION}${#BARCODE1}-${#BARCODE2}.csv ] && cp $HEADER $RUNFOLDER/SampleSheet_${EXTENSION}${#BARCODE1}-${#BARCODE2}.csv
			echo ${LINE%%\{*} >> $RUNFOLDER/SampleSheet_${EXTENSION}${#BARCODE1}-${#BARCODE2}.csv
		fi
#		echo $EXTENSION
	fi
	if [[ $LINE == Lane,* ]]; then
		DATA=1
	fi
done < $RUNFOLDER/SampleSheet.original
