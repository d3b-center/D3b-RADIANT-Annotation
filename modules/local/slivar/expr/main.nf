process SLIVAR_EXPR {
    tag "${meta.id}"
    label 'process_low'

    container "pgc-images.sbgenomics.com/d3b-bixu/slivar:0.3.4"

    input:
    tuple val(meta), path(vcf), path(vcf_index)
    path(ped)
    path(gnotate_zips)

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.tbi"), emit: filtered_vcf

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def ped_arg = ped ? "--ped ${ped}" : ''
    def zips_arg = gnotate_zips ? gnotate_zips.collect{ zip -> "-g ${zip}" }.join(" ") : ''
    """
    slivar expr \\
        --vcf $vcf \\
        --out-vcf ${prefix}.vcf.gz \\
	--js /opt/slivar/slivar-functions.js \\
        $ped_arg \\
        $zips_arg \\
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
