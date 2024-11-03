process COMPRESS_INDEX {
    label 'process_low'

    input:
    path(vcf)

    output:
    path("*"), emit: gz_tbi

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    bgzip -c ${vcf} > ${vcf.baseName}.vcf.gz
    tabix -p vcf ${vcf.baseName}.vcf.gz
    """
}