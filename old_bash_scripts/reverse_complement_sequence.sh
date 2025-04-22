#!/bin/bash

SEQUENCE=$1

function rrev() {
	case $1 in
		"T")
		echo -n A
		;;
		"A")
		echo -n T
		;;
		"G")
		echo -n C
		;;
		"C")
		echo -n G
		;;
	esac
}

REVERSED=`echo $SEQUENCE | rev`
REVCOMP=""
for I in $(seq 0 $((${#SEQUENCE}-1))); do
	REVCOMP="${REVCOMP}`rrev ${REVERSED:$I:1};`"
done
echo $REVCOMP
