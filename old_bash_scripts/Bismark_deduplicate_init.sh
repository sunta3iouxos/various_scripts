#!/bin/bash -l

BAM=$1
output=$2

echo "start..."
        i=$(find $BAM -maxdepth 1  -type f -name *"bam")
        echo "paths are: ${i}"
        samples="$(ls -1 $i  | awk -F '/' '{print $NF}' | awk '{split($0,a,"_");print a[2]}' | uniq)"
        echo "set of samples="$samples

for SAMPLE in $samples; do
        RunID="$(echo ${i} |  awk -F '/' '{print $NF}' | awk '{split($0,a,"_");print a[1]}' | uniq)"
        suffix=${i%/*}
        echo $suffix
        prefix=${suffix##*/}
        echo $prefix
        echo RunID: ${RunID}
        echo SampleNum: ${SAMPLE}
        read1="$(find $BAM/${RunID}\_${SAMPLE}* -name '*R1*bam')"
        fileRead1=${read1##*/}
        echo file read 1: $fileRead1
        NOEXTread1=${fileRead1%%_R*}
        echo $NOEXTread1
        echo end..........
        echo "Bismark_deduplicate.sh $BAM/$fileRead1 $output $prefix"
        sbatch Bismark_deduplicate.sh $BAM/$fileRead1 $output $prefix
done