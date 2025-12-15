#!/bin/bash

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env 

beast=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/beast

#########################################
#               INPUTS                  #
#########################################
input=$1          # XML file
dir=$2
prefix=$3
type=$4           # new or resume
threads=64

############################################# RUN BEAST MCMCs #############################################
chains="$dir/chains"
mkdir -p "$chains"

for i in {1..4}; do # run 4 chains for each input
    seed=$((30 - i))

    if [ "$type" == "resume" ]; then # resume an existing run
        $beast -threads $threads -prefix "$chains/chain${i}_" -resume "$input" &
    elif [ "$type" == "new" ]; then # start a new run
        $beast -threads $threads -prefix "$chains/chain${i}_" "$input" &
    else
        echo "❌ Error: unknown type '$type'. Expected 'resume' or 'new'."
        exit 1
    fi
done
wait

echo "✅ BEAST MCMC runs completed."
