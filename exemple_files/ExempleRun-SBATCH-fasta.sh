#!/bin/bash
#SBATCH --job-name=exRunCanDate
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/exRunCanDate_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/exRunCanDate_%j.err
#SBATCH --time=48:00:00
#SBATCH --get-user-env
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_normal
#SBATCH --cpus-per-task=96
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your.email@lrz.de

#---------------------- Exemple Run of CanDate Pipeline ----------------------#
# Exemple for running the CanDate Nextflow pipeline on LRZ cluster using SBATCH
# This starts 20 samples with 4 MCMC chains, which each chains heving to each 100 for each parameters to finish
# The example uses an existing multiple alignment and skips the consensus step
# Adjust the parameters as needed and run this script with sbatch
# ----------------------------------------------------------------------------#
nextflow run /dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/pipelines/popgen48-beast_tip_dating \
    --input FASTA20samples.csv \
    --outdir /dss/lxclscratch/09/re98gan/TESTS/downsampleReads/mtdownsample/10x \
    --reference_xml /dss/lxclscratch/09/re98gan/TESTS/downsampleReads/168ancientModernNODLOOP_REFDUMMY_1M.xml \
    --existing_maln /dss/lxclscratch/09/re98gan/TESTS/downsampleReads/168ancientsModernNODLOOP.fasta \
    --skip_consensus true \
    --num_chain 4 \
    --min_ess 100 \
    -profile lrz_cm4_custom \
    -qs 8


# 20 samples x 4 chains = 80 runs to be scheduled
# 96 cpus-per-task with qs 8 means 8 processes run in parralele with 12 cpus each
