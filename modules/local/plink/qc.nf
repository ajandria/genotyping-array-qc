process QC {
    label 'process_low'

    input:
    path bed

    output:
    path "*", emit: ingested_with_plink

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    ancestry_file = file("${params.ancestry_file}")
    pheno_file = file("${params.pheno_file}")
    """
    # Replace family IDs with 0
    awk '{\$1 = 0; print}' plink_renamed_merged.fam > plink_renamed_merged_new.fam
    mv plink_renamed_merged_new.fam plink_renamed_merged.fam

    qc.py \\
        --header plink_renamed_merged \\
        --ancestry_file_path ${ancestry_file} \\
        --pheno_files ${pheno_file} > cmd.log 2>&1
    """
}