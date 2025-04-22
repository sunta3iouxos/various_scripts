#!/bin/bash -l 


#SBATCH --mem=120gb
#SBATCH --time=148:00:00
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
mkdir -p /scratch/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/SID154136/CITE_CMOADT9/

CITE-seq-Count -R1 /projects-raptor-old/ccg-ngs/fastq/TX160/A006850155_154319_S21_L001_R1_001.fastq.gz,/projects-raptor-old/ccg-ngs/fastq/TX160/A006850155_154319_S21_L003_R1_001.fastq.gz,/projects-raptor-old/ccg-ngs/fastq/TX160/A006850155_154319_S21_L002_R1_001.fastq.gz,/projects-raptor-old/ccg-ngs/fastq/TX160/A006850155_154319_S21_L004_R1_001.fastq.gz -R2 /projects-raptor-old/ccg-ngs/fastq/TX160/A006850155_154319_S21_L001_R2_001.fastq.gz,/projects-raptor-old/ccg-ngs/fastq/TX160/A006850155_154319_S21_L003_R2_001.fastq.gz,/projects-raptor-old/ccg-ngs/fastq/TX160/A006850155_154319_S21_L002_R2_001.fastq.gz,/projects-raptor-old/ccg-ngs/fastq/TX160/A006850155_154319_S21_L004_R2_001.fastq.gz -t /projects-raptor-old/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/TX160_CMO_ADT_CITE.csv -u /scratch/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/SID154136/CITE_CMOADT9/unmapped.csv -cbf 1 -cbl 16 -umif 17 -umil 26 -o /scratch/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/SID154136/CITE_CMOADT9/ --expected_cells 16380 -wl /projects-raptor-old/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/SID154136/outs/filtered_feature_bc_matrix/barcodes.tsv -T 20 --start-trim 9 --sliding-window
