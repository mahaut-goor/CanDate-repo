import xml.etree.ElementTree as ET
from pathlib import Path
from Bio import SeqIO

from ParseXmlST_v2 import (
    load_fasta_sequences,
    detect_taxa,
    detect_alignment_data,
    replace_taxon_ids,
    update_date_trait,
    replace_alignment,
)

###################################### SOTN01 to Pinarbasi2  ######################################
    input_xml = Path(
    "/dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/pipelines/CanDate-repo-main/20seqexample/SOTN01_to_Pinarbasi2/TEST_D_Croatia_SOTN01_20seq_2.xml"
)

    fasta_path = Path(
    "/dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/pipelines/CanDate-repo-main/20seqexample/SOTN01_to_Pinarbasi2/17calC14_3moderns_lachie_noSOTN01_trimed_wPinarbasi2.fasta"
)
    output_xml = Path("/dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/pipelines/CanDate-repo-main/20seqexample/SOTN01_to_Pinarbasi2/UPDATED_D_Croatia_SOTN01_20seq_2.xml") ## change here to avoid overwriting

    new_sample_id = "D_Pinarbasi2_15837"
    
###################################### Pinarbasi2 to SOTN01 ######################################
    input_xml = Path(
    "/dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/pipelines/CanDate-repo-main/20seqexample/Pinarbasi2_to_SOTN01/TEST_D_Croatia_SOTN01_20seq.xml"
)

    fasta_path = Path(
    "/dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/pipelines/CanDate-repo-main/20seqexample/Pinarbasi2_to_SOTN01/17calC14_3moderns_lachie_wSOTN01_noPinarbasi2_trimed.fasta"
)
    output_xml = Path("/dss/dssfs02/pn29qe/pn29qe-dss-0000/workflows/nextflow/pipelines/CanDate-repo-main/20seqexample/Pinarbasi2_to_SOTN01/UPDATED_TEST_D_Pinarbasi2_20seq.xml")

    new_sample_id = "D_Croatia_SOTN01_4748"
    

##############" RUN"
# 1) UPDATING SAMPLE ID
#old xml parsing
tree = ET.parse(input_xml)
root = tree.getroot()
old_sample_id = detect_old_id(root)
# print("------------------------------------")
# print(f"Detected old sample ID: {old_sample_id}") 
# print(f"Replacing sample ID '{old_sample_id}' → '{new_sample_id}'")
replace_taxon_ids(root, old_sample_id, new_sample_id)

# 2) UPDATING PRIOR NAME
old_prior_name = detect_prior_name(root)
print("------------------------------------")
print(f"Detected old prior name: {old_prior_name}")
new_prior_name = f"{new_sample_id}_x"
print(f"Replacing prior name '{old_prior_name}' → '{new_prior_name}'")
replace_taxon_ids(root, old_prior_name, new_prior_name)

# 2) UPDATING ALIGNMENT BLOCK 
# now we look for the alignement block WITHIN the xml (so the old alignement block) 
data_block = detect_alignment_data(root)
old_alignment_id = data_block.attrib["id"]
# print("------------------------------------")
# print(f"Detected old alignment ID: {old_alignment_id}")

#new alignement parsing
fasta_records = load_fasta_sequences(fasta_path)
# print("------------------------------------")
# print(f"Loaded {len(fasta_records)} sequences from {fasta_path}")
#and we get the new alignement id from the fasta file
new_alignment_id = Path(fasta_path).stem
# print(f"New alignment ID from FASTA: {new_alignment_id}")
# print(f"Replacing alignment '{old_alignment_id}' → '{new_alignment_id}'")

# 3) UPDATING FASTA ID IN ROOT except data block
print("------------------------------------")
print(f"Updating alignment ID references in XML from '{old_alignment_id}' to '{new_alignment_id}'")
replace_fasta_ids(root, fasta_path)

# 4) UPDATING ALIGNMENT BLOCK
print("------------------------------------")
print(f"Replacing alignment bloc '{old_alignment_id}' → '{new_alignment_id}'")
replace_alignment(data_block, fasta_records, new_alignment_id)

# 5) WRITING UPDATED XML
tree.write(output_xml, encoding="utf-8", xml_declaration=True)
print(f"✅ Wrote updated XML to {output_xml}")