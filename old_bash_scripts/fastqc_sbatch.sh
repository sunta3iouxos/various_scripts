#!/bin/bash

# Slurm Parameters
#SBATCH --job-name=fastqc
#SBATCH --cpus-per-task=1
#SBATCH --mem=1gb
#SBATCH --time=0:45:00
#SBATCH -A unikoeln
#SBATCH -p ccg
#SBATCH --output=/scratch/ccg-ngs/stdout/fastqSBATCH.sh.%j.stdoutout
#SBATCH -e /scratch/ccg-ngs/stdout/fastqSBATCH.sh.%j.stdout.err 
 
# #SBATCH --array=1-4    ## this is the important thing that is coupled with the inputFileName


fastqfile=$1
outdir=$2
module load jdk
FASTQC=/projects/ccg-ngs/sw/FastQC/fastqc
mkdir -p $outdir

echo "$FASTQC -t 1 --nogroup --outdir $outdir $fastqfile"
$FASTQC -t 1 --nogroup --outdir $outdir $fastqfile 
