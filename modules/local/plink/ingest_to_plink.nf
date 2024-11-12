process INGEST_TO_PLINK {
    label 'process_low'

    input:
    path vcf

    output:
    path "plink_renamed_merged*", emit: ingested_with_plink

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    sex_file = file("${params.sex_file}")
    ancestry_file = file("${params.ancestry_file}")
    pheno_file = file("${params.pheno_file}")
    """
    # Remove any _ from sample IDs
    bcftools query -l ${vcf} | awk '{ old=\$0; gsub("_", "", old); print \$0 "\t" old }' > sample_map.txt
    bcftools reheader -s sample_map.txt ${vcf} -o renamed_merged.vcf.gz

    # Index
    tabix -p vcf renamed_merged.vcf.gz

    # Convert to plink format
    plink \
        --chr 1-22,X,Y,MT \
        --make-bed \
        --out plink_renamed_merged \
        --split-x b38 \
        --update-sex ${sex_file} \
        --vcf renamed_merged.vcf.gz
    """
}