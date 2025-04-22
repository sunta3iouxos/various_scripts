#!/bin/bash -l

#SBATCH --job-name=Bismark
#SBATCH -A unikoeln
#SBATCH -p ccg,ccg-dragen
#SBATCH --cpus-per-task=20
#SBATCH --mem=50gb
#SBATCH --time=6:00:00
#SBATCH --output=/scratch/ccg-ngs/stdout/bismarkMAP.sh.%j.stdout
#SBATCH -e /scratch/ccg-ngs/stdout/bismarkMAP.sh.%j.stderr


#input from command line

genome_path=$1
genome_path=${genome_path%/*}
suffix=${genome_path##*/}
FQ1=$2  
FQ2=$3
OUTFILE=$4
TMP=$5

echo "bismark --multicore 4 --parallel 4 --genome $genome_path -1 $FQ1  -2 $FQ2 --output_dir ${OUTFILE}${suffix} --temp_dir $TMP"
mkdir -p ${OUTFILE}${suffix}
mkdir -p ${TMP}/${suffix}
# module
module use -p /projects-raptor/ccg-ngs/production/modules/miniconda3
module load miniconda3
eval "$(conda shell.bash hook)"
conda activate Bismark

bismark --multicore 4 --parallel 4 --genome $genome_path -1 $FQ1  -2 $FQ2 --output_dir ${OUTFILE}/${suffix} --temp_dir $TMP/${suffix}_${SLURM_JOB_ID}

