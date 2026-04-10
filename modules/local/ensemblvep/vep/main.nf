process ENSEMBLVEP_VEP {
    label 'VEP'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ensembl-vep:105.0--pl5262h4a94de4_0' :
        'biocontainers/ensembl-vep:105.0--pl5262h4a94de4_0' }"

    input:
    tuple path(vcf), path(vcf_index)
    val   genome
    val   species
    val   cache_version
    path  cache
    path  fasta
    path  extra_files

    output:
    path("*.vcf.gz"), emit: vcf
    path("*.vcf.gz.tbi"), emit: tbi
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def file_extension = args.contains("--vcf") ? 'vcf' : args.contains("--json")? 'json' : args.contains("--tab")? 'tab' : 'vcf'
    def compress_cmd = args.contains("--compress_output") ? '' : '--compress_output bgzip'
    def prefix = task.ext.prefix ?: "vep_annotated"
    def dir_cache = cache ? "./" : "/.vep"
    def reference = fasta ? "--fasta $fasta" : ""
    """
    tar xzf $cache && \\
    vep \\
        -i $vcf \\
        -o ${prefix}.${file_extension}.gz \\
        $args \\
        $compress_cmd \\
        $reference \\
        --assembly $genome \\
        --species $species \\
        --cache \\
        --merged \\
        --cache_version $cache_version \\
        --dir_cache $dir_cache \\
        --fork $task.cpus && \\
        tabix ${prefix}.${file_extension}.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ensemblvep: \$( echo \$(vep --help 2>&1) | sed 's/^.*Versions:.*ensembl-vep : //;s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "vep_annotated"
    """
    echo "" | gzip > ${prefix}.vcf.gz
    echo "" | gzip > ${prefix}.tab.gz
    echo "" | gzip > ${prefix}.json.gz
    touch ${prefix}_summary.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ensemblvep: \$( echo \$(vep --help 2>&1) | sed 's/^.*Versions:.*ensembl-vep : //;s/ .*\$//')
    END_VERSIONS
    """
}