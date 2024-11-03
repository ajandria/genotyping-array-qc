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
    sex_file = file("${params.sex_file}")
    ancestry_file = file("${params.ancestry_file}")
    pheno_file = file("${params.pheno_file}")
    """
    # Remove any _ from sample IDs
    bcftools query -l ${vcf} | awk '{ old=\$0; gsub("_", "", old); print \$0 "\t" old }' > sample_map.txt
    bcftools reheader -s sample_map.txt ${vcf} -o renamed_merged.vcf.gz

    # Index
    tabix -p vcf renamed_merged.vcf.gz
    plink \
        --vcf renamed_merged.vcf.gz \
        --make-bed \
        --out 0_vcf_to_bed \
        --chr 1-22,X,Y,MT \
        --split-x b38 \
        --update-sex ${sex_file}

    # Paths and parameters
    plink2="plink"  # Path to your plink2 executable
    header="0_vcf_to_bed"  # Input PLINK files without extensions
    directory="./"  # Working directory
    ancestry_file_path="${ancestry_file}"  # Ancestry file path
    ancestry_matrix=( "EU:W" "HIS:H" "AFR:B" "AS:A" "Other:O" )  # Ancestry mapping

    # Step 1: Perform missingness check
    \$plink2 --bfile \$header --missing --out \$header

    # Step 2: Hardy-Weinberg Equilibrium test (HWE)
    \$plink2 --bfile \$header --hardy --out \$header

    # Step 3: Frequency check (MAF)
    \$plink2 --bfile \$header --freq --out \$header

    # Step 4: Sex check
    \$plink2 --bfile \$header --check-sex --out \$header

    # Step 5: Remove SNPs with high missingness
    awk '\$5 > 0.05 {print \$2}' \${header}.lmiss > \${header}_high_missing_snps.txt
    \$plink2 --bfile \$header --exclude \${header}_high_missing_snps.txt --make-bed --out \${header}_clean

    # Step 6: HWE filtering (for controls, P-value < 1e-10)
    awk '\$9 < 1e-10 {print \$2}' \${header}.hwe > \${header}_hwe_fail_snps.txt
    \$plink2 --bfile \${header}_clean --exclude \${header}_hwe_fail_snps.txt --make-bed --out \${header}_hwe_clean

    # Step 7: MAF filtering (MAF < 0.01)
    \$plink2 --bfile \${header}_hwe_clean --maf 0.01 --make-bed --out \${header}_maf_clean

    # Step 8: Check relatedness and filter related samples
    \$plink2 --bfile \${header}_maf_clean --genome --out \${header}
    awk '\$10 > 0.185 {print \$1, \$2}' \${header}.genome > \${header}_related_samples.txt
    \$plink2 --bfile \${header}_maf_clean --remove \${header}_related_samples.txt --make-bed --out \${header}_unrelated

    # Step 9: Perform ancestry-based filtering (custom function based on ancestry.csv)
    # This part should be tailored based on your ancestry data and requirements

    # Step 10: Generate PCA
    \$plink2 --bfile \${header}_unrelated --pca --out \${header}_pca

    # Additional Steps: Perform phenotype-specific filtering if needed
    \$plink2 --bfile \${header}_unrelated --pheno ${pheno_file} --test-missing

    echo "QC pipeline completed!"
    """
}