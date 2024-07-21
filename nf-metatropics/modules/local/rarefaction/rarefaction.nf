process RAREFACTION {
    tag "$meta.id"
    label 'process_low'
    container "nanozoo/bbmap:38.86--9ebcbfa"

    input:
    tuple val(meta), path(reads)
    val(perform_rarefaction)
    val(target_bases)

    output:
    tuple val(meta), path("*_rarefied.fastq.gz"), emit: rarefied_reads
    path "versions.yml", emit: versions

    when:
    perform_rarefaction

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    reformat.sh in=${reads} out=${prefix}_rarefied.fastq.gz samplebasestarget=$target_bases

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bbmap: \$(bbmap.sh --version 2>&1 | grep -o 'BBMap version [0-9.]*' | sed 's/BBMap version //')
    END_VERSIONS
    """
}
