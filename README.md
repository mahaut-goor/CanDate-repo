# 🐺 **CanDate**

### *Bayesian Molecular Age Estimation for Ancient Canids*

![CanDate Logo](/dss/dsshome1/09/re98gan/ANALYSIS/CanDate-repo/assets/CanDate-logo.png)

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

Example for BAM input:

```csv
sample,bam
D_Germany_CTC_4721,/path/to/bam/D_Germany_CTC_4721.bam
D_Ireland_Newgrange_4767,/path/to/bam/D_Ireland_Newgrange_4767.bam
```

Example for FASTA input:

```csv
sample,fasta
D_Germany_CTC_4721,/path/to/bam/D_Germany_CTC_4721.fasta
D_Ireland_Newgrange_4767,/path/to/bam/D_Ireland_Newgrange_4767.fasta
```

Example for XML resume input:

```csv
sample,xml_file
D_Germany_CTC_4721,/path/to/bam/D_Germany_CTC_4721.bam
D_Ireland_Newgrange_4767,/path/to/bam/D_Ireland_Newgrange_4767_updated.xml
```

> ⚠️ Sample names **must match** between the CSV file and the FASTA headers.

You can generate the input CSV using:

```bash
bash prepare_input.csv path/to/your/samples
```

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

---

## 💻 Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/mahaut-goor/CanDate-repo.git
   ```

2. **Create the Conda environment**

   ```bash
   conda env create -f environment.yml
   conda activate candate
   ```

3. **Test your Nextflow setup**

   ```bash
   nextflow run ./CanDatePipeline
   ```

4. **OPTIONAL: If you are running this workflow on another server**

   ```
   Set up some custom config file in <./CanDatePipeline/conf>
   Ask us for more customisation.
   ```

---

## ⚙️ Pipeline Parameters

| Parameter          | Description                                |
| ------------------ | ------------------------------------------ |
| `--input`          | Input CSV file with sample paths           |
| `--outdir`         | Output directory                           |
| `--reference_xml`  | XML template for BEAST                     |
| `--existing_maln`  | Reference FASTA alignment                  |
| `--num_chain`      | Number of BEAST MCMC chains                |
| `--min_ess`        | Minimum effective sample size              |
| `--profile`        | Compute environment profile                |
| `--skip_consensus` | Skip consensus creation (start from FASTA) |
| `--skip_maln`      | Skip alignment step                        |
| `--skip_parse_xml` | Skip xml creation step                     |

---

## ▶️ Usage Example

```bash
nextflow run ./CanDatePipeline \
  --input BAM20samples.csv \
  --outdir ./output \
  --reference_xml ./data/181ancientModernNODLOOP_REFDUMMY_1M.xml \
  --existing_maln ./data/181ancientsModernNODLOOP.fasta \
  --num_chain 4 \
  --min_ess 100 \
  -profile lrz_cm4_custom \
  -qs 8
```

### Resuming from specific steps

* **Start from BAMs (default):**

  ```
  --skip_consensus false
  --skip_maln false
  ```
* **Start from FASTAs (skip consensus + alignment):**

  ```
  --skip_consensus true
  --skip_maln true
  ```
* **Resume MCMC step:**

The workflow automaticaly resumes the MC chains if the parameters from the combined.log have not all recahe ESS >200.
You can also choose to resume the BEAST step providing nextflow with the run updated xml.

   ```
  --skip_consensus true
  --skip_maln true
  --skip_parse_xml true
  ```


---

## 📤 Outputs

| Step | Output File                              | Description                         |
| ---- | ---------------------------------------- | ----------------------------------- |
| 1    | `*.fasta`                                | Sample mitochondrial sequences      |
| 2    | `aligned.fasta` / `alignedtrimmed.fasta` | MAFFT-aligned and trimmed sequences |
| 3    | `*.xml`                                  | BEAST XML input files               |
| 4    | `*.log`, `*.state`, `*.trees`            | Individual MCMC outputs             |
| 4    | `*_combined.log`, `*_resampled.trees`    | Combined and resampled outputs      |
| 5    | `tip_dates.tsv`                          | Extracted tip dates per sample      |
|      | `trace.txt`                              | Time profiling of each process      |

---

## 🧠 Notes

* Nextflow automatically creates trace files tracking process time.
* Always run from a dedicated working directory:

  ```bash
  cd /path/to/working_dir
  ```
* Do **not delete the `work/` directory** until the run is complete — it’s required for resuming.

> ⚠️ For low-coverage BAMs, inspect consensus quality. Adjust `--depth` and `--min_qual` to improve reliability.

---

## 🧩 Example SLURM Script

Example batch file:

```bash
sbatch ExempleRunCanDate-SBATCH.sh
```

Example script path:

```
/dss/dsshome1/09/re98gan/ANALYSIS/CanDate-repo/ExempleRunCanDate-SBATCH.sh
```

---

## 🚧 Upcoming Features

* Automatic filtering step after `samtools`:
  Warn if consensus contains too many Ns (gaps).

  > “Consensus has too many gaps — consider increasing minimum depth or quality thresholds.”

---

## 📚 References

* **Tip Dating & Leave-One-Out Method:** Loog *et al.*, 2020
* **BEAST:** Bouckaert *et al.*, 2014
* **nf-core Framework:** Ewels *et al.*, 2020
