process ReadCount {
    publishDir "${params.outdir}", mode: 'copy'
    label 'process_high'
    tag "ReadCount"

    container = 'rocker/tidyverse:latest' // This container includes R and many common libraries
    containerOptions = "-v /data:/data -u \$(id -u):\$(id -g)" // without the option the command before the Rscript will not work!

    input:
    val outdir
    path medaka_files

    output:
    path "read_count/*.fastq.gz", emit: read_count_fastq_root
    path "read_count/**/*.fastq.gz", emit: read_count_fastq_nested
    //path "read_counts.xlsx", emit: read_counts_excel

    script:
    """
    set -e  # Exit immediately if a command exits with a non-zero status
    set -x  # Print commands and their arguments as they are executed

    mkdir -p read_count
    mkdir -p read_count/nohuman
    mkdir -p read_count/nohost

    echo "Current working directory: \$(pwd)"
    echo "Contents of outdir: \$(ls -l ${outdir})"

    ##Copy raw reads from 'fix' folder
    find ${outdir}/fix -name "*.fastq.gz" -type f -exec cp {} read_count/ \\; || echo "Copy from fix folder failed"

    ##Copy trimmed reads from 'fastp' folder
    find ${outdir}/fastp -name "*.fastq.gz" -type f -exec cp {} read_count/ \\; || echo "Copy from fastp folder failed"

    ##Copy human-depleted reads from 'nohuman' folder
    find ${outdir}/nohuman -name '*other.fastq.gz' -type f -exec cp {} read_count/nohuman/ \\; || echo "Copy from nohuman folder failed"

    ##Copy host-depleted reads from 'nohost' folder if it exists
    if [ -d "${outdir}/nohost" ]; then
        find ${outdir}/nohost -name '*other.fastq.gz' -type f -exec cp {} read_count/nohost/ \\; || echo "Copy from nohost folder failed"
    else
        echo "nohost folder does not exist"
    fi

    ##Process viral reads from 'seqtk' folder
    for file in ${outdir}/seqtk/*T1*classification_results.*.fastq.fq.gz; do
        if [ -f "\$file" ]; then
            base_name=\$(basename "\$file")
            sample_name=\${base_name%%_T1*}
            cat ${outdir}/seqtk/\${sample_name}_T1*classification_results.*.fastq.fq.gz > read_count/\${sample_name}_viral_reads.fastq.gz || echo "Processing \$file failed"
        else
            echo "No matching files found in seqtk folder"
            break
        fi
    done

    echo "Contents of read_count directory:"
    ls -lR read_count/

    set +x  # Disable debugging

    ##ReadCount.R
    """
}
