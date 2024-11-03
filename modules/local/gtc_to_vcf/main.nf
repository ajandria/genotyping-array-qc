process GTC_TO_VCF {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), val(gtc_dir)

    output:
    path("*vcf"), emit: vcf

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    bpm_manifest = file("${params.bpm_manifest}")
    csv_manifest = file("${params.csv_manifest}")
    genome_fasta_file = file("${params.genome_fasta_file}")
    """
    ${params.array_analysis_cli}/array-analysis-cli genotype gtc-to-vcf \
        --bpm-manifest ${bpm_manifest} \
        --csv-manifest ${csv_manifest} \
        --genome-fasta-file ${genome_fasta_file} \
        --gtc-folder ${gtc_dir} \
        --output-folder . \
        $args
    """
}