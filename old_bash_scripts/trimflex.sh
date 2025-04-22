 #!/bin/bash
FASTQ=$1

	i="$(ls $FASTQ/*.fastq.gz)"
	echo "paths are: ${i}"
	 sample="$(ls -1 $FASTQ/*  | awk '{split($0,a,"/");print a[4]}' | awk '{split($0,a,"_");print a[2]}' | uniq)"
	echo "set of samples="$sample

for SAMPLE in $sample
do
	RunID="$(echo ${i} |  awk '{split($0,a,"/");print a[4]}' | awk '{split($0,a,"_");print a[1]}' | uniq)"
	#SAMPLE
	#runID="$(echo ${i} |  awk '{split($0,a,"/");print a[2]}' | awk '{split($0,a,"_");print a[1]}' | uniq)"
	#sampleID="$(echo ${i} |  awk '{split($0,a,"/");print a[2]}' | awk '{split($0,a,"_");print a[2]}' | uniq)"
	echo ${RunID}
	#echo ${SID}
	echo ${SAMPLE}
	echo $FASTQ/${RunID}_${SAMPLE}".fq.gz"
	echo "..."
	read1="$(find $FASTQ/${RunID}\_${SAMPLE}* -name '*R1*')"
	read2="$(find $FASTQ/${RunID}\_${SAMPLE}* -name '*R2*')"
	fileRead1=${read1##*/}
	fileRead2=${read2##*/}
	echo $fileRead1
	echo $fileRead2
	NOEXTread1=${fileRead1%.*}
	NOEXTread2=${fileRead2%.*}
	NOEXT1read1=${NOEXTread1%.*}
	NOEXT1read2=${NOEXTread2%.*}
	echo $NOEXT1read1
	echo $NOEXT1read2

echo "flexbar --reads $1/${fileRead1}  --reads2 $1/${fileRead2} --stdout-reads --adapters tso_g_wo_hp.fasta --adapter-trim-end LEFT --adapter-revcomp ON --adapter-revcomp-end RIGHT --htrim-left GT --htrim-right CA --htrim-min-length 3 --htrim-max-length 5 --htrim-max-first --htrim-adapter --min-read-length 2 --threads 1 | flexbar --reads - --interleaved  -R  $FASTQ/${RunID}_${SAMPLE}_1.fq.gz -P $FASTQ/${RunID}_${SAMPLE}_2.fq.gz --adapters ilmn_20_2_seqs.fasta --adapter-trim-end RIGHT --min-read-length 2 --threads 1 "
flexbar --reads $1/${fileRead1}  --reads2 $1/${fileRead2} --stdout-reads --adapters tso_g_wo_hp.fasta --adapter-trim-end LEFT --adapter-revcomp ON --adapter-revcomp-end RIGHT --htrim-left GT --htrim-right CA --htrim-min-length 3 --htrim-max-length 5 --htrim-max-first --htrim-adapter --min-read-length 2 --threads 1 | flexbar --reads - --interleaved  -R  $FASTQ/${RunID}_${SAMPLE}"_1.fq.gz" -P $FASTQ/${RunID}_${SAMPLE}"_2.fq.gz" --adapters ilmn_20_2_seqs.fasta --adapter-trim-end RIGHT --min-read-length 2 --threads 1 &

done
