#!/bin/bash -l
echo	"use full path as folders arguments:
	./rename_forRNAseq.sh /project/ccg-ngs/fastq/PROJECT_INPUT /WHERE/YOU/WANT/IT/PROJECT_OUTPUT
	folder 1 can be the same as folder 2. this script will only create a sylink"

PATH2=$2
#ssh raptor1.rrz.uni-koeln.de 'mkdir -p $PATH2'
for i in $1/*.fastq.gz
do

 DIR=${i%/*}
 base1=${i##*/}
 NOEXT=${base1%.*}
 NOEXT1=${NOEXT%.*}
echo $A
echo $B
echo $i

 A="$(echo $NOEXT1 | cut -d'_' -f1)"
 B="$(echo $NOEXT1 | cut -d'_' -f2)"
 C="$(echo $NOEXT1 | cut -d'_' -f3)"
 D="$(echo $NOEXT1 | cut -d'_' -f4)"
 E="$(echo $NOEXT1 | cut -d'_' -f5)"
 F="$(echo $NOEXT1 | cut -d'_' -f6)"
 
if [ $E == "R1" ]; then
#echo "remove existing ln"
echo rm $PATH2/$A"_"$B"_1.fq.gz"
rm $PATH2/$A"_"$B"_1.fq.gz"
echo ln -nfs $DIR/$base1 $PATH2/$A"_"$B"_1.fq.gz"
ln -nfs  $DIR/$base1 $PATH2/$A"_"$B"_1.fq.gz"
elif [ $E == "R2" ]; then
#echo "remove existing ln"
#echo "rm $PATH2/$A"_"$B"_2.fq.gz"
rm $PATH2/$A"_"$B"_2.fq.gz"
echo ln -nfs $DIR/$base1 $PATH2/$A"_"$B"_2.fq.gz"
ln -nfs $DIR/$base1 $PATH2/$A"_"$B"_2.fq.gz"
else
echo "failed finding correct filename"
fi

done

#A006200100_127615_S10_L002_R2_001.fastq.gz 
#A006200100_127637_1.fq.gz
