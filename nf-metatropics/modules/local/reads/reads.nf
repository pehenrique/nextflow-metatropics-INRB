process ReadCount {
    publishDir "${params.outdir}", mode: 'copy', saveAs: { filename ->
        filename.endsWith('read_counts.csv') ? filename : null
    }

    label 'process_high'
    tag "ReadCount"

    container = 'rocker/tidyverse:latest'
    containerOptions = "-v /data:/data -u \$(id -u):\$(id -g)"

    input:
    val outdir
    path medaka_files

    output:
    path "read_count/*.fastq.gz", emit: read_count_fastq_root
    path "read_count/**/*.fastq.gz", emit: read_count_fastq_nested
    path "read_count/read_counts.csv", emit: read_counts_csv

    script:
    """
    mkdir -p read_count read_count/nohuman read_count/nohost

    # Check if directories exist
    for dir in fix fastp nohuman seqtk; do
        if [ ! -d "${outdir}/\$dir" ]; then
            echo "Directory ${outdir}/\$dir does not exist"
        fi
    done

    # Copy raw reads from 'fix' folder
    find ${outdir}/fix -name "*.fastq.gz" -type f -exec cp {} read_count/ \\; || echo "Copy from fix folder failed"

    # Copy trimmed reads from 'fastp' folder
    find ${outdir}/fastp -name "*.fastq.gz" -type f -exec cp {} read_count/ \\; || echo "Copy from fastp folder failed"

    # Copy human-depleted reads from 'nohuman' folder
    find ${outdir}/nohuman -name '*other.fastq.gz' -type f -exec cp {} read_count/nohuman/ \\; || echo "Copy from nohuman folder failed"

    # Copy host-depleted reads from 'nohost' folder if it exists
    if [ -d "${outdir}/nohost" ]; then
        find ${outdir}/nohost -name '*other.fastq.gz' -type f -exec cp {} read_count/nohost/ \\; || echo "Copy from nohost folder failed"
    else
        echo "nohost folder does not exist"
    fi

    # Process viral reads from 'seqtk' folder
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

    ReadCount.R ${params.outdir}/read_count/
    """
}


