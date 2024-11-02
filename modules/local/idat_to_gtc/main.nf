process IDAT_TO_GTC {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), val(idat_dir)

    output:
    tuple val(meta), path("."), emit: gtc

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    bpm_manifest = file("${params.bpm_manifest}")
    cluster_file = file("${params.cluster_file}")
    """
    ${params.array_analysis_cli}/array-analysis-cli genotype call \
        --bpm-manifest ${bpm_manifest} \
        --cluster-file ${cluster_file} \
        --output-folder . \
        --idat-folder ${idat_dir} \
        --num-threads $task.cpus \
        $args
    """
}