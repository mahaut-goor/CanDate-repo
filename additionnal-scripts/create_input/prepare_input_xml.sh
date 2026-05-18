#!/bin/bash

# This script prepares a CSV file listing XML files for input into a pipeline.
# Usage: ./prepare_xml_input.sh /path/to/xml/files > output.csv

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
echo "sample,xml_file"

# Loop through XML files
for xml in "$DIR"/*.xml; do
    # Skip if no XML files exist
    [ -e "$xml" ] || continue

    xml_file="$(basename "$xml")"

    # Remove extension for sample name
    sample="${xml_file%.xml}"

    # Output row
    echo "${sample},${xml}"
done