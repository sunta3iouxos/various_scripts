#!/bin/bash -l
DIR2=$2
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


echo ".."
#SNUM=(${C:1})
echo $SNUM
#NUM=$((SNUM+2))
echo $NUM
echo ".."

cp -s $DIR/$base1 $DIR2/$B"_"$C"_"$D"_"$E"_"$F".fastq.gz"
echo "cp -s $DIR/$base1 $DIR/$B"_"$C"_"$D"_"$E"_"$F".fastq.gz""

# echo $base1 $A"_"$B"_"$C"_"$D"_R3_"$F".fastq.gz"
#echo "$DIR/$base1 $DIR/$A"_"$B"_S"$NUM"_"$D"_"$E"_"$F".fastq.gz""
#mv $DIR/$base1 $DIR/$A"_"$B"_S"$NUM"_"$D"_"$E"_"$F".fastq.gz"
done
