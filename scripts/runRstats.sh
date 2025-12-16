#!/bin/bash

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env #create and env for beast

dir="/dss/lxclscratch/09/re98gan/205ancientsModern/leave-one-out/results/leave-one-out/done/good"
echo -e "Sample,Closest_Tip,Distance_to_Closest_Tip,Mean_Distance_of_10pct_Closest_Tips" > patristic_distance_summary.csv

for folder in $dir"/"*; do

    echo "----------------------------------"
    echo "Processing folder: $folder"
    name=${folder##*/}
	sampleName=${name%_TD*}
    echo "Sample name: $sampleName"

    input_tree="$folder/${sampleName}_resampled_log.tree"
    echo "Input tree path: $input_tree"

    Rscript --vanilla /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/stats.r $input_tree $sampleName >> $dir/patristic_distance_summary.csv

    printf "\n" >> $dir/patristic_distance_summary.csv

done