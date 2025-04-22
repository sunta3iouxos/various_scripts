#!/bin/bash -l

#SBATCH --cpus-per-task=1
#SBATCH --mem=8gb
#SBATCH --time=10:00:00
#SBATCH --account=unikoeln
#SBATCH --output=/scratch/ccg-ngs/stdout/run_fastqc.sh.%j.stdouterr
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=sheuser@uni-koeln.de
#SBATCH --partition=ccg

#Input parameters
##1. directory

FQDIRECTORY=$1
OUTDIR=$2
I=$SLURM_ARRAY_TASK_ID
	
module load jdk/8u92-gcc-4.8.5-vb2ldsl
FASTQC=/projects-raptor/ccg-ngs/sw/FastQC/fastqc

INFILE=`ls $FQDIRECTORY/*.fastq.gz | tail -n +$I | head -n 1`
if [ -z $INFILE ]; then
	INFILE=`ls $FQDIRECTORY/*.fq.gz | tail -n +$I | head -n 1`
fi

mkdir -p $OUTDIR

echo "Calling $FASTQC $INFILE --outdir $OUTDIR"
$FASTQC $INFILE --outdir $OUTDIR
