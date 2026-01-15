#!/bin/bash

INPUT=$1
SAMPLE=$2
DIR=$3
DEPTH=5
CONSENSUS=0.75
QUALITY=30

# Output file paths
MT_BAM="$DIR/${SAMPLE}.bam"
MT_TEMP_FASTA="$DIR/fastas/${SAMPLE}_temp.fasta"
MT_STATS="$DIR/fastas/${SAMPLE}_samcoverage.txt"
MT_FASTA="$DIR/fastas/${SAMPLE}.fasta"

module load slurm_setup
eval "$(conda shell.bash hook)"
conda activate samtools 


# -----------------------------------------------------------------------------
# 0. Check and index BAM file if not already indexed
# -----------------------------------------------------------------------------
# BAM_INDEX="${INPUT}.bai"

# if [[ ! -f "$BAM_INDEX" ]]; then
#   echo "❌ No index file found — creating BAM index..."
#   samtools index "$INPUT"
#   echo "✅ Index file created: $BAM_INDEX"
# else
#   echo "✅ BAM index already exists: $BAM_INDEX"
# fi

# # -----------------------------------------------------------------------------
# # 1. Detect mitochondrial reference name in BAM header
# # -----------------------------------------------------------------------------
# MT_REF=$(samtools view -H "$INPUT" | \
#   samtools view -H "$INPUT" | \
#   awk '/@SQ/ && ($2 ~ /SN:(MT|chrM|chrMT|NC_002008\.4|chrM[^[:space:]]*)$/) { sub("SN:", "", $2); print $2 }' | head -n1 )


# if [[ -z "$MT_REF" ]]; then
#   echo "❌ Error: Could not find mitochondrial reference (MT, chrM, chrMT or 4) in BAM header."
#   echo "Header references found:"
#   samtools view -H "$INPUT" | grep '^@SQ' || true
#   exit 1
# fi

# echo "✅ Detected mitochondrial reference: $MT_REF"

# # -----------------------------------------------------------------------------
# # 2. Extract mitochondrial alignments
# # -----------------------------------------------------------------------------
# samtools view -b -F 4 "$INPUT" "$MT_REF" -o "$MT_BAM"

# if [[ ! -s "$MT_BAM" ]]; then
#   echo "❌ Error: Mitochondrial BAM file ($MT_BAM) is empty."
#   exit 1
# fi

# echo "✅ Extracted mitochondrial reads to $MT_BAM"

# # -----------------------------------------------------------------------------
# # 3. Generate coverage statistics
# # -----------------------------------------------------------------------------
# samtools coverage "$MT_BAM" > "$MT_STATS"
# echo "✅ Wrote coverage stats to $MT_STATS"

# -----------------------------------------------------------------------------
# 4. Create consensus FASTA
# -----------------------------------------------------------------------------
samtools consensus -f FASTA -a -d "$DEPTH" -c "$CONSENSUS" --min-MQ "$QUALITY" "$MT_BAM" -o "$MT_FASTA"
echo "✅ Consensus FASTA created at $MT_FASTA"

# -----------------------------------------------------------------------------
# 5. Rename FASTA header (replace MT/chrM/4 with sample name)
# -----------------------------------------------------------------------------
sed "s/^>.*/>${SAMPLE}/" "$MT_FASTA" > "$MT_TEMP_FASTA"
mv "$MT_TEMP_FASTA" "$MT_FASTA"

echo "✅ Updated FASTA header with sample name: $SAMPLE"

# -----------------------------------------------------------------------------
# 6. Summary
# -----------------------------------------------------------------------------
echo "🎉 Pipeline complete!"
echo "Output files:"
echo "  BAM:   $MT_BAM"
echo "  Stats: $MT_STATS"
echo "  FASTA: $MT_FASTA"
