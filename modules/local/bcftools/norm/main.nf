process BCFTOOLS_NORM {
    label 'C4'
    container 'pgc-images.sbgenomics.com/d3b-bixu/bcftools:1.20'
    // basic annotation functionality. See https://samtools.github.io/bcftools/howtos/annotate.html
    input:
    tuple path(vcf), path(vcf_index)
    path fasta

    output:
    tuple path("*vcf.gz"), path("*vcf.gz.tbi"), emit: normed_vcf

    script:
    def prefix = task.ext.prefix ?: "normalized"
    def args = task.ext.args ?: ''
    """
    bcftools norm \\
        --threads 4 \\
        --write-index=tbi \\
        --old-rec-tag OLD_RECORD \\
        -f $fasta \\
        -O z \\
        -o ${prefix}.vcf.gz \\
        $args \\
        ${vcf}
    """
}