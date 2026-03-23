# 🐺 **CanDate**

### *Bayesian Molecular Age Estimation for Ancient Canids*

---

## 🧬 Overview

**CanDate** is a bioinformatic pipeline for estimating the **molecular age of ancient canid samples** using **Bayesian tip-dating** on their mitochondrial genomes.

It processes mitochondrial **BAM** or **FASTA** files through the following stages:

* **FASTA extraction**
* **Multiple sequence alignment**
* **XML generation**
* **BEAST MCMC tip-dating analysis**
* **Tip-date extraction**

CanDate is implemented in the **Nextflow framework** (compatible with nf-core standards) and supports **modular resumption** — meaning you can restart the pipeline from any step.

---

## 👩‍🔬 Development Team

Developed by **Mahaut Goor** & **Maulik Upadhyay**
at the *Paleogenomics Lab of Prof. Laurent Frantz*

With the help of:
**Alberto Carmagnini** & **Lachie Scarsbrook**

---

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

---

## 📥 Inputs

### **Required**

1. **BAM files** *or* **FASTA consensus files**

   * Preferably BAM files for full workflow.
   * Input specified via a `.csv` file:

### **Optional**

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

| Tool              | Version   | Notes                                                                   |
| ----------------- | --------- | ----------------------------------------------------------------------- |
| **Nextflow**      | ≥ 25.10.2 | [Install Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) |
| **Conda / Mamba** | Latest    | [Install Conda](https://docs.conda.io/en/latest/miniconda.html)         |
| **Beast**         | v.2.7.8   | [Install Beast v.2.7.8](https://github.com/CompEvol/beast2/releases)    |

---

## 💻 Installation

Will be available in the next weeks 

---

## ▶️ Usage Example

> first run additionnal-scripts/prepare_input.sh

```bash
cd <path/to/your/bams>
bash additionnal-scripts/prepare_input.sh ./ > input_bams.csv
```

> if you have bams from different mapping or don't know the mitochondrial chromosome header, run additionnal-scripts/extractMTChr.sh

```bash
bash additionnal-scripts/extractMTChr.sh ./ input_mt_header.csv
```
> then run nextflow

```bash
mkdir -p res

nextflow run ./candate_nf \
  --input input_bams.csv \
  --outdir ./res \
  --reference_xml ./data/181ancientModernNODLOOP_REFDUMMY_1M.xml \
  --existing_maln ./data/181ancientsModernNODLOOP.fasta \
  --mtdna_map_file input_mt_header.csv
  --num_chain 4 \
  --min_ess 100 
```


## 🧠 Notes

* Nextflow automatically creates trace files tracking process time.
* Always run from a dedicated working directory:

  ```bash
  cd /path/to/working_dir
  ```
* Do **not delete the `work/` directory** until the run is complete — it’s required for resuming.

> ⚠️ For low-coverage BAMs, inspect consensus quality. Adjust `--depth` and `--min_qual` to improve reliability.

---

## 🚧 Upcoming Features

* Automatic filtering step after `samtools`:
  Warn if consensus contains too many Ns (gaps).

  > “Consensus has too many gaps — consider increasing minimum depth or quality thresholds.”

* Sharable on other servers
* add a checkup for the coverage (eg is under a threshold, print a warning)

---

## 📚 References

* **Tip Dating & Leave-One-Out Method:** Loog *et al.*, 2020
* **BEAST:** Bouckaert *et al.*, 2014
* **nf-core Framework:** Ewels *et al.*, 2020
