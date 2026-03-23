process PYTHON_PARSE_XML_TIP_DATES{
    tag "$meta.id"
    label 'process_low'

    // Using a standard biopython container
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython:1.81' :
        'biocontainers/biopython:1.81' }"

    input:
    tuple val(meta), path(fasta)
    path(reference_xaml)

    output:
    tuple val(meta), path("*.xml"), emit: xml
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // new_id and fasta_new_name are derived from the meta.id or the fasta filename
    def new_id = meta.id.replaceAll(/_mt$/, '')

    """
    python3 ${baseDir}/bin/parse_xml_tip_dates.py \\
        $reference_xaml \\
        $fasta \\
        ${prefix}_updated.xml \\
        ${new_id} \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //g')
        biopython: \$(python3 -c "import Bio; print(Bio.__version__)")
    END_VERSIONS
    """
}
