process MERGE_VCFS {
    label 'process_low'

    input:
    path ch_vcf_files

    output:
    path "merged.vcf.gz", emit: merged_vcf

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    ls *.vcf.gz > vcf_files_list.txt
    bcftools merge \
        -O z \
        -o merged.vcf.gz \
        --file-list vcf_files_list.txt \
        --threads $task.cpus
    """
}