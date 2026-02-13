process PYTHON_EXTRACT_TIP_DATE {
    tag "${log_file.baseName}"
    label 'process_low'
    
    // Path to your yaml file relative to the project root
    conda "${projectDir}/environment.yml"

    input:
    tuple val(meta), path(log_file)

    output:
    tuple val(meta), path ("${log_file.baseName}_stats.csv"), emit: csv

    script:
    """
    python ${baseDir}/bin/extract_tip_date.py ${log_file} ${log_file.baseName}_stats.csv
    """
}
