process IDAT_TO_GTC {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.gtc"), emit: gtc

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    ${params.array_analysis_cli}/array-analysis-cli genotype call \
        --bpm-manifest ${params.bpm_manifest} \
        --cluster-file ${params.cluster_file} \
        --output-folder . \
        --idat-folder batchX/raw \
        --num-threads $task.cpus \
        $args
    """
}