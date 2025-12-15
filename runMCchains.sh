#!/bin/bash

#########################################
#               INPUTS                  #
#########################################
input=$1          # XML file
dir=$2
prefix=$3
type=$4           # new or resume
nb_chains=$5
total_threads=$6

threads=$((total_threads / nb_chains))
if [[ $threads -lt 1 ]]; then threads=1; fi

#########################################
#               LOAD ENV                #
#########################################
module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env \
    || { echo "❌ Error: Could not activate conda environment."; exit 1; }

beast=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/beast

#############################################
#            RUN BEAST MCMCs (SLURM)        #
#############################################
chains="$dir/chains"
mkdir -p "$chains"

echo "👉 Running $nb_chains chains with $threads threads each (total = $((threads*nb_chains))) CPUs)"

for i in $(seq 1 "$nb_chains"); do
    seed=$((RANDOM + i))
    prefix_chain="$chains/chain${i}_${prefix}"
    echo "________________________________________________________________________"
    echo "🚀 Chain $i/$nb_chains for $prefix"
    echo "prefix_chain : $prefix_chain"
    echo "→ Starting chain $i (seed=$seed) with $threads threads"

    if [[ "$type" == "resume" ]]; then
        echo "prefix_chain: $prefix_chain"
        "$beast" -threads "$threads" -seed "$seed" -prefix "$prefix_chain" -resume "$input" &
    elif [[ "$type" == "new" ]]; then
        "$beast" -threads "$threads" -seed "$seed" -prefix "$prefix_chain" "$input" &
    else
        echo "❌ Error: unknown type '$type'. Expected 'new' or 'resume'."
        exit 1
    fi
done

wait

echo "✅ All $nb_chains BEAST chains finished."
