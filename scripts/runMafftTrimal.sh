#!/bin/bash

#########################################
#               INPUTS                  #
#########################################
INPUT_DIR=$1
INPUT_FASTA=$2
INPUT_SAMPLE=$(basename "$INPUT_FASTA" .fasta)

ANALYSIS_NAME=$(basename "$INPUT_DIR")
echo "Analysis name: ${ANALYSIS_NAME}_${INPUT_SAMPLE}"

RES_DIR="$INPUT_DIR/mafft_trimal"
mkdir -p "$RES_DIR"

#########################################
#            DOG DBB FILES              #
#########################################
DOG_DBB="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/data"
DBB_FASTA="$DOG_DBB/192ancientsModernNODLOOP_renamed_filtered.fasta"

#########################################
#               STEP 2
#          Fasta alignment
#########################################
ALIGNED_FASTA="$RES_DIR/DBB_${INPUT_SAMPLE}_aligned.fasta"
TRIMMED_FASTA="$RES_DIR/DBB_${INPUT_SAMPLE}_trimmed.fasta"

echo "-----------------------------------------"
echo "STEP 2: Running MAFFT alignment..."
echo "DBB FASTA : $DBB_FASTA"
echo "Input FASTA : $INPUT_FASTA"
echo "Output : $ALIGNED_FASTA"
echo "-----------------------------------------"

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env || { echo "❌ Error: Could not activate conda environment 'beast_env'."; exit 1; }

mafft --thread 16 --inputorder --anysymbol --add "$INPUT_FASTA" --reorder "$DBB_FASTA" > "$ALIGNED_FASTA" || { echo "❌ Error: MAFFT alignment failed."; exit 1; }

if [[ ! -s "$ALIGNED_FASTA" ]]; then
    echo "❌ Error: MAFFT did not produce an output file."
    exit 1
fi
echo "✅ MAFFT alignment complete."

echo "-----------------------------------------"
echo "Trimming alignment with trimAl..."
echo "-----------------------------------------"

trimal -in "$ALIGNED_FASTA" -out "$TRIMMED_FASTA" -gt 0.2 || { echo "❌ Error: trimAl failed."; exit 1; }

if [[ ! -s "$TRIMMED_FASTA" ]]; then
    echo "❌ Error: Trimmed FASTA file is empty or missing: $TRIMMED_FASTA"
    exit 1
fi
echo "✅ Trimmed alignment created: $TRIMMED_FASTA"

