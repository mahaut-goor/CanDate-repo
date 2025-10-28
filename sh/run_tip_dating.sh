#!/bin/bash
#SBATCH --job-name=tdSamp1
#SBATCH --output=/dss/dsshome1/09/re98gan/ANALYSIS/out/datinsSamples1_%j.out
#SBATCH --error=/dss/dsshome1/09/re98gan/ANALYSIS/err/datinsSamples1_%j.err
#SBATCH --time=02:00:00
#SBATCH --get-user-env
#SBATCH --clusters=cm4
#SBATCH --partition=cm4_tiny
#SBATCH --cpus-per-task=32
#SBATCH --export=NONE
#SBATCH --mail-type=ALL
#SBATCH --mail-user=M.Goor@campus.lmu.de

#########
######### add a step to create the xml file using a aligment fast and tsv with samples + C14 dates as input 
#########

output_dir=/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/tests/testing20samplescalC14_1/leave-one-out_3
input_xml=$output_dir/strictClock_datingD_Croatia_SOTN01_20seq.xml
samples_to_run=/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/tests/testing20samplescalC14_1/leave-one-out_1/sample_ids.txt
dos2unix "$samples_to_run"

old_id="D_Croatia_SOTN01_4748"

while read sample; do
    echo "------------------------------------------------------"
    echo "Old ID: $old_id"
    echo "Input XML: $input_xml"
    echo "output dir: ${output_dir}"

    echo "-----------------------"
    echo "New ID: $sample"

    wrkg_dir="${output_dir}/strictClock_dating_"${sample}"_analysis" 
    mkdir -p "$wrkg_dir"
    echo "Working directory: $wrkg_dir"

    new_xml="strictClock_dating_${sample}.xml"
    echo "New file: $new_xml"
    
    python /dss/dsshome1/09/re98gan/ANALYSIS/py_scripts/parse_xml.py "$input_xml" "${wrkg_dir}/$new_xml" "$old_id" "$sample"

done < "$samples_to_run"

# echo "All folders and files created."

while read sample; do
    echo "------------------------------------------------------"
    echo "Old ID: $old_id"
    echo "Input XML: $input_xml"
    echo "output dir: ${output_dir}"

    echo "-----------------------"
    echo "New ID: $sample"

    wrkg_dir="${output_dir}/strictClock_dating_"${sample}"_analysis" 
    echo "Working directory: $wrkg_dir"
    new_xml="strictClock_dating_${sample}.xml"
    echo "New file: $new_xml"

    # Run the analysis for this modified XML
    source /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/tip_dating_v2.sh "${wrkg_dir}/$new_xml" "$wrkg_dir" "$sample"

done < "$samples_to_run"

echo "All analyses completed."


# "$output_dir/sample_ids.txt"

# prefix=$(basename "$input_xml" .xml)
# output_dir=$(dirname "$input_xml")/"$prefix"

#read aligment fasta
# fasta=/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/data/17calC14_3moderns_lachie_renamed.fasta
# # extract samples ids
# grep ">" $fasta | sed 's/>//g' > $output_dir/sample_ids.txt

# use first sample id from the generated list as old_id
# read -r old_id < "$output_dir/sample_ids.txt"