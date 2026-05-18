#!/usr/bin/env python3
import csv
from pathlib import Path
import sys


def parse_file_names(path: Path):
    stem = path.stem  # e.g. chain10_23_D_Pinarbasi2_15837_updated.xml
    parts = stem.split("_")

    chain_id = parts[0].lstrip("chain")
    seed_id = parts[1].lstrip("run")
    sample_id = "_".join(parts[2:]).split("_updated")[0]
    sample_id = sample_id.split("_")[0]

    return sample_id, chain_id, seed_id

def find_matching_files(beast_dir: Path):
    rows = []

    # iterate over .state files as the anchor
    for state_file in beast_dir.glob("chain*_*.xml.state"):
        sample_id, chain_id, seed_id = parse_file_names(state_file)

        # base without .xml.state
        base = state_file.name.replace(".xml.state", "")
        log_file = beast_dir / f"{base}.log"

        # trees has extra suffix, so glob
        tree_matches = list(beast_dir.glob(f"{base}*.trees"))
        tree_file = tree_matches[0] if tree_matches else ""

        rows.append([
            sample_id,
            chain_id,
            seed_id,
            str(state_file),
            str(log_file),
            str(tree_file),
        ])

    return rows

def find_matching_xml(python_dir: Path):
    rows = []

    for xml_file in python_dir.glob("*.xml"):
        sample = xml_file.name

        if sample.endswith("_updated.xml"):
            sample = sample.removesuffix("_updated.xml")
        else:
            sample = xml_file.stem

        sample = sample.split("_")[0]
        rows.append([
            sample,
            str(xml_file)
        ])

    return rows



def main():
    input_dir = Path(sys.argv[1]).resolve()

    beast_dir = input_dir / "beast"
    python_dir = input_dir / "python"

    output_csv = "combined_resume.csv"

    # Existing functions
    rows = find_matching_files(beast_dir)
    rows_p = find_matching_xml(python_dir)

    # Create lookup: sample -> xml_file
    xml_lookup = {sample: xml_file for sample, xml_file in rows_p}

    combined_rows = []

    for sample, chain, run, state, log, tree in rows:
        xml_file = xml_lookup.get(sample, "")

        combined_rows.append([
            sample,
            xml_file,
            chain,
            run,
            state,
            log,
            tree
        ])

    # Write single CSV
    with open(output_csv, "w", newline="") as f:
        writer = csv.writer(f)

        writer.writerow([
            "sample",
            "xml_file",
            "chain",
            "run",
            "state",
            "log",
            "tree"
        ])

        writer.writerows(combined_rows)

    print(f"Wrote {len(combined_rows)} rows to {output_csv}")

if __name__ == "__main__":
    main()
