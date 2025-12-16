# CanDate - Canis Ancient DNA Tip-dating Molecular Age Estimation Pipeline

This directory contains all scripts and data used for the estimation of molecular age from mitochondrial sequences.

## 1️⃣ BAM → FASTA Conversion

If you have .bam files, start by extracting mitochondrial (mt) reads and generating consensus sequences.

Script:
/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/bam2MTfasta.sh

Optional:
You can extract additional statistics such as coverage, number of reads, and depth of coverage using:
/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/getStatsMT.sh

## 2️⃣ Alignment & Trimming

Align your sample consensus sequence to the reference database of radiocarbon-dated samples (already aligned).

Script:
/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/runMafftTrimal.sh

## 3️⃣ XML Creation for BEAST

After alignment, generate the BEAST XML configuration file for tip dating.

Script:
/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/ParseXmlST.py

## 4️⃣ Tip Date Estimation

Run the BEAST analysis using the generated XML to estimate tip ages.

Script:
/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/tip_dating_v2.sh

## 5️⃣ Combine Logs and Trees

After BEAST runs are complete, combine all log and tree files into consolidated results.

Script:
/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/combineLogsTrees.sh

## 6️⃣ Extract Tip Ages

Finally, extract the estimated tip ages from the combined log files.

Script:
/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/ExtractTipDate.sh
