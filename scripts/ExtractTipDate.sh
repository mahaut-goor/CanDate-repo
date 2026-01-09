#!/bin/bash

# Usage: ./run_extract_tip_dates.sh <base_directory>

# base_dir="${1:-.}"  # Default to current directory if none provided
base_dir=$1
script_path="/dss/dsshome1/09/re98gan/ANALYSIS/CanDate-repo/scripts/extractTipDate.py"

echo "Searching for *.log files in: $base_dir"

# Loop through all *_combined_log.log files recursively
# find "$base_dir" -type f -name "COMBINED*.log" | while read -r log; do
find "$base_dir" -type f -name "*combined.log" | while read -r log; do
    echo "Processing: $log"
    output_dir=$(dirname "$log")
    prefix=$(basename "$log" .log)
    output_csv="$output_dir/extracted_tip_dates_${prefix}.csv"

    python "$script_path" "$log" "$output_csv"
done

# Combine all extracted CSVs into one master file
master_csv="$base_dir/combined_extracted_tip_dates.csv"
echo "Combining extracted CSVs into: $master_csv"
rm -f "$master_csv"

first=1
find "$base_dir" -type f -name "extracted_tip_dates_*.csv" | sort | while read -r file; do
    if [ "$first" -eq 1 ]; then
        cat "$file" > "$master_csv"
        first=0
    else
        tail -n +2 "$file" >> "$master_csv"
    fi
done

echo "✅ All extracted tip dates combined into: $master_csv"
