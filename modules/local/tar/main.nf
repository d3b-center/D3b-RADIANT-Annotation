process UNTAR{ 
    label 'C4'
    container "pgc-images.sbgenomics.com/d3b-bixu/cutadapt:3.4"
    input:
    path tarFile
    val decompress_flag

    output:
    path "*", emit: untarred

    when:
    task.ext.when == null || task.ext.when

    script:
    def decompress_cmd = decompress_flag ? '-I pigz': ""
    """
    tar $decompress_cmd  -xf $tarFile
    """
 }
