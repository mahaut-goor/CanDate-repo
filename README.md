# 🐺 **CanDate**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new/popgen48/beast_tip_dating)
[![GitHub Actions CI Status](https://github.com/popgen48/beast_tip_dating/actions/workflows/nf-test.yml/badge.svg)](https://github.com/popgen48/beast_tip_dating/actions/workflows/nf-test.yml)
[![GitHub Actions Linting Status](https://github.com/popgen48/beast_tip_dating/actions/workflows/linting.yml/badge.svg)](https://github.com/popgen48/beast_tip_dating/actions/workflows/linting.yml)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A525.04.0-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-3.4.1-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/3.4.1)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/popgen48/beast_tip_dating)

### *Bayesian Molecular Age Estimation for Ancient Canids*

---

## 👩‍🔬 Development Team

Developed by:
* **Mahaut Goor** Chair of Animla System Genomics, LMU, Munich, Germany
* **Maulik Upadhyay** Staatlichen Naturwissenschaftlichen Sammlungen Bayerns, Munich, Germany

---

## 🧬 Overview

**CanDate** is a bioinformatic pipeline for estimating the **molecular age of ancient samples** using **Bayesian tip-dating** on mitochondrial genomes.


## ⚙️ Pipeline Steps

| Step  | Description                                                        |
| ----- | ------------------------------------------------------------------ |
| **1** | Convert BAM files to FASTA sequences                               |
| **2** | Align sample FASTAs to a reference with MAFFT and trim with trimAl |
| **3** | Generate BEAST XML input files                                     |
| **4** | Run BEAST MCMC chains                                              |
| **5** | Combine logs and trees                                             |
| **6** | Extract tip dates from BEAST outputs                               |

> 💡 You can resume from any step in case of interruption.
> See --help for all options 

---

## 📥 Inputs

### **Required**

1. **BAM files** *or* **FASTA consensus files**

   * Preferably BAM files for full workflow.
   * Input specified via a `.csv` file:

### **Optional**

> CanDate was originaly developped to date canids samples, input xml and fasta can be found in data/canids

2. **Reference FASTA for alignment**
   Default provided:

   ```bash
   ./data/181ancientsModernNODLOOP.fasta
   ```

3. **XML template**
   Default BEAST XML template:

   ```bash
   ./data/181ancientModernNODLOOP_REFDUMMY_1M.xml
   ```

---

## 🧬 Dependencies

CanDate is implemented in the **Nextflow framework** and supports **modular resumption** — meaning you can restart the pipeline from any step. We have included all the necessary tools inside a singularity container. In order to run the pipeline, you need to have nextflow installed as well as singularity.

| Tool              | Version   | Notes                                                                                  |
| ----------------- | --------- | ---------------------------------------------------------------------------------------|
| **Nextflow**      | ≥ 25.10.2 | [Install Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)                |
| **singularity**   | Latest    | [Install Singularity](https://docs.sylabs.io/guides/3.0/user-guide/installation.html)  |
| **candate.sif**   | /         | [Install candate.sif](https://github.com/Popgen48/candate-container/releases/tag/v1.0) |
---

## 💻 Installation

> After downloading **candate.sif** you need to run this comand:

```bash
apptainer exec \
 >  -B "$HOME/.beast:$HOME/.beast" \
 >  <path_to_candate.sif> \
 >  packagemanager -add SSM
```

---

## ▶️ Usage Example

> first run additionnal-scripts/prepare_input.sh

```bash
cd <path/to/your/bams>
bash additionnal-scripts/create_input/prepare_input_bam.sh ./ > input_bams.csv
```

> if you have bams from different mapping or don't know the mitochondrial chromosome header, run additionnal-scripts/extractMTChr.sh

```bash
bash additionnal-scripts/create_input/extractMTChr.sh ./ input_mt_header.csv
```
> then run nextflow

```bash
mkdir -p res

nextflow run candate_nf \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR>
  --reference_xml <path_to_the_referenc_xml> \
  --existing_maln <path_to_the_referenc_fasta> \
  --mtdna_map_file input_mt_header.csv \
  --num_chain 4 \
  --min_ess 70 
```

> all options are documented in the help - use:

```bash
nextflow run candate_nf --help
```

## Running for Canids

> CanDate has been extensively tested on canid mitochondrial genomes. Use the provided reference files:

```bash
nextflow run candate_nf \
  --reference_xml data/canids/181ancientModernNODLOOP_REFDUMMY_1M.xml \
  --existing_maln data/canids/181ancientsModernNODLOOP.fasta \
  ...
```

## Running for New Species

> To apply CanDate to a new species or add samples to the reference dataset, you need to create new reference files and validate estimates using a leave-one-out approach. This compares estimated ages against known radiocarbon dates.

### Step 1: Create Reference Alignment
> Prepare a multiple sequence alignment of your reference samples.

### Step 2: Create Reference XML
>Find the evolutionary model: Run a model finder (e.g., IQ-TREE ModelFinder; Kalyaanamoorthy et al. 2017) to determine the best-fit substitution model.
>Create the initial XML manually: Use the BEAUti GUI (Drummond et al. 2012) with your alignment and selected model. 
>Configure:
>Substitution rate estimation and clock model (strict or relaxed)
>Tip dates — essential for age estimation
>MRCA prior: Select any sample, append _x to the taxon name, apply a uniform distribution with "tips only" enabled, and set an appropriate upper bound (e.g., 100,000 years)
>Chain length of 1,000,000 is sufficient; the pipeline automatically extends runs until ESS targets are met

### Step 3: Generate Leave-One-Out XML Files

```bash
bash additional-scripts/leave_one_out/runParse_XML.sh <alignment> <samples_to_test>
```

### Step 4: Prepare Input for Leave-One-Out
```bash
bash additional-scripts/create_input/prepare_input_xml.sh
```

### Step 5: Run BEAST with Skip Options

```bash
nextflow run candate_nf \
  --skip_consensus \
  --skip_maln \
  --skip_parse_xml \
  ...
```

### Option	Default	Description

```bash
--skip_consensus	false	Skip BAM → FASTA consensus generation
--skip_maln	false	Skip sequence alignment
--skip_parse_xml	false	Skip XML generation
--beast_resume	false	Resume an existing BEAST run
```

## 🧠 Notes

* Nextflow automatically creates trace files tracking process time.
* Always run from a dedicated working directory:

  ```bash
  cd /path/to/working_dir
  ```
* Do **not delete the `work/` directory** until the run is complete — it’s required for resuming.

> ⚠️ For low-coverage BAMs, inspect consensus quality. Adjust `--depth` and `--min_qual` to improve reliability.

> if the pipaline has not finished before teh time limitation you used for running the jobs, you ca use the option --beast_resume (default: false)
    Resume an existing BEAST run. which will automatically run teh analysis from running chains.

---

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/main/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
