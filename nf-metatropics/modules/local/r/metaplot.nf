process R_METAPLOT {
    tag "$meta.id"
    label 'process_high'

    container "$projectDir/images/R_plot.sif"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'daanjansen94/nf_r_plots:v4.2.2' }"

    input:
    tuple val(meta), path(classification), path(classlengh), path(classcov), path(classtotal)
    //tuple val(meta), path(classlengh)
    //tuple val(meta), path(classcov)
    //tuple val(meta), path(classtotal)


    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf
    // TODO nf-core: Where applicable please provide/convert compressed files as input/output
    //               e.g. "*.fastq.gz" and NOT "*.fastq", "*.bam" and NOT "*.sam" etc.
    //tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.pdf"), emit: plotpdf
    tuple val(meta), path("*.tsv"), emit: reporttsv
    tuple val(meta), path("*.txt"), emit: denovo
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    //tuple val(meta), path("*.bam"), emit: bam
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    //samtools \\
    //    sort \\
    //    $args \\
    //    -@ $task.cpus \\
    //    -o ${prefix}.bam \\
    //    -T $prefix \\
    //    $bam
    //cat <<-END_VERSIONS > versions.yml
    //"${task.process}":
    //    r: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    //END_VERSIONS
    """
    plotMappingSummary.R ${prefix}_classification_results $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R used to plots: \$(echo \$(R --version) | perl -p -e 's/R version //g' | perl -p -e 's/ .+//g' )
    END_VERSIONS
    """
}
