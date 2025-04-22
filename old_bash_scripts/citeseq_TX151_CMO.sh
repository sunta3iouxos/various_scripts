#!/bin/bash -l 

#SBATCH --mem=100gb
#SBATCH --time=168:00:00
#SBATCH --cpus-per-task=20
#SBATCH --partition=ccg
#SBATCH --account=unikoeln
#SBATCH --output=/scratch/ccg-ngs/stdout/CITEseq.sh.%j.stdoutout
#SBATCH -e /scratch/ccg-ngs/stdout/CITEseq.sh.%j.stdout.err 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=tgeorgom@uni-koeln.de
#SBATCH --job-name=CITEseq

# Input

conda activate kite
mkdir -p /scratch/ccg-ngs/results/TX151_hg38_PRID4986_5prim_26/SID149044/CITE_CMO/

CITE-seq-Count -R1 /projects/ccg-ngs/fastq/TX151/A006200151_149045_S2_L001_R1_001.fastq.gz,/projects/ccg-ngs/fastq/TX151/A006200151_149045_S2_L002_R1_001.fastq.gz -R2 /projects/ccg-ngs/fastq/TX151/A006200151_149045_S2_L001_R2_001.fastq.gz,/projects/ccg-ngs/fastq/TX151/A006200151_149045_S2_L002_R2_001.fastq.gz -t /projects-raptor/ccg-ngs/tmp/cellranger/TX151_hg38_PRID4986_5prim/TX151_CMO_CITE.csv -u /scratch/ccg-ngs/results/TX151_hg38_PRID4986_5prim_26/SID149044/CITE_CMO/unmapped.csv -cbf 1 -cbl 16 -umif 17 -umil 26 -o /scratch/ccg-ngs/results/TX151_hg38_PRID4986_5prim_26/SID149044/CITE_CMO/ --expected_cells 7000 -wl /projects-raptor/ccg-ngs/tmp/cellranger/TX151_hg38_PRID4986_5prim_26/SID149044/outs/filtered_feature_bc_matrix/barcodes.tsv -T 20 -T 20 --start-trim 9 --sliding-window
