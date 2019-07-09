#!/bin/bash

#establishing directory variables
DIRECTORY="$(pwd)/"

#Creating temp files.
mkdir temporal
touch temporal/file_list.txt
ARG_NUM="$#"
comp=0
TEMP_DIR="${DIRECTORY}temporal/"

#checking for arguments
if (( $ARG_NUM <= 1 ))
	then
		fail=1
		echo "Not enough arguments"
		echo "Aborting.."
		echo ""
		rm -r temporal
		exit 1
fi

#making a list of the argumented files.
        while [ "$1" != "" ]; do
                echo "$1" >> temporal/file_list.txt
                shift

        done

#making the output folder and log file
mkdir measured_intensity
touch measured_intensity/intensity_measured_log.txt
OUTPUT_FOLDER="${DIRECTORY}measured_intensity/"
mkdir measured_intensity/graph/

while [ $ARG_NUM -gt 0 ]
do
#restarting variables if needed
E_FILE=""
L_FILE=""

#Selecting the first item in the list of files and getting the genotype, slide, gonad and stage.
CURR=$(head -n 1 temporal/file_list.txt)

genotype=${CURR%_slide*} #obtaining genotype
pos_slide=${CURR#*slide} #obtaining slide
slide=${pos_slide%_gonad*} #obtaining slide
pos_gonad=${CURR#*gonad} #obtaining gonad
gonad=${pos_gonad%%_*}	#obtaining gonad
pos_stage=${CURR/*_gonad$gonad/} #obtaining stage
pos_stage=${pos_stage#_} #obtaining stage
stage=${pos_stage%_int*} #obtaining stage


#cheking if stage is correct
if [ "$stage" == "early" ]
	then
		E_FILE=$CURR
		complement_stage="late"
		fail=0
		#obtaining the complement string
		COMPLEMENT_FILE=${genotype}_slide${slide}_gonad${gonad}_${complement_stage}_intensities.csv
		L_FILE=$COMPLEMENT_FILE
else
		if [ "$stage" == "late" ]
			then
				L_FILE=$CURR
				complement_stage="early"
				fail=0
				#obtaining the complement string
				COMPLEMENT_FILE=${genotype}_slide${slide}_gonad${gonad}_${complement_stage}_intensities.csv
				E_FILE=$COMPLEMENT_FILE
			else
				echo "failed: check stages for $genotype slide$slide gonad$gonad and make sure you have early and late"
				echo "failed: check stages for $genotype slide$slide gonad$gonad and make sure you have early and late" >> measured_intensity/intensity_measured_log.txt
				fail=1
		fi
fi

#displaying error if stage is incorrect
if (( $fail == 1 ))
	then
		echo "error"
		exit 1
fi

#Setting Genstage variables for the R script
E_GENSTAGE="$genotype E"
L_GENSTAGE="$genotype L"

#Setting slide and gonad variable for R script
S_G_VARIABLE="s${slide}g${gonad}"

#Variable for outputfile
OUT_FILE="${genotype}_slide${slide}_gonad${gonad}_normalized.csv"

#echo the files processed
echo "calculating:"
echo $E_FILE
echo $L_FILE
echo ""

#eliminating the two entries from the file_list
sed -i "/$COMPLEMENT_FILE/d" temporal/file_list.txt
sed -i "/$CURR/d" temporal/file_list.txt

#running the measure_intensity.R script that needs 7 variables: 1)early file 2)late file 3)early genstage 4)late genstage 5)slide and gonad 6)output csv 7)temporal folder.
Rscript --vanilla /home/carlos/scripts/c016_sbs_intensity/measure_intensities.R "${DIRECTORY}${E_FILE}" "${DIRECTORY}${L_FILE}" "${E_GENSTAGE}" "${L_GENSTAGE}" "${S_G_VARIABLE}" "${OUTPUT_FOLDER}${OUT_FILE}" "${TEMP_DIR}"

#checking for the graph
if (( $(ls temporal/*.png | wc -l) == 2 ))
	then 
		fail=0
	else
		fail=1
fi

#finalizing if errors
if (( $fail == 1 ))
	then
		echo "error:"
		echo "error:" >> measured_intensity/intensity_measured_log.txt
		echo "something went wrong with finalizing measure_intensities.R on ${genotype}_slide${slide}_gonad${gonad} files."
		echo "something went wrong with finalizing measure_intensities.R on ${genotype}_slide${slide}_gonad${gonad} files." >> measured_intensity/intensity_measured_log.txt
		exit 1
fi

#moving graph from temporal to output folder
mv temporal/pansyp1.png measured_intensity/graph/${genotype}_slide${slide}_gonad${gonad}_normalized_pansyp1.png
mv temporal/syp1phos.png measured_intensity/graph/${genotype}_slide${slide}_gonad${gonad}_normalized_syp1phos.png

#getting variables for last check
if (( $(ls measured_intensity/graph/${genotype}_slide${slide}_gonad${gonad}_normalized_pansyp1.png | wc -l) == 0 ))
		then	
			fail=1
		else
			if (( $(ls measured_intensity/graph/${genotype}_slide${slide}_gonad${gonad}_normalized_syp1phos.png | wc -l) == 0 ))
				then 
					fail=1
			fi
fi

#finalizing if errors
if (( $fail == 1 ))
	then
		echo "error:"
		echo "error:" >> measured_intensity/intensity_measured_log.txt
		echo "something went wrong moving ${genotype}_slide${slide}_gonad${gonad} graph files." >> measured_intensity/intensity_measured_log.txt
		exit 1
fi

#adding the files to the completed list
echo $(date '+%Y_%m_%d_%H:%M:%S') >> measured_intensity/intensity_measured_log.txt
echo $CURR >> measured_intensity/intensity_measured_log.txt
echo $COMPLEMENT_FILE >> measured_intensity/intensity_measured_log.txt
echo "success" >> measured_intensity/intensity_measured_log.txt
echo "" >> measured_intensity/intensity_measured_log.txt
echo "success"
echo ""

#substracting from the flag
ARG_NUM=$(( $ARG_NUM - 2 ))

#end of while loop
done

echo ""
echo "" >> measured_intensity/intensity_measured_log.txt
echo "cleaning..."
echo "cleaning..." >> measured_intensity/intensity_measured_log.txt
echo ""
echo "" >> measured_intensity/intensity_measured_log.txt

#removing temporal directory
rm -r temporal

echo "Obtaining all_intensities file and plotly graphs"
echo "Obtaining all_intensities file and plotly graphs" >> measured_intensity/intensity_measured_log.txt
echo ""
echo "" >> measured_intensity/intensity_measured_log.txt

OUT_FILE_COMBINED="${OUTPUT_FOLDER}all_intensities.csv"
OUT_FILE_R_SPACE="${OUTPUT_FOLDER}all_intensities_graphs.RData"

#running the generation of the combined intensities and its graph. It requires two arguments 1)directory with the files 2)path of the output file.
Rscript --vanilla /home/carlos/scripts/c016_sbs_intensity/generating_combined.R "$OUTPUT_FOLDER" "$OUT_FILE_COMBINED" "$OUT_FILE_R_SPACE"

#checkpoint for data.image and output file
if (( $(ls $OUT_FILE_COMBINED | wc -l) != 1 ))
	then 
		fail=1
		echo "error obtaining all_intensities.csv file, check whats wrong in generating_combined.R script"
		echo "error obtaining all_intensities.csv file, check whats wrong in generating_combined.R script" >> measured_intensity/intensity_measured_log.txt
		exit 1
fi

if (( $(ls $OUT_FILE_R_SPACE | wc -l) != 1 ))
	then 
		fail=1
		echo "error obtaining all_intensities_graph.RData file, check whats wrong in generating_combined.R script"
		echo "error obtaining all_intensities_graph.RData file, check whats wrong in generating_combined.R script" >> measured_intensity/intensity_measured_log.txt
		exit 1
fi

echo "open the file ${OUT_FILE_R_SPACE} and run plotly_pan and plotly_phos to get the graphs"
echo "open the file ${OUT_FILE_R_SPACE} and run plotly_pan and plotly_phos to get the graphs" >> measured_intensity/intensity_measured_log.txt
echo "done"
echo "done" >> measured_intensity/intensity_measured_log.txt
echo ""
echo "" >> measured_intensity/intensity_measured_log.txt
