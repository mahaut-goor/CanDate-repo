process BEAST_MCMC_RESUME {
    tag "$meta.id - chain $chain_index"
    label 'process_high'


    input:
    tuple val(meta), path(xml), val(chain_index), val(run), path(state_file), path(log_file), path(trees)

    output:
    tuple val(meta), path("${prefix}*.log")  , emit: logs
    tuple val(meta), path("${prefix}*.trees"), emit: trees
    tuple val(meta), path("${prefix}*.state"), emit: state
    path "versions.yml"                      , emit: versions

    script:
    def args   = task.ext.args ?: ''
    sample = "${meta.id}"
    new_run = run.toInteger() + 1
    prefix     = "chain${chain_index}_run${new_run}_${sample}"
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
    
    LOWEST_ESS=\$(Rscript ${baseDir}/bin/check_ess.r ${log_file} ${remove_burnins} ${sample_interval} ${min_ess_nonbase} ${min_ess_base} ${prefix})

    cat ${state_file} > ${prefix}.state

    # Loop until the threshold is met
    while (( \$(echo "\$LOWEST_ESS == 0" | bc -l) )); do
        if [ \$RETRY_COUNT -ge \$MAX_RETRIES ]; then
            echo "Warning: Maximum retries (\$MAX_RETRIES) reached. ESS has still not crossed the required threshold. Proceeding anyway..."
            break 
        fi

        RETRY_COUNT=\$((RETRY_COUNT + 1))

        echo "ESS has not crossed the set threshold. Resuming BEAST for \${RETRY_COUNT} times..."
        beast -resume -threads ${task.cpus} -prefix ${prefix} -statefile ${prefix}.state -beagle ${args} $xml
        LOWEST_ESS=\$(Rscript ${baseDir}/bin/check_ess.r ${prefix}${xml.baseName}.log ${remove_burnins} ${sample_interval} ${min_ess_nonbase} ${min_ess_base} ${prefix})
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        beast: \$(beast -version 2>&1 | grep "version" | sed 's/.*version //')
    END_VERSIONS
    """
}
