process RSCRIPT_TRACERER{
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(meta), path(logfile)

    output:
    tuple val(meta), path("*_ess_report.csv"), emit: csv

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"

    """
       Rscript ${baseDir}/bin/check_ess.r ${logfile} ${args} ${prefix}

    """

}
