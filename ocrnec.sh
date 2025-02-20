#!/bin/bash
#Converts NEC jpg files to searchable PDF

cd nec/
for i in *.jpg; do
	tesseract -psm 1 -l eng $i $i pdf
	echo "DONE WITH $i.jpg"
done

echo "DONE CONVERTING NEC TO SEARCHABLE PDF. USE ACROBAT TO JOIN THE FILES"
