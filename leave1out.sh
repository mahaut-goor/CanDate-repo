#!/bin/bash
#SBATCH --job-name=lo192res
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/lo192res_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/lo192res_%j.err
#SBATCH --time=24:00:00
#SBATCH --get-user-env
#SBATCH --clusters=biohpc_gen #cm2_tiny
#SBATCH --partition=biohpc_gen_normal #biohpc_gen_production   #cm2_tiny
#SBATCH --qos=biohpc_gen_low_prio
#SBATCH --cpus-per-task=25
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=M.Goor@campus.lmu.de

#########################################
#             STEP CONTROL              #
#########################################
# Default to 1 if not specified
START_STEP=${1:-1}

echo "=================================================="
echo " Starting pipeline at STEP ${START_STEP}"
echo "=================================================="

#########################################
#               INPUTS                  #
#########################################
INPUT_DIR="/dss/lxclscratch/09/re98gan/205ancientsModern/leave-one-out"
OLD_ID="REFCanFam_AY729880.1_0"
ANALYSIS_NAME=$(basename "$INPUT_DIR")
echo "Analysis name: $ANALYSIS_NAME"

#########################################
#            ANALYSIS DIR               #
#########################################
RES_DIR="$INPUT_DIR/results"
MT_FASTA_DIR="$RES_DIR/mtDNA"
ANALYSIS_DIR="$RES_DIR/analysis"
LEAVE1OUT_DIR="$RES_DIR/leave-one-out"
mkdir -p "$RES_DIR" "$MT_FASTA_DIR" "$ANALYSIS_DIR" "$LEAVE1OUT_DIR"

#########################################
#            ANALYSIS FILES             #
#########################################
INPUT_XML=/dss/lxclscratch/09/re98gan/205ancientsModern/192ancientsModernNODLOOP_renamed_filtered_2ndrunWtree_REF.xml
samples_to_run=/dss/lxclscratch/09/re98gan/205ancientsModern/leave-one-out/samplelists/resume.txt

if [[ ! -s "$samples_to_run" ]]; then
  echo "❌ Error: Sample list file not found or empty: $samples_to_run"
  exit 1
fi

#########################################
#             INPUT TOOLS               #
#########################################
bam2fasta="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/bam2MTfasta.sh"
beast="/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/beast"
treeannotator="/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/treeannotator"
logcombiner="/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/logcombiner"
parse_xml="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/parse_xml.py"
runMCMC="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/runMCchains.sh"
combineLog="/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/combineLogsTrees.sh"

