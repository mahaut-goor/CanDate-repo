#!/bin/bash

# TODO
# python oop_script.py <input_fasta> <output_dir> <input_csv> ==> to check fasta files and csv files
# 

#########################################
#            INPUT VARIABLES            #
#########################################
INPUT_FASTA="$1"  # input aligned fasta file
INPUT_CSV="$3"    # input csv file with samples and tip dates
OUTPUT_DIR="$2"  # output directory
ANALYSIS_TYPE="$4"  # type of analysis: leave-one-out or single tip

#########################################
python /dss/dsshome1/09/re98gan/ANALYSIS/py_scripts/check_tip_dating_inputs.py "$INPUT_FASTA" "$INPUT_CSV"
# check fasta file ==> make sur its aligned
# check the labels (sample names) correspond to the csv file
# check if labels are in good format (no spaces, special characters etc)

#########################################
# check csv file
# check if it has two columns: sample names and tip dates
# check if sample names correspond to fasta file
# check if all samples have tip dates

#########################################
# check output directory

#########################################
# what analysis
# leave-one-out or just one tip
# if leave-one-out, read sample ids from a file

###############" if leave-one-out" ###############
# plot R2 estimated tip dates vs real calBP dates
# run python plotting script

###############" if only of tip" ###############





