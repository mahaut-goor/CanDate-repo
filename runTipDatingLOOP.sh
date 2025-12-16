#!/bin/bash
#SBATCH --job-name=chineseSamplesTD
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/chineseSamplesTD_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/chineseSamplesTD_%j.err
#SBATCH --time=48:00:00
#SBATCH --get-user-env
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_normal 
#SBATCH --qos=biohpc_gen_low_prio
#SBATCH --cpus-per-task=64
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=M.Goor@campus.lmu.de

#########################################
#               INPUTS                  #
#########################################
INPUT_DIR=<path/to/your/folder>
PREFIX=<your_sample_prefix>
TYPE="new"  # new or resume

#########################################
#                  DIR                  #
#########################################
RES_DIR=$INPUT_DIR/results
XML_DIR=$INPUT_DIR/xml_files/

#########################################
#               SCRIPTS                 #
#########################################
runMCMC=/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/runMCMCTipDating.sh
bam2fasta=/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/bam2fasta.sh
runMafftTrimal=/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/runMafftTrimal.sh
parseXml=/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/ParseXmlST.py

########################################## BAM to FASTA #########################################
for bam in $INPUT_DIR"/"*".bam"; do
    INPUT_BAM=$bam
    INPUT_SAMPLE=$(basename ${bam%.bam})
    mkdir -p $RES_DIR $XML_DIR

    echo "Processing BAM: $INPUT_BAM"
    echo "Sample Name: $INPUT_SAMPLE"
    echo "Results Directory: $RES_DIR"

    source $bam2fasta "$INPUT_BAM" "$INPUT_SAMPLE" "$RES_DIR"
done

########################################## Mafft trimal #########################################
for fasta in $INPUT_DIR/*.fasta; do
  INPUT_FASTA=$fasta
  source $runMafftTrimal $INPUT_DIR $INPUT_FASTA
done

# ######################################### Parse XMLs #########################################
for alignment in $INPUT_FASTA"/"*"_trimmed.fasta"; do
    prefix_fasta=$(basename ${alignment%.fasta})
    echo "prefix fasta $prefix_fasta"
    prefix=${prefix_fasta##*DBB_}
	prefix=${prefix%_trimmed*}
    echo "prefix sample $prefix"
    new_xml=$XML_DIR/$prefix.xml
    python $parseXml "$new_xml" "$alignment" "$prefix" "$prefix_fasta"
done


#########################################
#       SUBMIT RESUME JOBS
#########################################
echo "----------------------------------------------------------------"
echo "Starting at: $(date)"
echo "----------------------------------------------------------------"

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate /dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env #create and env for beast

beast=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/beast
treeannotator=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/treeannotator
logcombiner=/dss/dsshome1/09/re98gan/ANALYSIS/envs/beast_env/beast/bin/logcombiner

# echo "------------------------"
# echo "Combining chains..."
chains=$INPUT_DIR/chains

echo "Submitting RESUME jobs..."
for xml in $XML_DIR"/"*".xml"; do
    prefix=$(basename ${xml%.xml})
    prefix=${prefix##*DBB_}
	prefix=${prefix%_trimmed*}
    
    echo "------------------------"
    echo "Resuming $prefix"
    echo "XML: $xml"
    echo "------------------------"

    source "$runMCMC" "$xml" "$INPUT_DIR" "$prefix" "new"

    echo "chains1 is : $chains/chain1_$prefix.log"
    echo "output is : $INPUT_DIR/COMBINE_VF_$prefix.log"
    
    $logcombiner -b 10 -log $chains"/chain1_"$prefix".log" -log $chains"/chain2_"$prefix".log" -log $chains"/chain3_"$prefix".log" -log $chains"/chain4_"$prefix".log" -o $INPUT_DIR"/COMBINED_"$prefix".log"

done

echo "----------------------------------------------------------------"
echo "Finishing at: $(date)"
echo "----------------------------------------------------------------"