#########################################
#               STEP 1
#           BAMs → FASTAs
#########################################
if [[ "$START_STEP" -le 1 ]]; then
  echo "-----------------------------------------"
  echo "STEP 1: Processing BAMs into FASTAs ..."
  echo "-----------------------------------------"

  module load slurm_setup
  eval "$(conda shell.bash hook)"
  conda activate samtools || { echo "❌ Error: Could not activate conda environment 'samtools'."; exit 1; }

  for file in "$INPUT_DIR"/*.bam; do
      if [[ ! -s "$file" ]]; then
          echo "⚠️ Warning: BAM file missing or empty: $file"
          continue
      fi
      sampleName=$(basename "$file" .bam)
      echo "Processing file: $file -> Sample: $sampleName"
      $bam2fasta "$file" "$sampleName" "$MT_FASTA_DIR"
  done

  MULTIFASTA="$ANALYSIS_DIR/${ANALYSIS_NAME}.fasta"
  cat "$MT_FASTA_DIR"/*.fasta > "$MULTIFASTA"

  if [[ ! -s "$MULTIFASTA" ]]; then
      echo "❌ Error: Combined multifasta is empty or missing: $MULTIFASTA"
      exit 1
  fi
else
  echo "➡️ Skipping STEP 1 (starting from STEP ${START_STEP})"
  MULTIFASTA="$ANALYSIS_DIR/${ANALYSIS_NAME}.fasta"
fi

#########################################
#               STEP 2
#          Fasta alignment
#########################################
if [[ "$START_STEP" -le 2 ]]; then
  ALIGNED_FASTA="$ANALYSIS_DIR/${ANALYSIS_NAME}_aligned.fasta"
  TRIMMED_FASTA="$ANALYSIS_DIR/${ANALYSIS_NAME}_trimmed.fasta"

  echo "-----------------------------------------"
  echo "STEP 2: Running MAFFT alignment..."
  echo "Input  : $MULTIFASTA"
  echo "Output : $ALIGNED_FASTA"
  echo "-----------------------------------------"

  conda deactivate
  conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env || { echo "❌ Error: Could not activate conda environment 'beast_env'."; exit 1; }

  mafft --auto --thread 32 --inputorder --anysymbol "$MULTIFASTA" > "$ALIGNED_FASTA" || { echo "❌ Error: MAFFT alignment failed."; exit 1; }

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
#      Create XMLs for leave-one-out
#########################################
if [[ "$START_STEP" -le 3 ]]; then
  echo "-----------------------------------------"
  echo "STEP 3: Creating all XMLs for leave-one-out ..."
  echo "-----------------------------------------"

  while read -r sample; do
      wrkg_dir="$LEAVE1OUT_DIR/${sample}_TD"
      mkdir -p "$wrkg_dir"
      new_xml="192samples_${sample}.xml"

      python "$parse_xml" "$INPUT_XML" "${wrkg_dir}/$new_xml" "$OLD_ID" "$sample" || {
          echo "❌ Error: XML generation failed for $sample"
          continue
      }
  done < "$samples_to_run"
else
  echo "➡️ Skipping STEP 3 (starting from STEP ${START_STEP})"
fi

#########################################
#               STEP 4
#           Run BEAST analyses
#########################################
if [[ "$START_STEP" -le 4 ]]; then
  echo "-----------------------------------------"
  echo "STEP 4: Running tip dating for all samples ..."
  echo "-----------------------------------------"

  while read -r sample; do
      wrkg_dir="$LEAVE1OUT_DIR/${sample}_TD"
      new_xml="192samples_${sample}.xml"

      if [[ ! -s "${wrkg_dir}/$new_xml" ]]; then
          echo "⚠️ Warning: XML file missing for $sample, skipping BEAST"
          continue
      fi

      source "$runMCMC" "${wrkg_dir}/$new_xml" "$wrkg_dir" "$sample" "new" 4 100
      source "$combineLog" "${wrkg_dir}/$sample" "$wrkg_dir" "$sample" 4
  done < "$samples_to_run"
else
  echo "➡️ Skipping STEP 4 (starting from STEP ${START_STEP})"
fi

#########################################
#               STEP 5
#           Run BEAST analyses
#########################################
if [[ "$START_STEP" -le 5 ]]; then
  echo "-----------------------------------------"
  echo "STEP 5: RCombining logs ..."
  echo "-----------------------------------------"

  while read -r sample; do
      wrkg_dir="$LEAVE1OUT_DIR/${sample}_TD"
      source /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/tip_dating_v2.sh "${wrkg_dir}/$sample" "$wrkg_dir" "$sample" 4
  done < "$samples_to_run"
else
  echo "➡️ Skipping STEP 5 (starting from STEP ${START_STEP})"
fi

# #########################################
# #               STEP 5
# #           output plots and stats
# #########################################
# if [[ "$START_STEP" -le 5 ]]; then
#   echo "-----------------------------------------"
#   echo "STEP 5: Outputing plots and stats ..."
#   echo "-----------------------------------------"

#  # extract tip dates
#  /dss/dsshome1/09/re98gan/ANALYSIS/py_scripts/extractTipDate.py \
#     --logfile "$RES_DIR/${INPUT_SAMPLE}_tipdating.log" \
#     --outdir "$RES_DIR" \
#     --sample "$INPUT_SAMPLE" || { echo "❌ Error: extractTipDate.py failed."; exit 1; }
  
#   # plot studied tip date onto the dog bdd r2 plot
#   /dss/dsshome1/09/re98gan/ANALYSIS/py_scripts/plotTipDates.py

#   # extract patristic distance from beast tree
#   /dss/dsshome1/09/re98gan/ANALYSIS/r_scripts/patristic_distance.r

#   #  add everything to the same csv + add coverage too

#   # plot everything + compute lm
#   /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/tests/126samples/leave-one-out_strictClock/stats/stats_TD.R
  
#   # don't forget to compute also correlation with the coverage

# fi

# echo "✅ Pipeline finished (started from step ${START_STEP})."
