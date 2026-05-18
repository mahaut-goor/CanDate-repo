process BEAST_MCMC_RESUME {
    tag "$meta.id - chain $chain_index"
    label 'process_high'
    publishDir "${params.outdir}/beast_resume/", mode: 'copy', saveAs: { filename -> "results_files/$filename" }
    stageInMode 'copy'


    input:
    tuple val(meta), path(xml), val(chain_index), val(run), path(state_file), path(log_file), path(trees)

    output:
    // Prepend the directory name to the glob pattern
    tuple val(meta), path("results_files/${prefix}*.log")  , emit: logs
    tuple val(meta), path("results_files/${prefix}*.trees"), emit: trees
    tuple val(meta), path("results_files/${prefix}*.state"), emit: state
    path "versions.yml"                                   , emit: versions

    script:
    def args   = task.ext.args ?: ''
    sample = "${meta.id}"
    new_run = run.toInteger()
    prefix     = "chain${chain_index}_run1_"
    min_ess_nonbase    = params.min_ess_nonbasefreq
    min_ess_base    = params.min_ess_basefreq
    remove_burnins = params.remove_burnins
    sample_interval = params.sample_interval
    max_resume = params.max_resume
    //def resume = run_type == "resume" ? "-resume" : ""
    
    """
    # Check ESS using loganalyser

    RETRY_COUNT=0
    MAX_RETRIES=${max_resume}
    

    #cat ${state_file} > ${prefix}.xml.state
    #cat ${log_file} > ${prefix}.log
    #cat ${xml} > ${prefix}.xml


    while [ "\$RETRY_COUNT" -lt "\$MAX_RETRIES" ]; do

        beast ${args} -resume -prefix "${prefix}" -threads ${task.cpus} \
            -statefile ${state_file} \
            -beagle ${xml}

        RETRY_COUNT=\$((RETRY_COUNT + 1))

        echo "Completed attempt \${RETRY_COUNT}/\${MAX_RETRIES}"

    done

    mkdir results_files

    cp ${prefix}*.log ./results_files/
    cp ${prefix}*.trees ./results_files/
    cp ${prefix}*.state ./results_files/


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        beast: \$(beast -version 2>&1 | grep "version" | sed 's/.*version //')
    END_VERSIONS
    """
}
