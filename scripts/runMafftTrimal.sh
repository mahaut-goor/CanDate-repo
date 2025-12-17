#!/bin/bash

#########################################
#               INPUTS                  #
#########################################
INPUT_DIR=$1
INPUT_FASTA=$2
OUTPUT_DIR=$3
INPUT_SAMPLE=$(basename "$INPUT_FASTA" .fasta)

ANALYSIS_NAME=$(basename "$INPUT_DIR")
echo "Analysis name: ${ANALYSIS_NAME}_${INPUT_SAMPLE}"

#########################################
#            DOG DBB FILES              #
#########################################
DOG_DBB="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/data"
DBB_FASTA="$DOG_DBB/192ancientsModernNODLOOP_renamed_filtered.fasta"

#########################################
#               FILES                   #
#########################################
ALIGNED_FASTA="$OUTPUT_DIR/DBB_${INPUT_SAMPLE}_aligned.fasta"
TRIMMED_FASTA="$OUTPUT_DIR/DBB_${INPUT_SAMPLE}_trimmed.fasta"

#########################################
#               ENV                     #
#########################################
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env \
  || { echo "❌ Error: Could not activate conda environment 'beast_env'."; exit 1; }

#########################################
#               MAFFT                   #
#########################################
THREADS=${SLURM_CPUS_PER_TASK:-16}

echo "-----------------------------------------"
echo "STEP 2: Running MAFFT alignment"
echo "Threads      : $THREADS"
echo "DBB FASTA    : $DBB_FASTA"
echo "Input FASTA  : $INPUT_FASTA"
echo "Output       : $ALIGNED_FASTA"
echo "-----------------------------------------"

mafft \
  --thread "$THREADS" \
  --inputorder \
  --anysymbol \
  --add "$INPUT_FASTA" \
  --reorder "$DBB_FASTA" \
  > "$ALIGNED_FASTA"

[[ -s "$ALIGNED_FASTA" ]] || { echo "❌ Error: MAFFT output missing or empty."; exit 1; }
echo "✅ MAFFT alignment complete."

#########################################
#               TRIMAL                  #
#########################################
echo "-----------------------------------------"
echo "Trimming alignment with trimAl"
echo "-----------------------------------------"

trimal -in "$ALIGNED_FASTA" -out "$TRIMMED_FASTA" -gt 0.2

[[ -s "$TRIMMED_FASTA" ]] || { echo "❌ Error: Trimmed FASTA missing or empty."; exit 1; }
echo "✅ Trimmed alignment created: $TRIMMED_FASTA"
