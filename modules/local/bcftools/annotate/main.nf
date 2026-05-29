process BCFTOOLS_ANNOTATE {
    tag "${meta.id}"
    label 'C4'
    container 'pgc-images.sbgenomics.com/d3b-bixu/bcftools:1.20'
    // basic annotation functionality. See https://samtools.github.io/bcftools/howtos/annotate.html
    input:
    tuple val(meta), path(vcf), path(vcf_index)
    tuple path(annotate_vcf), path(annotate_vcf_index)

    output:
    tuple val(meta), path("*vcf.gz"), path("*vcf.gz.tbi"), emit: annotated_vcf

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    def annot_vcf_input = annotate_vcf ? "-a ${annotate_vcf}" : ''
    """
    bcftools annotate \\
        --threads 4 \\
        --write-index=tbi \\
        -O z \\
        -o ${prefix}.vcf.gz \\
        ${annot_vcf_input} \\
        $args \\
        $vcf
    """
}
