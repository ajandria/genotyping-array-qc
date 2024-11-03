process QC_PROCESSES {
    label 'process_low'

    input:
    path vcf

    output:
    path "merged.vcf.gz", emit: merged_vcf

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    # Remove any _ from sample IDs
    bcftools query -l ${vcf} | awk '{ old=\$0; gsub("_", "", old); print \$0 "\t" old }' > sample_map.txt
    bcftools reheader -s sample_map.txt ${vcf} -o renamed_merged.vcf.gz

    # Index
    tabix -p vcf renamed_merged.vcf.gz
    plink --vcf renamed_merged.vcf.gz --make-bed --out 0_vcf_to_bed
    """
}