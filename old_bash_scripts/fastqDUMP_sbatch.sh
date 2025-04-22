#!/bin/bash

# Slurm Parameters
#SBATCH --job-name=fastDUMP
#SBATCH --cpus-per-task=6
#SBATCH --mem=10gb
#SBATCH --time=4:45:00
#SBATCH -A unikoeln
#SBATCH -p smp 
#SBATCH --output=/scratch/ccg-ngs/stdout/fasterqDUMP.sh.%j.stdoutout
#SBATCH -e /scratch/ccg-ngs/stdout/fasterqDUMP.sh.%j.stdout.err 
 
# #SBATCH --array=1-4    ## this is the important thing that is coupled with the inputFileName

conda activate entrez-direct

SRR=$1
tmp=$2
outdir=$3
mkdir -p $outdir
fasterq-dump $SRR --split-files  --temp $tmp --outdir $outdir
