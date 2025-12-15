#!/bin/bash

#########################################
#               INPUTS                  #
#########################################
input=$1
dir=$2
prefix=$3
type=$4
nb_chains=$5

#########################################
#               LOAD ENV                #
#########################################
module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env || { echo "❌ Error: Could not activate conda environment 'beast_env'."; exit 1; }

ltreeannotator=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/treeannotator


# ############################################# COMBINE TREES #############################################
chains="$dir/chains"
combined_trees_output="$dir/"$prefix"_combined_trees.trees"

trees=()
for i in {1..4}; do
    trees+=( -log "$chains/chain${i}"*".trees" )
done
$logcombiner -b 10 "${trees[@]}" -o "$combined_trees_output"

# ############################################# ANNOTATE TREE #############################################
combined_tree_output="$dir/"$prefix"_combined_tree.tree"

$treeannotator \
    -burnin 10 \
    -height median "$combined_trees_output" "$combined_tree_output"

