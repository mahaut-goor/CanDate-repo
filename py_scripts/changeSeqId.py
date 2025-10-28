import sys
from Bio import SeqIO  # type: ignore
import pandas as pd

def changeSeqIDs(infile, outfile, csv_file_path):
    """
    This function reads a table (tab-separated) with two columns: old names and new names.
    It replaces the sequence IDs in the FASTA file according to the mapping provided in the table.
    
    ___________USAGE____________
    arg1: input file with all sequences to filter in fasta format
    arg2: output file name to put renamed sequences in fasta format
    arg3: csv file with old names,new names
    
    """
    # Read the name mappings into a dictionary
    names_file = pd.read_csv(csv_file_path, delimiter=',', encoding="utf-8")
    name_dict = dict(zip(names_file.iloc[:, 0], names_file.iloc[:, 1]))
    print(f"name_dict: {name_dict}")
                
    # Prepare a list to hold renamed sequences
    new_seq = []

    # Parse the input FASTA file and update IDs
    for record in SeqIO.parse(infile, 'fasta'):
        print("_____________________________________")
        print(f"record.description: {record.description}")
        
        if record.description in name_dict:
            print(f"name_dict[record.description]: {name_dict[record.description]}")
            # Rename the sequence description and clear name/description
            record.name = ''
            record.id = name_dict[record.description]
            record.description = ''
            new_seq.append(record)
        else:
            record.name = ''
            record.id = record.description
            record.description = ''
            new_seq.append(record)

    # Write the updated records to the output FASTA file
    SeqIO.write(new_seq, outfile, 'fasta')

# Uncomment this line to run with command line arguments
changeSeqIDs(sys.argv[1], sys.argv[2], sys.argv[3])
    
def changeSeqIDs_intree(infile, outfile, csv_file_path):
    """
    This function reads a table (tab-separated) with two columns: old names and new names.
    It replaces the sequence IDs in any file according to the mapping provided in the table.
    
    ___________USAGE____________
    arg1: input file with all sequences to filter in fasta format
    arg2: output file name to put renamed sequences in fasta format
    arg3: csv file with old names,new names
    
    """
    # Read the name mappings into a dictionary
    names_file = pd.read_csv(csv_file_path, delimiter=',', encoding="utf-8", header=None)
    name_dict = dict(zip(names_file.iloc[:, 0], names_file.iloc[:, 1]))
    intree = open(infile)
    new_tree = str(intree.read())
    intree.close()
    # print(intree)
    # print(f"name_dict: {name_dict}")
    

    # Parse the input FASTA file and update IDs
    for old_label, new_label in name_dict.items():
        # print("_____________________________________")
        
        new_tree = new_tree.replace(old_label, new_label)
    
    f = open(outfile, "a")
    f.write(new_tree)
    f.close()

# Uncomment this line to run with command line arguments
# changeSeqIDs_intree(sys.argv[1], sys.argv[2], sys.argv[3])

