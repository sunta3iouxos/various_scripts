#!/bin/bash -l

FQDIR=$1
OUTDIR=$2
BATCHSIZE=$3
START=$4

TOTALFILES=`ls $FQDIR/*.fq.gz | wc -l`

I=$START
for I in `seq $I $BATCHSIZE $TOTALFILES`; do
	sbatch --array $I-$(( I+BATCHSIZE-1 )) /usr/local/ccg-ngs/scripts/run_fastqc.sh --no-group $FQDIR $OUTDIR
	sleep 2h
done
