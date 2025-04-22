#!/bin/bash -l

#SBATCH --job-name=fastp
#SBATCH -A unikoeln
#SBATCH -p ccg,ccg-dragen
#SBATCH --cpus-per-task=8
#SBATCH --mem=8gb
#SBATCH --time=6:00:00
#SBATCH --output=/scratch/ccg-ngs/stdout/fastp_trim.sh.%j.stdout
#SBATCH -e /scratch/ccg-ngs/stdout/fastp_trim.sh.%j.stderr


#input from command line
FASTQ=$1
fileRead1=$2
fileRead2=$3
NOEXT1read1=$4
NOEXT1read2=$5
output=$6
trim_front=$7
trim_tail=$8
echo $output
echo $FASTQ
echo $fileRead1
#for the NEB-next kit use triming of 14 both fron and back due to the APOBEC treatment
# module
module use -p /projects-raptor/ccg-ngs/production/modules/miniconda3
module load miniconda3
eval "$(conda shell.bash hook)"
conda activate Bismark
if [[ -z ${trim_front} ]] && [[ -z ${trim_tail} ]]; then
fastp --in1 $FASTQ/$fileRead1 --in2 $FASTQ/$fileRead2 --html $output/$NOEXT1read1".html" -R $output/$NOEXT1read1".log" --out1 $output/$NOEXT1read1"._trim.fastq.gz" --out2 $output/$NOEXT1read2"._trim.fastq.gz" --trim_poly_g --trim_poly_x --length_required 16 --thread 8 --detect_adapter_for_pe -Q --correction
elif [[ -n ${trim_front} ]] && [[ -z ${trim_tail} ]]; then
fastp --in1 $FASTQ/$fileRead1 --in2 $FASTQ/$fileRead2 --html $output/$NOEXT1read1".html" -R $output/$NOEXT1read1".log" --out1 $output/$NOEXT1read1"._trim.fastq.gz" --out2 $output/$NOEXT1read2"._trim.fastq.gz" --trim_front1 $trim_front --trim_front2 $trim_front --trim_poly_g --trim_poly_x --length_required 16 --thread 8 --detect_adapter_for_pe -Q --correction
elif  [[ -z ${trim_front} ]] && [[ -n ${trim_tail} ]]; then
fastp --in1 $FASTQ/$fileRead1 --in2 $FASTQ/$fileRead2 --html $output/$NOEXT1read1".html" -R $output/$NOEXT1read1".log" --out1 $output/$NOEXT1read1"._trim.fastq.gz" --out2 $output/$NOEXT1read2"._trim.fastq.gz" --trim_tail1 $trim_tail --trim_tail2 $trim_tail --trim_poly_g --trim_poly_x --length_required 16 --thread 8 --detect_adapter_for_pe -Q --correction
elif [[ -n ${trim_front} ]] && [[ -n ${trim_tail} ]]; then
fastp --in1 $FASTQ/$fileRead1 --in2 $FASTQ/$fileRead2 --html $output/$NOEXT1read1".html" -R $output/$NOEXT1read1".log" --out1 $output/$NOEXT1read1"._trim.fastq.gz" --out2 $output/$NOEXT1read2"._trim.fastq.gz" --trim_front1 $trim_front --trim_tail1 $trim_tail --trim_front2 $trim_front --trim_tail2 $trim_tail --trim_poly_g --trim_poly_x --length_required 16 --thread 8 --detect_adapter_for_pe -Q --correction
fi
