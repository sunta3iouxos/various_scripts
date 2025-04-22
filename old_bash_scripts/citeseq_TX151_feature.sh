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
mkdir -p /projects-raptor/ccg-ngs/tmp/cellranger/TX151_hg38_PRID4986_5prim_26/SID149044/CITE_feature/
CITE-seq-Count -R1 /projects/ccg-ngs/fastq/TX151/A006200151_149045_S2_L001_R1_001.fastq.gz,/projects/ccg-ngs/fastq/TX151/A006200151_149045_S2_L002_R1_001.fastq.gz -R2 /projects/ccg-ngs/fastq/TX151/A006200151_149045_S2_L001_R2_001.fastq.gz,/projects/ccg-ngs/fastq/TX151/A006200151_149045_S2_L002_R2_001.fastq.gz -t /projects-raptor/ccg-ngs/tmp/cellranger/TX151_hg38_PRID4986_5prim/TX151_feature_CITEseqCount.csv -u /projects-raptor/ccg-ngs/tmp/cellranger/TX151_hg38_PRID4986_5prim/SID149044/CITE_feature/unmapped.csv -cbf 1 -cbl 16 -umif 17 -umil 26 -o /projects-raptor/ccg-ngs/tmp/cellranger/TX151_hg38_PRID4986_5prim_26/SID149044/CITE_feature/ --expected_cells 7000 -wl /projects-raptor/ccg-ngs/tmp/cellranger/TX151_hg38_PRID4986_5prim/SID149044/outs/barcodes.tsv -T 20
