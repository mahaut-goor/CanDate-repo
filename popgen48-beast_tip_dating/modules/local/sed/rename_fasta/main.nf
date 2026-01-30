process SED_RENAME_FASTA {
    tag "${meta.id}"
    label 'process_low'

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("${prefix}.fasta.gz"), emit: fasta

    script:
    // Strip "_mt" from the ID to create the prefix
    // Example: "Sample01_mt" becomes "Sample01"
    prefix = meta.id.replaceFirst(/_mt$/, "")

    """
    sed "s/^>.*/>${prefix}/" "${fasta}"|gzip -c > "${prefix}.fasta.gz"
    """
}
