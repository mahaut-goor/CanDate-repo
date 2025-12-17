# CanDate - Canis Molecular Tip-Dating

## Overview

This pipeline processes mitochondrial BAM files from multiple samples through **FASTA extraction**, **alignment**, **XML generation**, **BEAST MCMC tip-dating analysis**, and **tip-date extraction**. It is designed to run on a SLURM-managed HPC environment and is modular, allowing resumption from any step.

---

## Pipeline Steps

| Step | Description                                                                                 |
| ---- | ------------------------------------------------------------------------------------------- |
| 1    | Convert BAM files to FASTA sequences (`bam2fasta.sh`).                                      |
| 2    | Align sample FASTA to reference using MAFFT and trim with trimAl (`runMafftTrimal.sh`).     |
| 3    | Generate BEAST XML input files from trimmed alignments (`ParseXmlST.py`).                   |
| 4    | Run BEAST MCMC chains and combine logs and trees (`runMCMC.sh` + `combineLogsTrees_v2.sh`). |
| 5    | Extract tip dates from BEAST output (`ExtractTipDate.sh`).                                  |

---

## Inputs

1. **BAM files**
   Location: `INPUT_DIR/*.bam`
   Requirements:

   * Indexed BAM files (or the pipeline will index them automatically).
   * Reads mapped to mitochondrial genome.

2. **Reference FASTA for alignment**
   Internal in `runMafftTrimal.sh`:

   ```
   /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/data/192ancientsModernNODLOOP_renamed_filtered.fasta
   ```

3. **XML templates / parameters**
   Generated automatically from trimmed alignments.

4. **Pipeline parameters** (set in SLURM job script)

   * `INPUT_DIR`: directory containing BAMs
   * `PREFIX`: sample or run identifier
   * `TYPE`: `new` or `resume`
   * `STEP`: integer 1–5, starting step
   * `nb_chains`: number of BEAST MCMC chains

---

## Outputs

| Step | Output                                        | Description                                       |
| ---- | --------------------------------------------- | ------------------------------------------------- |
| 1    | `$FASTA_DIR/*.fasta`                          | Sample mitochondrial sequences in FASTA format    |
| 2    | `$ALIGN_DIR/*_trimmed.fasta`                  | MAFFT-aligned and trimmed sequences ready for XML |
| 3    | `$XML_DIR/*.xml`                              | BEAST XML input files                             |
| 4    | `$CHAINS_DIR/chain*_*.log`                    | Individual MCMC log files per chain               |
|      | `$CHAINS_DIR/chain*_*.trees`                  | Individual MCMC tree files per chain              |
|      | `$COMBINED_DIR/${prefix}_combined_log.log`    | Combined log file from all chains                 |
|      | `$COMBINED_DIR/${prefix}_resampled_log.trees` | Resampled trees for annotation                    |
|      | `$COMBINED_DIR/${prefix}_resampled_log.tree`  | Annotated tree (TreeAnnotator output)             |
| 5    | `$COMBINED_DIR/tip_dates.tsv`                 | Extracted tip dates for each sample               |

---

## Directory Structure

```text
INPUT_DIR/
├─ fastas/                # FASTA files generated from BAMs
├─ mafft_trimal/          # Trimmed alignments
├─ xml_files/             # XML files for BEAST
├─ chains/                # Raw BEAST chain logs & trees
├─ combined/              # Combined logs, trees, annotated trees, tip dates
└─ <BAM files>            # Input BAMs
```

---

## Dependencies

* **SLURM HPC environment**
* **Conda environment**: `beast_env` containing:

  * BEAST2 (with `treeannotator`, `logcombiner`)
  * MAFFT
  * trimAl
  * samtools
* Python 3.x
* Scripts in `/dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/`

---

## Usage

### Submitting a full pipeline

Edit SLURM job script (e.g., `run_7armenian.sh`) with appropriate parameters:

```bash
INPUT_DIR=/path/to/BAMs
PREFIX="7armenian"
TYPE="new"       # or resume
STEP=1           # Start from step 1
```

Submit job:

```bash
sbatch run_7armenian.sh
```

The pipeline can resume from any step by adjusting `STEP`:

```bash
STEP=3  # Start from XML generation
```

---

### Individual scripts

1. **`bam2fasta.sh`**
   Converts BAM → consensus FASTA.
   Arguments: `INPUT_BAM SAMPLE OUTPUT_DIR`

2. **`runMafftTrimal.sh`**
   Aligns sample to reference, trims alignment.
   Arguments: `INPUT_DIR INPUT_FASTA [OUTPUT_DIR]`

3. **`ParseXmlST.py`**
   Generates XML for BEAST from trimmed alignment.
   Arguments: `OUTPUT_XML ALIGNMENT PREFIX PREFIX_FASTA`

4. **`runMCMC.sh`**
   Runs BEAST chains.
   Arguments: `XML_FILE CHAINS_DIR PREFIX TYPE NUM_CHAINS`

5. **`combineLogsTrees_v2.sh`**
   Combines chain logs & trees, resamples trees, produces annotated tree.
   Arguments: `CHAINS_DIR COMBINED_DIR PREFIX TYPE NUM_CHAINS`

6. **`ExtractTipDate.sh`**
   Extracts tip dates from combined outputs.
   Arguments: `COMBINED_DIR`

---

## Notes

* The pipeline assumes **FASTA files from BAM** contain only mitochondrial sequences.
* The number of threads per BEAST chain is automatically distributed based on `SLURM_CPUS_PER_TASK` and `nb_chains`.
* Intermediate files (logs, trees) are preserved in `chains/` for reproducibility.
* Tip-date extraction produces a single TSV summarizing all samples.

---

## Example Run

```bash
sbatch run_7armenian.sh
```

* Full run from BAM → tip-date extraction.
* Restart pipeline from STEP 4 (BEAST) if previous steps completed:

```bash
STEP=4 sbatch run_7armenian.sh
```
