import sys
from Bio import SeqIO

######################################################################
def getSpecificSamples(input_file, sample_ids):
    '''With this funtion, we parse the file containing all sequences into a "record" with 
    an "id" and "seq", if the IDs that are in the file given as sample label file are found in the "input_seq" 
    file, the IDs and its sequence are both put into a new file "newSeqs"
    
    ___________USAGE____________
    arg1: input file with all sequences to filter in fasta format
    arg2: txt file with lables of seuqences to keep
    arg3: output file name to put filtered sequences to keep in fasta format
    '''
    kept_records = []
    
    with open(sample_ids, "r") as labels:
        samples_to_retrieve=[line.rstrip("\n") for line in labels.readlines()]
        # print(f"samples to retriee {samples_to_retrieve}")
    
    for record in SeqIO.parse(input_file, "fasta"):
        print(record)
        for sample in samples_to_retrieve:
            # print(sample)
            if record.id== sample:
                # print(f"sample label: {sample}")
                kept_records.append(record)
                # print(kept_records)
    
    return kept_records

kept_sequences = getSpecificSamples(sys.argv[1], sys.argv[2])


def getSpecificPhylum(input_file, phylum):
    '''
    ___________USAGE____________
    arg1: input file with all sequences to filter in fasta format
    arg2: The phylum you want to keep
    arg3: output file name to put filtered sequences to keep in fasta format
    '''
    kept_records = []
    
    
    for record in SeqIO.parse(input_file, "fasta"):   
        if record.id.startswith(phylum):
            print(f"sample label: {record.id}")
            kept_records.append(record)
    
    return kept_records

#kept_sequences = getSpecificPhylum(sys.argv[1], sys.argv[2])

with open(sys.argv[3], 'w', encoding="utf-8") as out:
    SeqIO.write(kept_sequences, out, 'fasta')