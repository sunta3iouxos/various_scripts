#!/bin/bash -l

for i in $1/*.fastqc.gz
do

 DIR=${i%/*}
 base1=${i##*/}
 NOEXT=${base1%.*}
 NOEXT1=${NOEXT%.*}


mv $i $DIR/$NOEXT1"fastq.gz"

done
