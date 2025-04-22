#!/bin/bash

echo "query_samplesheet..."
echo "HiSeq4000 or NovaSeq"
RUNFOLDER=$1
TYPE=$2
EXIT_STATE=`ssh anubis2.ccg.uni-koeln.de "/data/Varpipe3.0/scripts/query_samplesheet_3.2.sh $RUNFOLDER $TYPE"`
echo "EXIT_STATE=$EXIT_STATE"
if [ -z $EXIT_STATE ]; then
	ERRORCODE=1
	echo "Error writing samplesheet for $RUNFOLDER."
	MSG="Error writing samplesheet for $RUNFOLDER."
	continue
fi
mkdir  -p ${RUNFOLDER}/CCG_Pipeline/
rsync --no-p --no-g --chmod=ugo=rwX anubis2.ccg.uni-koeln.de:/data/tmp/ccg-ngs/${RUNFOLDER}_SampleSheet.csv ${RUNFOLDER}/CCG_Pipeline/SampleSheet.original

