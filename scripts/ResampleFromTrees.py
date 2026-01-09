#!/usr/bin/env python3
import sys

"""
Resample a BEAST/MrBayes .trees file by keeping only every Nth tree.

Usage:
    python resample_trees.py input.trees output.trees 100

This keeps every 100th tree.
"""

def resample_trees(input_file, output_file, step):
    header_lines = []
    tree_lines = []
    
    with open(input_file, "r") as infile:
        with open(output_file, "w") as outfile:

            count = 0
            tree_index = 0

            for line in infile:
                # Write NEXUS headers and translation blocks unchanged
                if not line.strip().startswith("tree "):
                    outfile.write(line)
                    continue

                # It's a tree line
                count += 1
                
                # Keep only every Nth tree
                if count % step == 0:
                    outfile.write(line)
                    tree_index += 1

    print(f"Done. Kept {tree_index} trees (one every {step}).")
    print(f"Output written to: {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python resample_trees.py input.trees output.trees <step>")
        sys.exit(1)

    infile = sys.argv[1]
    outfile = sys.argv[2]
    step = int(sys.argv[3])

    resample_trees(infile, outfile, step)
