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

INFILE=$1
OUTDIR=$2
	
module load jdk/8u92-gcc-4.8.5-vb2ldsl
FASTQC=/projects-raptor/ccg-ngs/sw/FastQC/fastqc

mkdir -p $OUTDIR

echo "Calling $FASTQC $INFILE --outdir $OUTDIR"
$FASTQC $INFILE --outdir $OUTDIR
