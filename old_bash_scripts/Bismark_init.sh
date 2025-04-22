#!/bin/bash -l

FASTQ=$1
output=$2
#genome_path=$3
echo "start..."
        i=$(find $FASTQ/ -maxdepth 1  -type f -name "*trim*")
        echo "paths are: ${i}"
        sample="$(ls -1 $i  | awk -F '/' '{print $NF}' | awk '{split($0,a,"_");print a[2]}' | uniq)"
        echo "set of samples="$sample

for SAMPLE in $sample
do
        RunID="$(echo ${i} |  awk -F '/' '{print $NF}' | awk '{split($0,a,"_");print a[1]}' | uniq)"
        echo RunID: ${RunID}
        echo SampleNum: ${SAMPLE}
        #echo Path and file: $FASTQ/${RunID}_${SAMPLE}".fq.gz"
        read1="$(find $FASTQ/${RunID}\_${SAMPLE}* -name '*R1*')"
	if [ -z "${read1}" ]; then
        	read1=$(find $FASTQ/${RunID}\_${SAMPLE}* -name '*_1.*')
	        if [ -z "${read1}" ]; then
        	        echo "no fastqs with ending fastq.gz or fq.gz"
                	exit
	        fi
	fi
        read2="$(find $FASTQ/${RunID}\_${SAMPLE}* -name '*R2*')"
        if [ -z "${read2}" ]; then
		read2=$(find $FASTQ/${RunID}\_${SAMPLE}* -name '*_2.*')
                if [ -z "${read2}" ]; then
                        echo "no fastqs with ending fastq.gz or fq.gz"
                        exit
                fi
        fi
        fileRead1=${read1##*/}
        fileRead2=${read2##*/}
        echo $fileRead1
        echo $fileRead2
        #NOEXTread1=${fileRead1%.*}
        #NOEXTread2=${fileRead2%.*}
        #NOEXT1read1=${NOEXTread1%.*}
        #NOEXT1read2=${NOEXTread2%.*}
        #echo $NOEXT1read1
        #echo $NOEXT1read2
        echo end..........
echo "sbatch bismark.sh /projects-raptor/ccg-ngs/production/public/species/Ecoli_K12_MG1655/ $FASTQ/$fileRead1 $FASTQ/$fileRead2 $output /scratch/ccg-ngs/tmp/"
sbatch bismark.sh /projects-raptor/ccg-ngs/production/public/species/Ecoli_K12_MG1655/ $FASTQ/$fileRead1 $FASTQ/$fileRead2 $output /scratch/ccg-ngs/tmp/ &
echo "sbatch bismark.sh /projects-raptor/ccg-ngs/production/public/species/lambda/ $FASTQ/$fileRead1 $FASTQ/$fileRead2 $output /scratch/ccg-ngs/tmp/"
sbatch bismark.sh /projects-raptor/ccg-ngs/production/public/species/lambda/ $FASTQ/$fileRead1 $FASTQ/$fileRead2 $output /scratch/ccg-ngs/tmp/ &
done
