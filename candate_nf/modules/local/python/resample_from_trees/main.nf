process PYTHON_RESAMPLE_FROM_TREES{
    tag "$meta.id"
    label 'process_low'

    // Using a standard biopython container
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.81' :
        'biocontainers/biopython:1.81' }"

    input:
    tuple val(meta), path(trees)

    output:
    tuple val(meta), path("${prefix}_resampled.tree"), emit: tree
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    // new_id and fasta_new_name are derived from the meta.id or the fasta filename

    """
    python3 ${baseDir}/bin/resample_from_trees.py \\
        $trees \\
        ${prefix}_resampled.tree \\
        ${args} \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //g')
    END_VERSIONS
    """
}
