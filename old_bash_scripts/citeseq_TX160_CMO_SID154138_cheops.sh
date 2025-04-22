#!/bin/bash -l 

#SBATCH --mem=200gb
#SBATCH --time=148:00:00
#SBATCH --cpus-per-task=20
#SBATCH --partition=smp
# #SBATCH --account=unikoeln
#SBATCH --account=ccg-ngs
#SBATCH --output=/scratch/ccg-ngs/stdout/CITEseq.sh.%j.stdoutout
#SBATCH -e /scratch/ccg-ngs/stdout/CITEseq.sh.%j.stdout.err 
# #SBATCH --mail-type=ALL
# #SBATCH --mail-user=tgeorgom@uni-koeln.de
#SBATCH --job-name=CITEseq

# Input

#conda activate kite
conda activate citeSeq

mkdir -p /projects/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/SID154138/CITE_CMOb/

CITE-seq-Count -R1 /projects/ccg-ngs/fastq/TX160/A006850155_154321_S23_L001_R1_001.fastq.gz,/projects/ccg-ngs/fastq/TX160/A006850155_154321_S23_L003_R1_001.fastq.gz,/projects/ccg-ngs/fastq/TX160/A006850155_154321_S23_L002_R1_001.fastq.gz,/projects/ccg-ngs/fastq/TX160/A006850155_154321_S23_L004_R1_001.fastq.gz -R2 /projects/ccg-ngs/fastq/TX160/A006850155_154321_S23_L001_R2_001.fastq.gz,/projects/ccg-ngs/fastq/TX160/A006850155_154321_S23_L003_R2_001.fastq.gz,/projects/ccg-ngs/fastq/TX160/A006850155_154321_S23_L002_R2_001.fastq.gz,/projects/ccg-ngs/fastq/TX160/A006850155_154321_S23_L004_R2_001.fastq.gz -t /projects/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/TX160_CMO_CITE.csv -u /projects/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/SID154138/CITE_CMOb/unmapped.csv -cbf 1 -cbl 16 -umif 17 -umil 26 -o /projects/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/SID154138/CITE_CMOb/ --expected_cells 24915 -wl /projects/ccg-ngs/results/TX160_hg38_PRID4794_5prim_26/SID154138/outs/filtered_feature_bc_matrix/barcodes.tsv -T 20 --start-trim 10 --sliding-window
