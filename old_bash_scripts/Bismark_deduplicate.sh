#!/bin/bash -l

#SBATCH --job-name=Bismark
#SBATCH -A unikoeln
#SBATCH -p ccg,ccg-dragen
#SBATCH --cpus-per-task=4
#SBATCH --mem=10gb
#SBATCH --time=6:00:00
#SBATCH --output=/scratch/ccg-ngs/stdout/bismarkDedup.sh.%j.stdout
#SBATCH -e /scratch/ccg-ngs/stdout/bismarkDedup.sh.%j.stderr


#input from command line

BAM=$1  
OUTFILE=$2
suffix=$3i

mkdir -p ${OUTFILE}${suffix}
# module
module use -p /projects-raptor/ccg-ngs/production/modules/miniconda3
module load miniconda3
eval "$(conda shell.bash hook)"
conda activate Bismark

deduplicate_bismark --bam --output_dir ${OUTFILE}${suffix} $BAM