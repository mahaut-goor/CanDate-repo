#!/bin/bash
#SBATCH --job-name=tdCanLup
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/tdCanLup_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/tdCanLup_%j.err
#SBATCH --time=24:00:00
#SBATCH --get-user-env
#SBATCH --clusters=cm4
#SBATCH --partition=cm4_tiny
#SBATCH --cpus-per-task=64
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=M.Goor@campus.lmu.de

#########################################
#             STEP CONTROL              #
#########################################
START_STEP=${1:-1}
echo "=================================================="
echo " Starting pipeline at STEP ${START_STEP}"
echo "=================================================="

#########################################
#               INPUTS                  #
#########################################
INPUT_DIR="/dss/lxclscratch/09/re98gan/mt_dogs_to_date/CanisLupus"
INPUT_FASTA="/dss/lxclscratch/09/re98gan/mt_dogs_to_date/CanisLupus/NC_008092.1.fasta"
INPUT_SAMPLE="NC_008092.1"
ANALYSIS_NAME=$(basename "$INPUT_DIR")
echo "Analysis name: ${ANALYSIS_NAME}_${INPUT_SAMPLE}"

#########################################
#            ANALYSIS DIR               #
#########################################
RES_DIR="$INPUT_DIR/results"
mkdir -p "$RES_DIR"

#########################################
#            DOG DBB FILES              #
#########################################
DOG_DBB="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/data"
DBB_XML="$DOG_DBB/DOG_DBB_NC_008092.1.xml"
DBB_FASTA="$DOG_DBB/192ancientsModernNODLOOP_renamed_filtered.fasta"
OLD_ID="CanLup_NC_008092.1"

#########################################
#             INPUT TOOLS               #
#########################################
bam2fasta="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/bam2MTfasta.sh"
beast="/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/beast"
treeannotator="/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/treeannotator"
logcombiner="/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/logcombiner"
parse_xml="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/parse_xml.py"
tip_dating_v2="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/tip_dating_v2.sh"

#########################################
#               STEP 1
#           BAMs → FASTAs
#########################################
if [[ "$START_STEP" -le 1 ]]; then
  echo "-----------------------------------------"
  echo "STEP 1: Processing BAM into FASTA ..."
  echo "-----------------------------------------"

  module load slurm_setup
  eval "$(conda shell.bash hook)"
  conda activate samtools || { echo "❌ Error: Could not activate conda environment 'samtools'."; exit 1; }

  INPUT_BAM=$(ls "$INPUT_DIR"/${INPUT_SAMPLE}*.bam 2>/dev/null | head -n 1)
  if [[ ! -s "$INPUT_BAM" ]]; then
      echo "❌ Error: No BAM file found for $INPUT_SAMPLE in $INPUT_DIR"
      exit 1
  fi

  echo "Processing BAM: $INPUT_BAM → Sample: $INPUT_SAMPLE"
  $bam2fasta "$INPUT_BAM" "$INPUT_SAMPLE" "$RES_DIR" || { echo "❌ Error: bam2fasta failed for $INPUT_BAM"; exit 1; }

else
  echo "➡️ Skipping STEP 1 (starting from STEP ${START_STEP})"
fi

#########################################
#               STEP 2
#          Fasta alignment
#########################################
if [[ "$START_STEP" -le 2 ]]; then
  ALIGNED_FASTA="$RES_DIR/DOG_DBB_${INPUT_SAMPLE}_aligned.fasta"
  TRIMMED_FASTA="$RES_DIR/DOG_DBB_${INPUT_SAMPLE}_trimmed.fasta"

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
else
  echo "➡️ Skipping STEP 2 (starting from STEP ${START_STEP})"
fi

#########################################
#               STEP 3
#      Create XMLs for single-tip dating
#########################################
if [[ "$START_STEP" -le 3 ]]; then
  echo "-----------------------------------------"
  echo "STEP 3: Creating XML manually using BEAUti ..."
  echo "-----------------------------------------"
  echo "⚠️ Open BEAUti, load: $TRIMMED_FASTA, set tip dates, and export XML to:"
  echo "   $RES_DIR/${INPUT_SAMPLE}.xml"
else
  echo "➡️ Skipping STEP 3 (starting from STEP ${START_STEP})"
fi

#########################################
#               STEP 4
#           Run BEAST analyses
#########################################
if [[ "$START_STEP" -le 4 ]]; then
  echo "-----------------------------------------"
  echo "STEP 4: Running BEAST tip dating ..."
  echo "-----------------------------------------"

  INPUT_XML=$DBB_XML 
  if [[ ! -s "$INPUT_XML" ]]; then
      echo "❌ Error: XML file not found: $INPUT_XML"
      exit 1
  fi

  source "$tip_dating_v2" "$INPUT_XML" "$RES_DIR" "$INPUT_SAMPLE"
else
  echo "➡️ Skipping STEP 4 (starting from STEP ${START_STEP})"
fi

echo "✅ Pipeline finished (started from step ${START_STEP})."

#########################################
#               STEP 5
#           output plots and stats
#########################################
if [[ "$START_STEP" -le 5 ]]; then
  echo "-----------------------------------------"
  echo "STEP 5: Outputing plots and stats ..."
  echo "-----------------------------------------"

fi

echo "✅ Pipeline finished (started from step ${START_STEP})."
