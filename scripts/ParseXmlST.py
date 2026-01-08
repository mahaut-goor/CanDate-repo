#!/usr/bin/env python3
import sys
from Bio import SeqIO


def replace_alignment(fasta_path: str) -> str:
    """Generate <sequence> XML lines from a FASTA alignment."""
    sequences = list(SeqIO.parse(fasta_path, "fasta"))
    seq_lines = [
        f'    <sequence id="seq_{record.id}" spec="Sequence" taxon="{record.id}" '
        f'totalcount="4" value="{str(record.seq)}"/>'
        for record in sequences
    ]
    print(f"✅ Parsed {len(sequences)} sequences from {fasta_path}")
    return "\n".join(seq_lines)


def parse_xml_tip_dates(
    input_xml: str,
    output_xml: str,
    old_sample_id: str,
    new_sample_id: str,
    fasta_old_name: str,
    fasta_new_name: str,
    input_alignment: str,
):
    """Replace taxon names and alignment data in a BEAST XML for new sample."""

    old_sample_id = old_sample_id.strip()
    print(f"Old sample ID: {old_sample_id}")
    new_sample_id = new_sample_id.strip()
    print(f"New sample ID: {new_sample_id}")

    # Extract the prefix used for the tipDatesSampler and taxonset IDs
    old_tip_id = "_".join(old_sample_id.split("_")[:-1])
    print(f"Old tip ID: {old_tip_id}")
    new_tip_id = [("_".join(new_sample_id.split("_")[:-1])) if "_" in new_sample_id else new_sample_id][0]
    print(f"New tip ID: {new_tip_id}")

    with open(input_xml, "r") as file:
        xml_content = file.read()

    # Replace the FASTA alignment ID/name
    xml_content = xml_content.replace(fasta_old_name, fasta_new_name)

    # Replace tip IDs throughout
    xml_content = xml_content.replace(
        f'taxonset id="{old_tip_id}"', f'taxonset id="{new_tip_id}"'
    )
    xml_content = xml_content.replace(
        f'<taxon id="{old_sample_id}"', f'<taxon id="{new_sample_id}"'
    )
    xml_content = xml_content.replace(
        f'taxonset="@{old_tip_id}"', f'taxonset="@{new_tip_id}"'
    )
    xml_content = xml_content.replace(
        f'id="tipDatesSampler.{old_tip_id}"', f'id="tipDatesSampler.{new_tip_id}"'
    )
    xml_content = xml_content.replace(
        f'id="{old_tip_id}.prior"', f'id="{new_tip_id}.prior"'
    )
    xml_content = xml_content.replace(
        f'idref="{old_tip_id}.prior"', f'idref="{new_tip_id}.prior"'
    )
    print(f"✅ Replaced sample ID {old_sample_id} with {new_sample_id}")

    # Replace the alignment <data> block
    start_tag = "<data"
    end_tag = "</data>"
    start_index = xml_content.find(start_tag)
    end_index = xml_content.find(end_tag, start_index)
    if start_index == -1 or end_index == -1:
        raise ValueError("Could not find <data> block in XML.")
    end_index += len(end_tag)

    # Build new alignment XML
    new_sequence_lines = replace_alignment(input_alignment)
    new_data_block = (
        f'<data id="{fasta_new_name}" spec="Alignment" name="alignment">\n'
        f"{new_sequence_lines}\n</data>"
    )

    # Replace the old alignment block
    old_data_block = xml_content[start_index:end_index]
    xml_content = xml_content.replace(old_data_block, new_data_block)

    # Write updated XML
    with open(output_xml, "w") as file:
        file.write(xml_content)

    print(f"✅ Wrote updated XML to {output_xml}")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print(
            "Usage:\n  python parse_xml_tip_dates.py <output_xml> "
            "<input_alignment.fasta> <new_sample_id> <fasta_new_name>"
        )
        sys.exit(1)

    output_xml = sys.argv[1]
    input_alignment = sys.argv[2]
    new_id = sys.argv[3]
    fasta_new_name = sys.argv[4]

    # The FASTA "old name" can be extracted from the old XML if needed.
    # For now, assume you know it explicitly:
    input_xml = r"/dss/dsshome1/09/re98gan/ANALYSIS/CanDate-repo/data/DOG_DBB_D_Pinarbasi2_15837_final_trimmed_10MA.xml"
    old_id = "D_Pinarbasi2_15837"
    fasta_old_name = "DOG_DBB_D_Pinarbasi2_15837_final_trimmed"

    parse_xml_tip_dates(
        input_xml,
        output_xml,
        old_id,
        new_id,
        fasta_old_name,
        fasta_new_name,
        input_alignment,
    )
