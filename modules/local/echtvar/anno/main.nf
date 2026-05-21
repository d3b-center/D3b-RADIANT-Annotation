process ECHTVAR_ANNO {
    tag "${meta.id}"
    label 'process_low'

    container "pgc-images.sbgenomics.com/d3b-bixu/echtvar:0.2.0"

    input:
    tuple val(meta), path(vcf), path(vcf_index)
    path(echtvar_zips)

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.tbi"), emit: annotated_vcf

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def zips_arg = echtvar_zips.collect{ zip -> "-e ${zip}" }.join(" ")  
    """
    echtvar anno \\
        $echtvar_zips \\
        $args \\
        $vcf \\
        ${prefix}.vcf.gz \\
    && bcftools index \\
        --threads $task.cpus \\
        --tbi \\
        --force \\
        ${prefix}.vcf.gz
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf.gz
    touch ${prefix}.vcf.gz.tbi
    """
}
