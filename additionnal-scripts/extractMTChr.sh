#!/bin/bash

# This script extracts the mitochondrial chromosome name from BAM files and saves it in a CSV file.
# Usage: ./extractMTChr.sh /path/to/bam/files output.csv

INPUT_DIR=$1
INPUT_CSV=$2

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate samtools 

echo "sample,mt_header" > "$INPUT_CSV"

# Loop over BAM files
for file in "$INPUT_DIR"/*.bam; do
    name=${file##*/}             # Extract file name
    name=${name%.bam}            # Remove .bam extension

    # Extract the mitochondrial chromosome name
    mt_chr=$(samtools idxstats "$file" | awk '$1 ~ /MT|chrM|chrMT|M/ {print $1}')

    # If multiple matches, pick the first one
    mt_chr=$(echo "$mt_chr" | head -n 1)

    echo "$name,$mt_chr" >> "$INPUT_CSV"
done