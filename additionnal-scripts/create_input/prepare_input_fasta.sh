#!/bin/bash

# This script prepares a CSV file listing FASTA files for input into a pipeline.
# Usage: ./prepare_fasta_input.sh /path/to/fasta/files > output.csv

# Exit if no directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

DIR="$1"

# Resolve directory to absolute path
DIR="$(cd "$DIR" && pwd)"

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory not found: $DIR"
    exit 1
fi

# Print header
echo "sample,fasta"

# Loop through FASTA-like files
for fasta in "$DIR"/*.{fasta,fa,fn}; do
    # Skip if no matching files exist
    [ -e "$fasta" ] || continue

    fasta_file="$(basename "$fasta")"

    # Remove extension for sample name
    sample="${fasta_file%.*}"

    # Output row
    echo "${sample},${fasta}"
done