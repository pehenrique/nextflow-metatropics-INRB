process CLEANUP {
    label 'process_single'

    input:
    path versions_file
    path final_report
    val docker_enabled
    path read_counts_csv

    script:
    """
    if [ "${docker_enabled}" = "true" ]; then
        docker ps -aq | xargs -r docker rm -f
        docker images -q | xargs -r docker rmi -f
    else
        echo "Docker cleanup skipped as it's not enabled"
    fi
    """
}
