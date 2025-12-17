#!/bin/bash
set -euo pipefail

INPUT_DIR=$1
INPUT_CSV=$2

# Header line
echo "Sample_name,numreads,covbases,coverage,meandepth" > "$INPUT_CSV"

# Loop over coverage files
for file in "$INPUT_DIR"/*_samcoverage.txt; do
    name=${file##*/}                              # e.g. Sample_samcoverage.txt
    sampleName=${name%_*_samcoverage.txt}         # Extract sample name

    # Extract the desired fields from the 2nd line and append to CSV
    awk -v s="$sampleName" 'FNR==2 {print s "," $4 "," $5 "," $6 "," $7}' "$file" >> "$INPUT_CSV"
done

echo "✅ Coverage summary written to $INPUT_CSV"
