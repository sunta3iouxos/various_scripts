#!/bin/bash -l 

#SBATCH --cpus-per-task=24
#SBATCH --mem=32gb
#SBATCH --time=24:00:00
#SBATCH -p ccg,ccg-dragen
#SBATCH --output=/scratch/ccg-ngs/stdout/BismarkINDEX.sh.%j.stdoutout
#SBATCH -e /scratch/ccg-ngs/stdout/BismarkINDEX.sh.%j.stdout.err 
#SBATCH --job-name=Bismark
#SBATCH -A unikoeln

echo "bismark_genome_preparation --bowtie2 --parallel 24 /projects/ccg-ngs/production/public/species/puc19/ "
# Input
echo "activate conda"
module use -p /projects-raptor/ccg-ngs/production/modules/miniconda3
module load miniconda3
eval "$(conda shell.bash hook)"
conda activate Bismark

bismark_genome_preparation --bowtie2 --parallel 24 /projects/ccg-ngs/production/public/species/puc19/ 
