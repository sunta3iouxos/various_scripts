#!/bin/bash
#set -euo pipefail

anubis=hthiele0@anubis2.ccg.uni-koeln.de:/data/html/ngs_reports/10x
project=$1
PRID=$2
inFolder=$3
root=/projects-raptor/ccg-ngs/production/PRID/$project/results/


if [ -z "${project}" ] || [ -z "${PRID}" ] ||  [ -z "${inFolder}" ]
   then
        echo "set as first variable the project name, as second the PRID, as third the name of the folder in results"
   else
        echo "$project, $PRID, $inFolder"
fi

CELLRANGER=$(ls $root | grep ranger )
echo $CELLRANGER
if [ $CELLRANGER == "cellranger" ] ; then
	root=$root/cellranger
	echo "this is a $CELLRANGER analysis"
elif [ $CELLRANGER == "cellrangerARC"  ] ; then
	root=$root/cellrangerARC
	echo "this is a $CELLRANGER analysis"
elif [ $CELLRANGER == "cellrangerATAC" ] ; then
    root=$root/cellrangerATAC
	echo "this is a $CELLRANGER analysis"
elif [ $CELLRANGER == "spaceranger" ] ; then
    root=$root/spaceranger
	echo "this is a $CELLRANGER analysis"
else
	echo "no valid cellrangerfolder"
fi

path=$root/$inFolder

for sample in "$path"/*; do
	sample=${sample%*/}
    sampleN=${sample##*/}
	sampleMulti=$(ls ${path}/${sampleN}/outs/ | grep multi)
	echo "folder name to processs: $sampleN"     
	echo "path of processed folder: $path"
	echo "full path where web_summary and cloupe exist: $sample"
	if [[ "$sampleMulti" == "" ]] ; then
		echo "No multi analysis"
			if [[ "${sampleN}" == "agg" ]];	then
			echo "scp -i /home/hthiele0/.ssh/id_rsa $path/$sampleN/outs/cloupe.cloupe $anubis/${project}_${sampleN}_${PRID}.cloupe"
			scp -i /home/hthiele0/.ssh/id_rsa $path/$sampleN/outs/count/cloupe.cloupe "${anubis}"/"${project}"_"${sampleN}"_"${PRID}".cloupe
			scp -i /home/hthiele0/.ssh/id_rsa $path/$sampleN/outs/web_summary.html "${anubis}"/"${project}"_"${sampleN}"_"${PRID}".html
			else
			scp -i /home/hthiele0/.ssh/id_rsa "$path"/"$sampleN"/outs/cloupe.cloupe "$anubis"/"$project"_"$sampleN"_"$PRID".cloupe
			scp -i /home/hthiele0/.ssh/id_rsa "$path"/"$sampleN"/outs/web_summary.html "$anubis"/"$project"_"$sampleN"_"$PRID".html
			fi
	#elif [[ "${sampleMulti}" == "multi"* ]]; then
	else
		echo "there is multi folder"
		for sampleI in $(ls "$path"/"$sampleN"/outs/per_sample_outs/) ; do
			echo "internal sample : $sampleI"
			echo "scp -i /home/hthiele0/.ssh/id_rsa ${path}/${sampleN}/outs/per_sample_outs/${sampleI}/web_summary.html ${anubis}/${project}_${sampleN}_${PRID}.html"
			scp -i /home/hthiele0/.ssh/id_rsa "$path"/"$sampleN"/outs/per_sample_outs/"$sampleI"/web_summary.html "$anubis"/"$project"_"$sampleN"_"$PRID"_${sampleI}.html
			scp -i /home/hthiele0/.ssh/id_rsa "$path"/"$sampleN"/outs/per_sample_outs/"$sampleI"/count/sample_cloupe.cloupe "$anubis"/"$project"_"$sampleN"_"$PRID"_${sampleI}.cloupe
		done
	fi
done

