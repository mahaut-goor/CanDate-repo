#!/bin/bash
INPUT=$1
SAMPLE=$2
DEPTH=$3
CONSENSUS=$4
QUALITY=$5

#Extract mitochondrial reads from bam
samtools view -b -F4 $INPUT chrM > results/mtDNA/${SAMPLE}.bam
#Extract length of mitochondrial genome
length=$(samtools view -H results/mtDNA/${SAMPLE}.bam | awk '$2 ~ /^SN:chrM$/ { sub("LN:", "", $3); print $3 }')
#Calculate depth of coverage (mitochondrial genome)
depth=$(samtools depth results/mtDNA/${SAMPLE}.bam | awk -v len="$length" '{sum+=$3} END {print sum/len}')
#Calculate breadth of coverage (mitochondrial genome)
breadth=$(samtools depth results/mtDNA/${SAMPLE}.bam | wc -l | awk -v len="$length" '{print ($1/len)*100 "%"}')
echo "$SAMPLE $depth $breadth" >> results/mtDNA/${SAMPLE}_stats.txt
#Create consensus FASTA
samtools consensus -f FASTA -a -d $DEPTH -c $CONSENSUS --min-MQ $QUALITY results/mtDNA/${SAMPLE}.bam -o results/mtDNA/${SAMPLE}.fasta
#Change FASTA header
cat results/mtDNA/${SAMPLE}.fasta | sed "s/chrM/${SAMPLE}/g" > results/mtDNA/${SAMPLE}_consensus.fasta
mv results/mtDNA/${SAMPLE}_consensus.fasta results/mtDNA/${SAMPLE}.fasta

## original code from Lachie ##