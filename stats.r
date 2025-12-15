#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# Load necessary packages
library(ape)
library(adephylo)
#my_tree <- read.tree("/dss/dsshome1/09/re98gan/ANALYSIS/r_scripts/TN-F-I_strictClock_126samples_PJ35K_combined_tree.nwk")  # Example Newick tree
#tip1 <- "PJ35K_mtDNA"

my_tree <- read.nexus(args[1])
tip1 <- args[2]

# Using ape to get all pairwise distances
patristic_matrix_ape <- cophenetic.phylo(my_tree)
# print(patristic_matrix_ape)

# compute distance to closest tip
dist_to_tip1 <- patristic_matrix_ape[tip1, ]

########### get closest tip to the target tip
closest_tip1 <- names(which.min(dist_to_tip1[dist_to_tip1 > 0]))
closest_distance1 <- min(dist_to_tip1[dist_to_tip1 > 0])
#cat("Closest tip to", tip1, "is", closest_tip1, "with a distance of", closest_distance1, "\n")

########### get 10% closest tips to the target tip
sorted_distances1 <- sort(dist_to_tip1[dist_to_tip1 > 0])
top_10_percent1 <- head(sorted_distances1, length(sorted_distances1) * 0.1)
#cat("10% closest tips to", tip1, ":\n")
#print(top_10_percent1)

########### get mean of 10% closest tips to the target tip
mean_distance1 <- mean(top_10_percent1)
#cat("Mean distance of 10% closest tips to", tip1, "is", mean_distance1, "\n")

#output_file <- paste0(tip1, "_patristic_distances.txt")
#sink(output_file)
#cat("Sample,Closest_Tip,Distance_to_Closest_Tip,Mean_Distance_of_10pct_Closest_Tips\n")
cat(tip1,",",closest_tip1,",",closest_distance1,",",mean_distance1)
#sink()