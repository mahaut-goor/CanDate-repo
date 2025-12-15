#!/bin/bash
#SBATCH --job-name=searchSamples
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/searchSamples_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/searchSamples_%j.err
#SBATCH --time=02:00:00
#SBATCH --get-user-env
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_normal 
#SBATCH --qos=biohpc_gen_low_prio
#SBATCH --cpus-per-task=4
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=M.Goor@campus.lmu.de

patterns=(
AL3118 AL2242 AL3165 AL2840 AL2892 OL4161 AL2706
TH1 TH3 TH10 TH8 CGG31 TH15 TH7 TH12
AL2988 AL2991 AL2994 AL2995 AL2997
KF661092 KF661087 KF661095 KF661088 KF661090 KF661080 KF661078
)

search_path="/dss/dssfs02/pn29qe/pn29qe-dss-0000"

for p in "${patterns[@]}"; do
    echo "Searching for: $p"
    find "$search_path" -type f -iname "*$p*" >> /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/data/found_samples.txt
done
