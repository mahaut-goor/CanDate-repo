#!/bin/bash

# This script prepares a CSV file listing BAM files and their corresponding index files for input into the CanDate pipeline.
# Usage: ./prepare_input.sh /path/to/bam/files > output.csv

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
echo "sample,bam,idx"

# Loop through BAM files
for bam in "$DIR"/*.bam; do
    # Skip if no BAM files exist
    [ -e "$bam" ] || continue

    bam_file="$(basename "$bam")"

    # Sample name = part before first "."
    sample="${bam_file%%.*}"

    # Check for index files (two common conventions)
    if [ -f "$bam.bai" ]; then
        idx="$bam.bai"
    elif [ -f "${bam%.bam}.bai" ]; then
        idx="${bam%.bam}.bai"
    else
        idx="none"
    fi

    # Output row (full paths)
    echo "${sample},${bam},${idx}"
done
