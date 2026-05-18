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
    export HOME="\$PWD"
    export MPLCONFIGDIR="\$PWD/.matplotlib"
    export XDG_CACHE_HOME="\$PWD/.cache"
    export FONTCONFIG_CACHE="\$PWD/.fontconfig"
    export NUMBA_CACHE_DIR="\$PWD/.numba"

    mkdir -p "\$MPLCONFIGDIR" "\$XDG_CACHE_HOME" "\$FONTCONFIG_CACHE" "\$NUMBA_CACHE_DIR"

    python ${baseDir}/bin/extract_tip_date.py ${log_file} ${log_file.baseName}_stats.csv
    """
}
