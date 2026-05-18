process PYTHON_GENERATE_MCMC_RESUME_CSV {
    tag "Generating Resume CSV"
    label 'process_low' // Or whatever label fits your resource config

    input:
    val outdir // This takes the directory from your main script params

    output:
    path ("combined_resume.csv"), emit: mcmc


    script:
    """
    python ${baseDir}/bin/generate_mcmc_resume_csv.py ${outdir}
    """
}
