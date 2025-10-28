import argparse
import pandas as pd
import numpy as np
from sklearn.manifold import TSNE
import scipy.cluster.hierarchy as sch
import matplotlib.pyplot as plt
from adjustText import adjust_text  # type: ignore
from matplotlib.lines import Line2D


##### DOC

#######################################
#            USAGE INFO            #
#######################################
# Script to check fasta files and csv files for tip dating analyses
# Checks if fasta file is aligned
# Checks if sample names in fasta correspond to csv file

# python oop_script.py <input_fasta> <output_dir> <input_csv> ==> to check fasta files and csv files

class TDInputChecker:
    def __init__(self, fasta_file, csv_file, output_dir):
        self.fasta_file = fasta_file
        self.csv_file = csv_file
        self.output_dir = output_dir
        self.analysis_type = analysis_type

    def check_fasta(self):
        # Implement fasta checking logic here
        # #########################################
        # check fasta file ==> make sur its aligned
        # check the labels (sample names) correspond to the csv file
        # check if labels are in good format (no spaces, special characters etc)
        pass

    def check_csv(self):
        # Implement csv checking logic here
        # # check csv file
        # check if it has two columns: sample names and tip dates
        # check if sample names correspond to fasta file
        # check if all samples have tip dates
        pass

    def run_checks(self):
        self.check_fasta()
        self.check_csv()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check fasta and csv files for tip dating analyses.")
    parser.add_argument("fasta_file", help="Input aligned fasta file")
    parser.add_argument("csv_file", help="Input csv file with samples and tip dates")

    args = parser.parse_args()

    checker = TDInputChecker(args.fasta_file, args.csv_file)
    checker.run_checks()





