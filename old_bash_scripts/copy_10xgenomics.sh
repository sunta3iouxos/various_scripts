#!/bin/bash -l
inputDIR=$1
outputDIR=$2 #path of project
mkdir -p $outputDIR/fastq/
for src in $inputDIR*.fastq.gz; do
        FILENAME=${src##*/}
        dst=${FILENAME#*_}
        while [[ -e "$outputDIR/fastq/$dst" ]]; do
                n=${dst#*_S}
                n=$(( ${n%%_*} + 1 ))
                dst=${dst%%S*}S${n}_${dst#*_*_}
        done
        echo "ln -s  $src $outputDIR/fastq/$dst"
        cp "$src" "$outputDIR/fastq/$dst"
done
