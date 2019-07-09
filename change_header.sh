#!/bin/bash
DIR=$(pwd)
flag=0

mkdir $DIR/temporal


for filename in $DIR/*.csv; do
echo " ,sbs,stage,crop,pansyp1_corrected,syp1phos_corrected,npixels_phos,npixels_pan,pansyp1_background,pansyp1_background_pixels,syp1phos_background,syp1phos_background_pixels" > $DIR/temporal/temp.csv
tail -n +2 $filename >> $DIR/temporal/temp.csv

cp $DIR/temporal/temp.csv $filename

done

rm -r $DIR/temporal
