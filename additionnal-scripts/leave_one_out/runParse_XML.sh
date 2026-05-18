#!/bin/bash

#### DOC 
#######################################
#            USAGE INFO            #
#######################################
# Script to run the ParseXmlST_l1o.py script for multiple samples listed in a text file. It reads sample names from the text file, processes each sample by calling the Python script with the appropriate arguments, and generates new XML files for each sample. --- IGNORE ---
# It takes an input XML file, a FASTA file for the alignment, and an output directory to save the new XML files. The sample names are read from a text file, and for each sample, the script generates a new XML file with the sample name included in the filename. --- IGNORE ---


mkdir -p xml

input_xml=$1
fasta_path=$2
dir=$3
analysis_name=$4
samples_list=$5

while read -r samples
do
    echo "Processing $samples"

    python ParseXmlST_l1o.py $input_xml $fasta_path $dir"/"$analysis_name"_"$samples".xml" "$samples"

done < $samples_list