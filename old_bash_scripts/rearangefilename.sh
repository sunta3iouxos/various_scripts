#!/bin/bash -l

 for i in $1/*.fastq.gz
do

 DIR=${i%/*}
 base1=${i##*/}
 NOEXT=${base1%.*}
 NOEXT1=${NOEXT%.*}


 A="$(echo $NOEXT1 | cut -d'_' -f1)"
 B="$(echo $NOEXT1 | cut -d'_' -f2)"
 C="$(echo $NOEXT1 | cut -d'_' -f3)"
 D="$(echo $NOEXT1 | cut -d'_' -f4)"
 E="$(echo $NOEXT1 | cut -d'_' -f5)"
 F="$(echo $NOEXT1 | cut -d'_' -f6)"
 
# mv $i $test/"A00001_"$A"_"$C"_L00"$B"_"$D"_"$E".fastq.gz"
#echo $base1 $B"_"$C"_"$D"_R3_"$F".fastq.gz"
# mv $DIR/$base1 $DIR/$B"_"$C"_"$D"_R3_"$F".fastq.gz"
echo cp -s $DIR/$base1 $DIR/$A"_"$B"_1.fq.gz"

done

#A006200100_127615_S10_L002_R2_001.fastq.gz 
#A006200100_127637_1.fq.gz