#!/bin/bash

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env #create and env for beast

dir="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/tests/126samples/leave-one-out_strictClock"
echo -e "Sample,Closest_Tip,Distance_to_Closest_Tip,Mean_Distance_of_10pct_Closest_Tips" > patristic_distance_summary.csv

for folder in $dir"/strictClock_dating_"*; do

    #echo "Processing folder: $folder"
    folder_name=$(basename "$folder")
    #echo "Folder name: $folder_name"
    sampleName=${folder_name#strictClock_dating_}
    #echo "Extracted sample name: $sampleName"
    sampleName=${sampleName%_analysis}
    echo "Sample name: $sampleName"

    input_tree="$folder/${sampleName}_combined_tree.tree"
    echo "Input tree path: $input_tree"

    echo -e "\n" >> patristic_distance_summary.csv
    Rscript --vanilla /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/stats.r $input_tree $sampleName >> patristic_distance_summary.csv

done