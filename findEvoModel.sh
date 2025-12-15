#!/bin/bash
#SBATCH --job-name=iqtree205
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/iqtree205_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/iqtree205_%j.err
#SBATCH --time=02:00:00
#SBATCH --get-user-env
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_normal 
#SBATCH --qos=biohpc_gen_low_prio
#SBATCH --cpus-per-task=32
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=M.Goor@campus.lmu.de

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env #create and env for beast

dir="/dss/lxclscratch/09/re98gan/205ancientsModern"
iqtree_output="$dir/iqtree_output"
mkdir -p "$iqtree_output"

input_fasta="/dss/lxclscratch/09/re98gan/205ancientsModern/192ancientsModernNODLOOP_renamed_filtered.fasta"
# Run ModelFinder to select the best model before running tree inference
iqtree -s "$input_fasta" \
    -m MF \
    -pre "$iqtree_output"/192ancientsModernNODLOOP_renamed_filtered \
    -nt AUTO \
    -ntmax 32

