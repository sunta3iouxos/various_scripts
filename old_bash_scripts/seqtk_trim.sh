#!/bin/bash -l
#SBATCH --cpus-per-task=2
#SBATCH --mem=2gb
#SBATCH --time=1:00:00
#SBATCH --account=cgg-ngs
#SBATCH --output=/scratch/ccg-ngs/stdout/seqkt.sh.%j.stdouterr
# #SBATCH --mail-type=ALL
# #SBATCH --mail-user=tgeorgom@uni-koeln.de
#SBATCH --array=1-2

#INFILE=$1
#INFILE=/somthing/input/"${SLURM_ARRAY_TASK_ID}".txt
#while IFS=, read col1; do
#echo "trim file:" $INFILE
#while IFS=, read col1; do 
export PATH=$PATH:/projects/ccg-ngs/sw/seqtk/
inputFileName="/projects/ccg-ngs/fastq/LR05_CNV/"${SLURM_ARRAY_TASK_ID}".txt"
fastqfile=`sed '1q;d' $inputFileName`
base1=${fastqfile##*/}
path1=${fastqfile%/*}
NOEXT1=${base1%.*}
seqtk trimfq -b 21 $fastqfile > $path1/$NOEXT1"_trimmed21.fastq"



# done < $INFILE
