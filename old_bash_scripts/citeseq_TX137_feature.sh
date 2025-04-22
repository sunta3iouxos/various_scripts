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
mkdir -p /projects-raptor/ccg-ngs/tmp/cellranger/TX137_hg38_PRID4794_5prim_26/CITE_feature/

CITE-seq-Count -R1 /projects/ccg-ngs/fastq/TX137/A006200136_141701_S2_L003_R1_001.fastq.gz,/projects/ccg-ngs/fastq/TX137/A006200136_141701_S2_L004_R1_001.fastq.gz -R2 /projects/ccg-ngs/fastq/TX137/A006200136_141701_S2_L003_R2_001.fastq.gz,/projects/ccg-ngs/fastq/TX137/A006200136_141701_S2_L004_R2_001.fastq.gz -t /projects-raptor/ccg-ngs/tmp/cellranger/TX137_hg38_PRID4794_5prim/TX137_feature_CITE.csv -u /projects-raptor/ccg-ngs/tmp/cellranger/TX137_hg38_PRID4794_5prim/CITE_feature/unmapped.csv -cbf 1 -cbl 16 -umif 17 -umil 26 -o /projects-raptor/ccg-ngs/tmp/cellranger/TX137_hg38_PRID4794_5prim_26/CITE_feature/ --expected_cells 20000 -wl /projects-raptor/ccg-ngs/tmp/cellranger/TX137_hg38_PRID4794_5prim/SID141700/barcodes.csv -T 20

#-R1 read one of the CMO-ADT fastq
#-R2 read one of the CMO-ADT fastq
#-t 