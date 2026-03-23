CanDatePipeline – Help
Usage:
nextflow run candate_nf [options]

Input options
-------------

--input
    CSV file containing samples and BAM files.

    Format:
    sample,bam,idx
    sample1,/path/sample1.bam,/path/sample1.bam.bai
    sample2,/path/sample2.bam,/path/sample2.bam.bai

    Script to generate:
    bash prepare_input.sh path/to/directorywithsamples

--mt_seq_name (default: MT)
    Chromosome name used in BAM files for mitochondrial read extraction.
    Example: chrMT

--out_prefix (default: combined_unaligned)
    Prefix for output files.

--mtdna_map_file
    CSV file specifying mitochondrial chromosome name per sample
    (if different across BAM files).

    Format:
    sample,mt_header
    sample1,chrM
    sample2,chrMT
    sample3,chrMT

    Script to generate:
    bash extractMTChr.sh path/to/samples


Consensus generation (bam2consensus)
------------------------------------

--depth (default: 5)
    Minimum coverage depth required to call a consensus base.

--consensus (default: 0.75)
    Minimum allele frequency required to call the consensus base.

--mapping_qual (default: 30)
    Minimum mapping quality for reads used in consensus generation.


Alignment (MAFFT)
-----------------

--existing_maln
    Path to an existing reference FASTA alignment.

--reference_xml
    Path to the BEAST XML template.


Workflow control
----------------

--skip_consensus (default: false)
    Skip BAM → FASTA consensus generation.

--skip_maln (default: false)
    Skip sequence alignment.

--skip_parse_xml (default: false)
    Skip XML generation.

--beast_resume (default: false)
    Resume an existing BEAST run.


BEAST parameters
----------------

--num_chain (default: 8)
    Number of BEAST MCMC chains.

--min_ess_nonbasefreq (default: 50)
    Minimum ESS required for non–base frequency parameters.

--min_ess_basefreq (default: 25)
    Minimum ESS required for base frequency parameters.

--remove_burnins (default: 0.1)
    Fraction of burn-in removed from combined logs.

--sample_interval (default: 1000)
    Sampling interval when resampling trees.

--max_resume (default: 50)
    Maximum number of BEAST resume attempts.


Examples
--------

Run full pipeline from BAM files:

nextflow run CanDatePipeline \
    --input samples.csv \
    --reference_xml template.xml \
    --existing_maln ref_alignment.fasta \
    --outdir output


Start from FASTA sequences:

--skip_consensus true
--skip_maln true


Start from existing BEAST XML files:

--skip_consensus true
--skip_maln true
--skip_parse_xml true
