#!/bin/bash

#########################################
#               INPUTS                  #
#########################################
dir=$1
output_dir=$2
prefix=$3
nb_chains=$4

#########################################
#               LOAD ENV                #
#########################################
module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env \
  || { echo "❌ Error: Could not activate conda environment 'beast_env'."; exit 1; }

#########################################
#               PATHS                   #
#########################################
treeannotator=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/treeannotator
logcombiner=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/logcombiner
resample=/dss/dsshome1/09/re98gan/ANALYSIS/CanDate-repo/scripts/ResampleFromTrees.py

chains="$dir"
combined_log="$output_dir/${prefix}_combined.log"
combined_trees="$output_dir/${prefix}_combined.trees"
resampled_trees="$output_dir/${prefix}_resampled.trees"
final_tree="$output_dir/${prefix}_resampled.tree"

#########################################
#           COMBINE LOG FILES            #
#########################################
echo "Combining $nb_chains chains..."

log_args=()
for i in $(seq 1 "$nb_chains"); do
    logfile="$chains/chain${i}_${prefix}.log"
    [[ -f "$logfile" ]] || { echo "❌ Missing $logfile"; exit 1; }
    log_args+=(-log "$logfile")
done

"$logcombiner" -b 10 "${log_args[@]}" -o "$combined_log"

#########################################
#           COMBINE TREE FILES           #
#########################################
tree_args=()
for i in $(seq 1 "$nb_chains"); do
    treefile=${chains}"/chain"${i}_${prefix}."trees"
    [[ -f "$treefile" ]] || { echo "❌ Missing $treefile"; exit 1; }
    tree_args+=(-log "$treefile")
done

"$logcombiner" -b 10 "${tree_args[@]}" -o "$combined_trees"

#########################################
#           RESAMPLE TREES               #
#########################################
echo "Resampling trees..."
"$resample" "$combined_trees" "$resampled_trees" 10000

#########################################
#           TREE ANNOTATION              #
#########################################
echo "Running TreeAnnotator..."
"$treeannotator" -burnin 10 -height median \
  "$resampled_trees" "$final_tree"

echo "✅ chains & trees combined successfully."
