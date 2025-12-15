#!/bin/bash

# combine_beast_logs.sh
# Usage: bash combine_beast_logs.sh <input_xml> <output_dir> <prefix> <nb_chains>


#########################################
#               INPUTS                  #
#########################################
input=$1
dir=$2
prefix=$3
nb_chains=$4

#########################################
#               LOAD ENV                #
#########################################
module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env || {
  echo "❌ Error: Could not activate conda environment 'beast_env'."
  exit 1
}

logcombiner="/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/logcombiner"
treeannotator="/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/treeannotator"


########################################
#       COMBINE RESULTS
#########################################

echo "Combining chains..."
dir=$INPUT_DIR"/chains"

combined_log_output="$dir/"$prefix"_combined_log.log"
$logcombiner -b 10 -log $dir"/chain1_"$prefix".log" -log $dir"/chain2_"$prefix".log" -log $dir"/chain3_"$prefix".log" -log $dir"/chain4_"$prefix".log" -o $dir"/"$prefix"_combined_log.log"

echo "✅ Combined log file created at: $combined_log_output"



# #########################################
# #            COMBINE LOGS               #
# #########################################
# chains="$dir/chains"
# combined_log_output="$dir/${prefix}_combined_log.log"
# combined_tree_output="$dir/${prefix}_combined_trees.trees"

# logs=()
# trees=()
# missing=false

# for i in $(seq 1 "$nb_chains"); do
#     log_file=$(ls "$chains"/chain${i}_*.log 2>/dev/null || true)
#     tree_file=$(ls "$chains"/chain${i}_*.trees 2>/dev/null || true)

#     if [[ -s "$log_file" && -s "$tree_file" ]]; then
#         logs+=( -log "$log_file" )
#         trees+=( -log "$tree_file" )
#     else
#         echo "⚠️  Warning: Missing chain ${i} log or tree file in $chains"
#         missing=true
#     fi
# done

# if [[ ${#logs[@]} -eq 0 ]]; then
#     echo "❌ Error: No valid .log files found in $chains"
#     exit 1
# fi

# echo "--------------------------------------------"
# echo "Combining ${#logs[@]} log files for prefix: $prefix"
# echo "--------------------------------------------"

# # Combine logs
# $logcombiner -b 10 "${logs[@]}" -o "$combined_log_output"
# echo "✅ Combined log file created at: $combined_log_output"

# # Combine trees (optional, uncomment if desired)
# if [[ ${#trees[@]} -gt 0 ]]; then
#     $logcombiner -b 10 "${trees[@]}" -o "$combined_tree_output"
#     echo "🌳 Combined tree file created at: $combined_tree_output"
# fi

# # Summarize with TreeAnnotator (optional)
# # treeannotator -heights mean "$combined_tree_output" "$dir/${prefix}_MCC.tree"

# echo "✅ Combination complete for $prefix"
