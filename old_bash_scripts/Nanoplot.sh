#!/bin/bash

#before the loop check if the script is already running
if [ -f /data/gridion/run.running ]; then exit 0; fi
touch /data/gridion/run.running

function cleanup(){
        rm /data/gridion/run.running
}

trap cleanup EXIT SIGINT SIGTERM

conda activate NanoPlot

count=1
# find the folder where the summary files are.
for Files in `find /data/gridion/ -name *sequencing_summary*txt` ; do
DIR=${Files%/*}

#check the loop
echo "found sequencing folder ${Files}"
   (( count++ ))

# if the QC already exists
    if [ -d ${DIR}"/QC" ]; then
        #some debuginf naming stuff
        echo  "sequencing already done and folder exists: $DIR/QC"
        base=${Files##*/}
    else
    TITLE=${Files##*gridion/}
    TITLE=${TITLE%%/*}
        echo "NanoPlot -t8 --summary" $Files "-f jpeg --N50 --loglength --plots dot kde hex -o QC --legacy"
#        NanoPlot -t8 --title "$TITLE"  --summary $Files -f jpeg --N50 --loglength --plots dot kde --legacy hex -o ${DIR}"/QC/summary-plots-log10N50"
 NanoPlot -t8 --title "$TITLE"  --summary $Files -f jpeg --N50 --loglength --plots kde dot --legacy hex -o ${DIR}"/QC/
    fi

done
conda deactivate
echo "processed $count gridion folders"