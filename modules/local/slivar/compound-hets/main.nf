process SLIVAR_COMPOUND_HETS {
    tag "${meta.id}"
    label 'process_low'

    container "brentp/slivar:v0.3.1"

    input:
    tuple val(meta), path(vcf), path(vcf_index)
    path(ped)

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.tbi") emit: compound_hets

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def zips_arg = echtvar_zips.collect{ zip -> "-e ${zip}" }.join(" ")  
    """
    slivar compound-hets \\
        --vcf $vcf \\
        --ped $ped \\
        --out-vcf ${prefix}.vcf.gz \\
        $args
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf.gz
    """
}
