process SLIVAR_COMPOUND_HETS {
    tag "${meta.id}"
    label 'process_low'

    container "pgc-images.sbgenomics.com/danmiller/slivar:0.3.4"

    input:
    tuple val(meta), path(vcf), path(vcf_index)
    path(ped)

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.tbi"), emit: compound_hets

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    slivar compound-hets \\
        --vcf $vcf \\
        --ped $ped \\
        --out-vcf ${prefix}.vcf.gz \\
        $args \\
    && bcftools index --tbi ${prefix}.vcf.gz
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf.gz
    touch ${prefix}.vcf.gz.tbi
    """
}
