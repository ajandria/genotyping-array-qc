process SPLIT_BY_ANCESTRY {
    label 'process_low'

    input:
    path bed

    output:
    path "plink_renamed_merged*", emit: ingested_with_plink

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    ancestry_file = file("${params.ancestry_file}")
    """
    for RACE_CAT in \$(awk 'NR > 1 {print \$2}' "$ancestry_file" | sort | uniq); do

        KEEP_FILE="\${RACE_CAT}_to_include.txt"
        awk -v race="\$RACE_CAT" 'NR > 1 && \$2 == race {print \$1, \$1}' "${ancestry_file}" > "\$KEEP_FILE"
        
        plink \
            --bfile plink_renamed_merged \
            --keep "\$KEEP_FILE" \
            --make-bed \
            --out "plink_renamed_merged.\${RACE_CAT}"
    done

    echo "All ancestry groups processed."
    """
}