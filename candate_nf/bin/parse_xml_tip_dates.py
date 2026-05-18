#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET
from Bio import SeqIO
from pathlib import Path


def load_fasta_sequences(fasta_path):
    records = list(SeqIO.parse(fasta_path, "fasta"))
    if not records:
        raise ValueError(f"No sequences found in alignement{fasta_path}")
    return records


def detect_alignment_data(root):
    data_blocks = root.findall(".//data") # here we find the alignement block in the xml
    if len(data_blocks) != 1:
        raise ValueError(
            f"Expected exactly one <data> block, found {len(data_blocks)}"
        )
    return data_blocks[0]


def detect_old_id(root):
    taxa = root.findall(".//taxon")# this allows to detect the old sample id directly in the xml (ie <taxon id="old_id")
    ids = {t.attrib["id"] for t in taxa if "id" in t.attrib}
    if len(ids) != 1:
        raise ValueError(
            f"Expected exactly one taxon ID, found: {ids}"
        )
    return ids.pop()

def detect_prior_name(root):
    #detect taxonset
    prior = root.findall(".//taxonset")# this allows to detect the old sample id directly in the xml (ie <taxon id="old_id")
    ids = {t.attrib["id"] for t in prior if "id" in t.attrib}
    if len(ids) != 1:
        raise ValueError(
            f"Expected exactly one taxon ID, found: {ids}"
        )
    return ids.pop()

def replace_taxon_ids(root, old_id, new_id):
    count=0
    for elem in root.iter():
        # print(f"Checking element: {elem.tag} with attributes {elem.attrib} ")
        for attr in elem.attrib:
            if old_id in elem.attrib[attr]:
                # print(f"Replacing in element: {elem.tag} attribute: {attr} value: {elem.attrib[attr]}")
                count+=1
                elem.attrib[attr] = elem.attrib[attr].replace(old_id, new_id)
    print(f'number of occurrences to replace: {count}')

def replace_fasta_ids(root, fasta_path):
    count=0
    old_alignment_id = detect_alignment_data(root).attrib["id"]
    # print(f"Old alignment ID to replace: {old_alignment_id}")
    new_alignment_id = Path(fasta_path).stem
    # print(f"New alignment ID from FASTA: {new_alignment_id}")
    
    for elem in root.iter():
        if elem.tag == "data":
            continue  # Skip the data block itself
        # print(f"Checking element: {elem.tag} with attributes {elem.attrib} ")
        for attr in elem.attrib:
            if old_alignment_id in elem.attrib[attr]:
                # print(f"Replacing in element: {elem.tag} attribute: {attr} value: {elem.attrib[attr]}")
                count+=1
                elem.attrib[attr] = elem.attrib[attr].replace(old_alignment_id, new_alignment_id)
    print(f'number of occurrences to replace: {count}')

# def update_date_trait(root, old_id, new_id):
#     for trait in root.findall(".//trait"):
#         if trait.attrib.get("traitname") == "date-backward":
#             trait.attrib["value"] = f"{new_id}=0"


def replace_alignment(data_block, fasta_records, new_alignment_id):
    data_block.attrib["id"] = new_alignment_id
    data_block.clear()

    data_block.attrib.update({
        "id": new_alignment_id,
        "spec": "Alignment",
        "name": "alignment",
    })

    for record in fasta_records:
        seq_elem = ET.SubElement(data_block, "sequence")
        seq_elem.attrib = {
            "id": f"seq_{record.id}",
            "spec": "Sequence",
            "taxon": record.id,
            "totalcount": "4",
            "value": str(record.seq),
        }


def main():
    if len(sys.argv) != 5:
        sys.exit(
            "Usage:\n"
            "  python ParseXmlST.py <input.xml> <alignment.fasta> <output.xml> <new_sample_id>"
        )

    input_xml, fasta_path, output_xml, new_sample_id = sys.argv[1:]

    # 1) UPDATING SAMPLE ID
    #old xml parsing
    tree = ET.parse(input_xml)
    root = tree.getroot()
    old_sample_id = detect_old_id(root)
    replace_taxon_ids(root, old_sample_id, new_sample_id)
    
    # 2) UPDATING PRIOR NAME
    old_prior_name = detect_prior_name(root)
    new_prior_name = f"{new_sample_id}_x"
    replace_taxon_ids(root, old_prior_name, new_prior_name)
    
    # 2) UPDATING ALIGNMENT BLOCK 
    data_block = detect_alignment_data(root)
    old_alignment_id = data_block.attrib["id"]
    #new alignement parsing
    fasta_records = load_fasta_sequences(fasta_path)
    new_alignment_id = Path(fasta_path).stem

    # 3) UPDATING FASTA ID IN ROOT except data block
    replace_fasta_ids(root, fasta_path)

    # 4) UPDATING ALIGNMENT BLOCK
    replace_alignment(data_block, fasta_records, new_alignment_id)
    
    # 5) WRITING UPDATED XML
    tree.write(output_xml, encoding="utf-8", xml_declaration=True)
    print(f"✅ Wrote updated XML to {output_xml}")


if __name__ == "__main__":
    main()

