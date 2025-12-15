#!/bin/bash

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env #create and env for beast

beast=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/beast
treeannotator=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/treeannotator
logcombiner=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/logcombiner
# This script performs tip dating analysis using BEAST2.

# # Input files
input=$1
dir=$2
prefix=$3
type=$4

############################################# IQTREE - to generate starting tree #####################################################
# Create output directory if it doesn't exist
# iqtree_output="$dir/iqtree_output"
# mkdir -p "$iqtree_output"

# input_fasta="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/test21samples/seq21_Aligned_noNs_autotrim_newBP.fasta"
# Run ModelFinder to select the best model before running tree inference
# "$iqtree_path" -s "$input_fasta" \
#     -m MFP \
#     -pre "$iqtree_output"/test21samples_modeltest \
#     -nt AUTO \
#     -ntmax 4
# # After model selection, run tree inference with the chosen model (replace GTR+G with the selected model if needed)
# "$iqtree_path" -s "$input_fasta" \
#     -m GTR+G \s
#     -bb 1000 \
#     -alrt 1000 \
#     -pre "$iqtree_output"/test21samples \
#     -nt AUTO \
#     -ntmax 4
# the model is used for beast and the tree is used to compare with the bayesian one

############################################# RUN BEAST MCMCs #############################################
chains="$dir/chains" # maybe 10 is too much, can try 5 first
mkdir -p "$chains"

# Run 10 independent MCMC chains with different random seeds
# $beast -validate/ $input

for i in {1..4}; do
    seed=$((30 - i))

    if [ "$type" == "resume" ]; then
        $beast -threads 64 -prefix "$chains/chain${i}_" -resume "$input" &
    elif [ "$type" == "new" ]; then
        $beast -threads 64 -prefix "$chains/chain${i}_" "$input" &
    else
        echo "❌ Error: unknown type '$type'. Expected 'resume' or 'new'."
        exit 1
    fi
done
wait

############################################# COMBINE LOGS #############################################
# combined_log_output="$dir/"$prefix"_combined_log.log"

# logs=()
# for i in {1..4}; do
#     logs+=( -log "$chains/chain${i}"*".log" )
# done
# $logcombiner -b 10 "${logs[@]}" -o "$combined_log_output"

# # ################## OPTIONS ##################
# # # -b 10 indicates to burn the first 10% of the samples
# # # Check the combined log file for convergence and effective sample sizes (ESS) using Tracer
# # # Open Tracer and load the combined_log.log file to assess convergence and ESS values

# # ############################################# COMBINE TREES #############################################
# combined_trees_output="$dir/"$prefix"_combined_trees.trees"

# trees=()
# for i in {1..4}; do
#     trees+=( -log "$chains/chain${i}"*".trees" )
# done
# $logcombiner -b 10 "${trees[@]}" -o "$combined_trees_output"

# # ############################################# ANNOTATE TREE #############################################
# combined_tree_output="$dir/"$prefix"_combined_tree.tree"

# $treeannotator \
#     -burnin 10 \
#     -height median "$combined_trees_output" "$combined_tree_output"

