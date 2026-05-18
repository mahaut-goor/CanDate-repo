# 🐺 **CanDate**

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

CanDate is implemented in the **Nextflow framework** and supports **modular resumption** — meaning you can restart the pipeline from any step. We have included all the necessary tools inside a singularity container. In order to run the pipeline, you need to have nextflow installed as well as singularity.

| Tool              | Version   | Notes                                                                                  |
| ----------------- | --------- | ---------------------------------------------------------------------------------------|
| **Nextflow**      | ≥ 25.10.2 | [Install Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)                |
| **singularity**   | Latest    | [Install Singularity](https://docs.sylabs.io/guides/3.0/user-guide/installation.html)  |

---

## 💻 Installation



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

## Runing for Canids

## Running for new species


## 🧠 Notes

* Nextflow automatically creates trace files tracking process time.
* Always run from a dedicated working directory:

  ```bash
  cd /path/to/working_dir
  ```
* Do **not delete the `work/` directory** until the run is complete — it’s required for resuming.

> ⚠️ For low-coverage BAMs, inspect consensus quality. Adjust `--depth` and `--min_qual` to improve reliability.

---

## 📚 References

* **Tip Dating & Leave-One-Out Method:** Loog *et al.*, 2020
* **BEAST:** Bouckaert *et al.*, 2014
* **nf-core Framework:** Ewels *et al.*, 2020
* **mafft** Katoh *et al.* ,2013 Jan (10.1093/molbev/mst010)
* **trimal** Capella-Gutiérrez *et al.*, 2009 (10.1093/bioinformatics/btp348)
* **samtools** Danecek *et al.*, 2021 (https://doi.org/10.1093/gigascience/giab008)
* **singularity** Kurtzer *et al*, (2017) (https://doi.org/10.1371/journal.pone.0177459)
