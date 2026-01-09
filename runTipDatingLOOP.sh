#!/bin/bash
#SBATCH --job-name=7armenian
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/7armenian_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/7armenian_%j.err
#SBATCH --time=48:00:00
#SBATCH --get-user-env
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_normal 
#SBATCH --qos=biohpc_gen_low_prio
#SBATCH --cpus-per-task=64
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=M.Goor@campus.lmu.de

set -euo pipefail

#########################################
#               INPUTS                  #
#########################################
INPUT_DIR=/dss/lxclscratch/09/re98gan/mt_dogs_to_date/7LachieSamples
PREFIX="7armenian"
TYPE="new"
STEP=3 # STEP 1: BAM→FASTA, STEP 2: Run MAFFT+TRIMAL, STEP 3: Creat Xml, STEP 4: Run Beast MCMC, STEP 5: Extract Tip Dates

#########################################
#                  DIR                  #
#########################################
FASTA_DIR="$INPUT_DIR/fastas"
ALIGN_DIR="$INPUT_DIR/mafft_trimal"
XML_DIR="$INPUT_DIR/xml_files"
CHAINS_DIR="$INPUT_DIR/chains"
COMBINED_DIR="$INPUT_DIR/combined"

#########################################
#               SCRIPTS                 #
#########################################
scripts_dir=/dss/dsshome1/09/re98gan/ANALYSIS/CanDate-repo/scripts
runMCMC=$scripts_dir/runMCMC.sh
bam2fasta=$scripts_dir/bam2fasta.sh
runMafftTrimal=$scripts_dir/runMafftTrimal.sh
parseXml=$scripts_dir/ParseXmlST.py
extractDates=$scripts_dir/ExtractTipDate.sh
combineLogsTrees=$scripts_dir/combineLogsTrees_v2.sh

echo "=================================================="
echo " Starting pipeline at STEP ${STEP}"
echo "=================================================="

########################################## STEP 1: BAM → FASTA #########################################
if [[ "$STEP" -le 1 ]]; then
    mkdir -p "$FASTA_DIR"
  for bam in "$INPUT_DIR"/*.bam; do
      INPUT_SAMPLE=$(basename "${bam%.bam}")
      echo "Processing BAM: $bam"
      "$bam2fasta" "$bam" "$INPUT_SAMPLE" "$FASTA_DIR"
  done
else
  echo "➡️ Skipping STEP 1"
fi

########################################## STEP 2: MAFFT + TRIMAL #########################################
if [[ "$STEP" -le 2 ]]; then
    mkdir -p "$ALIGN_DIR"
  for fasta in "$FASTA_DIR"/*.fasta; do
      "$runMafftTrimal" "$FASTA_DIR" "$fasta" "$ALIGN_DIR"
  done
else
  echo "➡️ Skipping STEP 2"
fi

########################################## STEP 3: XML #########################################
if [[ "$STEP" -le 3 ]]; then
    mkdir -p "$XML_DIR"
  for alignment in "$ALIGN_DIR"/*_trimmed.fasta; do
      prefix_fasta=$(basename "${alignment%.fasta}")
      prefix=${prefix_fasta##*DBB_}
      prefix=${prefix%_trimmed*}
      id_consensus=$(grep ">" $FASTA_DIR"/"*"$prefix"*".fasta" | head -n 1 | sed 's/>//')
      echo "Creating XML for alignment: $alignment"
      echo "Prefix: $prefix"
      echo "Output FASTA prefix: $prefix_fasta"

      python "$parseXml" "$XML_DIR/$prefix.xml" "$alignment" "$id_consensus" "$prefix_fasta"
  done
else
  echo "➡️ Skipping STEP 3"
fi

########################################## STEP 4: BEAST #########################################
if [[ "$STEP" -le 4 ]]; then
  mkdir -p "$CHAINS_DIR"
  nb_chains=6

  for xml in "$XML_DIR"/*.xml; do
    echo "----------------------------------------"
      prefix=$(basename "${xml%.xml}")
      prefix=${prefix##*DBB_}
      prefix=${prefix%_trimmed*}

      echo "Running BEAST for $prefix"
      echo "xml file: $xml"
      echo "prefix: $prefix"
      echo "chains dir: $CHAINS_DIR"
      "$runMCMC" "$xml" "$CHAINS_DIR" "$prefix" "$TYPE" "$nb_chains"
  done
else
  echo "➡️ Skipping STEP 4"
fi

########################################## STEP 5: Combine logs #########################################
if [[ "$STEP" -le 5 ]]; then
  mkdir -p "$COMBINED_DIR"
  nb_chains=6

  for xml in "$XML_DIR"/*.xml; do
    echo "----------------------------------------"
      prefix=$(basename "${xml%.xml}")
      prefix=${prefix##*DBB_}
      prefix=${prefix%_trimmed*}

      echo "chains dir: $CHAINS_DIR"
      echo "combined dir: $COMBINED_DIR"
      "$combineLogsTrees" "$CHAINS_DIR" "$COMBINED_DIR" "$prefix" "$TYPE" "$nb_chains"
  done
else
  echo "➡️ Skipping STEP 5"
fi

########################################## STEP 6: Tip dates #########################################
if [[ "$STEP" -le 6 ]]; then
  "$extractDates" "$COMBINED_DIR"
else
  echo "➡️ Skipping STEP 6"
fi

echo "----------------------------------------------------------------"
echo "Finished at: $(date)"
echo "----------------------------------------------------------------"
