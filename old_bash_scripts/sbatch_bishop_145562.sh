#!/bin/bash

# Slurm Parameters
#SBATCH --job-name=fastqc
#SBATCH --cpus-per-task=1
#SBATCH --mem=1gb
#SBATCH --time=0:45:00
#SBATCH -A unikoeln
#SBATCH -p ccg-dragen
#SBATCH -o %j.out 
#SBATCH -e %j.err 
# #SBATCH --array=1-4    ## this is the important thing that is coupled with the inputFileName


module use -p /projects/ccg-ngs/modules/rnapipeline/
#1618944118
module load condaenv/v1.2019
#1618944121
source activate /projects-raptor/ccg-ngs/sw/BSseeker3/Bseeker_en

bismark --parallel 8 --genome /projects/ccg-ngs/public/Annotations/puc19/ -1 /projects-raptor/ccg-ngs/fastq/UJ01/A006850134_145562_S1_L001_R1_001.trim.fastq.gz -2 /projects-raptor/ccg-ngs/fastq/UJ01/A006850134_145562_S1_L001_R2_001.fastq.trim.fastq.gz -o /scratch/UJ01/puc19_trim_145562/ --temp_dir /scratch/nf_tmp/