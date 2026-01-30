process CAT_FASTA_FILES {
    tag "${prefix}"
    label 'process_low'

    input:
    path(fastas)

    output:
    path("${prefix}.fasta.gz"), emit: fasta

    script:

    prefix = task.ext.prefix?:'all_new_samples_mtdna'
    // Strip "_mt" from the end of the ID for the output filename
    
    """
    cat ${fastas} | gzip -c > ${prefix}.fasta.gz
    """
}
