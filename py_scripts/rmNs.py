from Bio import AlignIO
from Bio import Phylo
from Bio import SeqIO
from Bio.Seq import Seq
import sys
import re

def fasta_to_phylip_relaxed(fasta_file, phylip_file):
    """
    Convert a FASTA alignment file to relaxed PHYLIP format (keeps full sequence labels).
    
    Parameters:
    fasta_file (str): Path to the input FASTA file.
    phylip_file (str): Path to the output PHYLIP file.
    """
    # Read the FASTA file
    alignment = AlignIO.read(fasta_file, "fasta")
    
    # Write to relaxed PHYLIP format
    AlignIO.write(alignment, phylip_file, "phylip-sequential")
    print(f"Converted {fasta_file} to {phylip_file} in relaxed PHYLIP format.")

# Example usage
input_file = sys.argv[1]  # Input FASTA alignment file
output_file = sys.argv[2]  # Output PHYLIP file

# fasta_to_phylip_relaxed(input_file, output_file)


def fasta_to_phylip(fasta_file, phylip_file):
    """
    Convert a FASTA alignment file to PHYLIP format.
    
    Parameters:
    fasta_file (str): Path to the input FASTA file.
    phylip_file (str): Path to the output PHYLIP file.
    """
    # Read the FASTA file
    alignment = AlignIO.read(fasta_file, "fasta")
    
    # Write to PHYLIP format
    AlignIO.write(alignment, phylip_file, "phylip")
    print(f"Converted {fasta_file} to {phylip_file} in PHYLIP format.")

# fasta_to_phylip(input_file, output_file)


def tree_to_newick(treefile, output_newick_file):
    """
    Convert a tree file to Newick format.
    
    Parameters:
    treefile (str): Path to the input tree file.
    output_newick_file (str): Path to the output Newick file.
    """
    # Read the tree file
    tree = Phylo.read(treefile, "newick")  # Assuming input is already in a tree-like format
    
    # Write to Newick format
    with open(output_newick_file, "w") as outfile:
        Phylo.write(tree, outfile, "newick")
    
    print(f"Converted {treefile} to Newick format as {output_newick_file}")

# tree_to_newick(input_file, output_file)


def reformat_labels_and_convert(fasta_file, phylip_file):
    """
    Convert a FASTA alignment file to PHYLIP format with sequence labels reformatted
    to use the first two characters of the genus and species inside brackets.
    
    Parameters:
    fasta_file (str): Path to the input FASTA file.
    phylip_file (str): Path to the output PHYLIP file.
    """
    # Read the alignment file
    alignment = AlignIO.read(fasta_file, "fasta")
    
    # Reformat labels
    for record in alignment:
        # Extract the content inside brackets
        match = re.search(r"\[(.*?)\]", record.id)
        if match:
            full_name = match.group(1)  # Get genus_species
            parts = full_name.split("_")
            if len(parts) == 2:  # Ensure we have both genus and species
                genus, species = parts
                # Take the first 2 characters of each
                new_label = genus[:2] + species[:2]
                record.id = new_label
            else:
                raise ValueError(f"Invalid label format: {record.id}")
        else:
            raise ValueError(f"No brackets found in label: {record.id}")
        
        record.description = ""  # Clear the description to avoid duplications

    # Write to PHYLIP format
    AlignIO.write(alignment, phylip_file, "phylip")
    print(f"Converted {fasta_file} to {phylip_file} with reformatted labels.")

# reformat_labels_and_convert(input_file, output_file)

def replace_n_with_gap(fasta_file, output_file):
    """
    Replace all 'N' or 'n' characters in a FASTA file with '-' and save to a new file.

    Parameters:
    fasta_file (str): Path to the input FASTA file.
    output_file (str): Path to the output FASTA file.
    """
    records = []
    for record in SeqIO.parse(fasta_file, "fasta"):
        # Convert the sequence to a string and replace N/n with -
        new_seq_str = str(record.seq).replace("N", "-").replace("n", "-")
        
        # Assign the modified sequence back as a Biopython Seq object
        record.seq = Seq(new_seq_str)
        records.append(record)
    
    # Write the modified records to the output FASTA file
    SeqIO.write(records, output_file, "fasta")
    print(f"Replaced 'N'/'n' with '-' in {fasta_file} and saved to {output_file}.")

replace_n_with_gap(input_file, output_file)