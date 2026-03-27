process BEAST_LOGCOMBINER{
    tag "$meta.id"
    label 'process_low'


    input:
    tuple val(meta), path(log_files)
    val(type_files)

    output:
    tuple val(meta), path("${output_file}")  , emit: logs
    path "versions.yml"                      , emit: versions

    script:
    def args   = task.ext.args ?: ''
    output_file = type_files == "log"?"${meta.id}_combined.log" : "${meta.id}_combined.trees"
    def logs = log_files.collect { "-log $it" }.join(' ')
    
    """
    logcombiner ${args} ${logs} -o ${output_file}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        logcombiner: \$(logcombiner -h 2>&1|grep -oP 'v\\K[0-9.]+')
    END_VERSIONS
    """
}
