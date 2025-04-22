#!/bin/bash -l
inputDIR=$1
outputDIR=$2 #path of project
mkdir -p $outputDIR
 FASTQS=$(find $inputDIR/ -type f -name *".fastq.gz")
#        echo "paths are: ${FASTQS}"
         sample="$(ls -1 $FASTQS  | awk -F '/' '{print $NF}' | awk '{split($0,a,"_");print a[2]}' | uniq)"
        echo "set of samples="$sample

for SAMPLE in $sample; do
    RunID="$(echo ${FASTQS} |  awk -F '/' '{print $NF}' | awk '{split($0,a,"_");print a[1]}' | uniq)"
       echo RunID: ${RunID}
       echo SampleNum: ${SAMPLE}
    #    echo Path and file: $inputDIR/${RunID}_${SAMPLE}".fq.gz"
    #    echo "..."
        read1="$(find $inputDIR/${RunID}\_${SAMPLE}*fastq.gz -name '*R1*')"
        read2="$(find $inputDIR/${RunID}\_${SAMPLE}*fastq.gz -name '*R2*')"
     #   fileRead1=${read1##*/}
        echo "read1 is $read1"
        echo "ln -s $read1 ${outputDIR}/${RunID}_${SAMPLE}_1.fq.gz"
	ln -s $read1 ${outputDIR}/${RunID}_${SAMPLE}_1.fq.gz
     #       A1="$(echo $fileRead1 | cut -d'_' -f1)" #RunID
     #       B1="$(echo $fileRead1 | cut -d'_' -f2)" #sample
     #       C1="$(echo $fileRead1 | cut -d'_' -f3)" #S
     #       D1="$(echo $fileRead1 | cut -d'_' -f4)" #Lane
     #       E1="$(echo $fileRead1 | cut -d'_' -f5)" #Read
     #       F1="$(echo $fileRead1 | cut -d'_' -f6)" #001.fastq.gz
     #       echo "part of the filename: $A1 $B1 $C1 $D1 $E1 $F1 "
     #       fileRead2=${read2##*/}
        if [[ -z ${read2} ]]; then
	echo "no read2 nothing to do"
	else
	echo "read2 is $read2 "
        echo "ln -s $read1 ${outputDIR}/${RunID}_${SAMPLE}_2.fq.gz"
	ln -s $read1 ${outputDIR}/${RunID}_${SAMPLE}_2.fq.gz
    #        A2="$(echo $fileRead2 | cut -d'_' -f1)" #RunID
    #        B2="$(echo $fileRead2 | cut -d'_' -f2)" #sample
    #        C2="$(echo $fileRead2 | cut -d'_' -f3)" #S
    #        D2="$(echo $fileRead2 | cut -d'_' -f4)" #Lane
    #        E2="$(echo $fileRead2 | cut -d'_' -f5)" #Read
    #        F2="$(echo $fileRead2 | cut -d'_' -f6)" #001.fastq.gz
    #        echo "part of the filename: $A2 $B2 $C2 $D2 $E2 $F2 "
	fi
done
