#!/bin/bash
#SBATCH --job-name=dl_sra
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/dl_sra_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/dl_sra_%j.err
#SBATCH --time=02:00:00
#SBATCH --get-user-env
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_normal
#SBATCH --qos=biohpc_gen_low_prio
#SBATCH --cpus-per-task=4
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=M.Goor@campus.lmu.de

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/sra-tools


accessions=( SRR13762333 SRR13762336 SRR13762337 SRR13762339 SRR13762340 SRR13762344 )
for acc in "${accessions[@]}"; do
  fasterq-dump "$acc" --outdir /dss/lxclscratch/09/re98gan/xx_ancients_bams --split-files --threads 4
done
