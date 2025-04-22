#!/bin/bash -l

FQPATH=$1
outpath=$2
mkdir -p $outpath
for SID in $(ls -1 $FQPATH | awk '{split($0,a,"_"); print a[2]}' | uniq); do
	RNFB=$(ls -1 $FQPATH | awk '{split($0,a,"_"); print a[1]}' | uniq)
	echo ${SID}
	echo ${RNFB}
		for READ in R1 R2; do
		cat $FQPATH/*${SID}*${READ}*.fastq.gz > $outpath/${RNFB}_${SID}_${READ}.fastq.gz
        done
done

	#A006850205_174232_S11_L002_R1_001.fastq.gz