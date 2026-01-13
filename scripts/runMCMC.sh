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
threads=${SLURM_CPUS_PER_TASK:-16}
nb_chains=$5

############################################# RUN BEAST MCMCs #############################################

for i in $(seq 1 $nb_chains); do 
    seed=$((30 - i))

    echo "==============================================="
    echo "Starting BEAST chain $i with seed $seed"
    echo "Input file: $input"
    echo "Output prefix: $dir/chain${i}_"

    if [ "$type" == "resume" ]; then # resume an existing run
        $beast -threads $threads -prefix "$dir/chain${i}_" -resume "$input" -beagle &
    elif [ "$type" == "new" ]; then # start a new run
        $beast -threads $threads -prefix "$dir/chain${i}_" "$input" -beagle &
    else
        echo "❌ Error: unknown type '$type'. Expected 'resume' or 'new'."
        exit 1
    fi
done
wait

echo "✅ BEAST MCMC runs completed."
