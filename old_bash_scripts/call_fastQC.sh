#!/bin/bash -l

for i in $1/*.fastq.gz
do

 DIR=${i%/*}

echo fastqc_sbatch.sh $DIR $i
 
done
