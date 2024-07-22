process RCOVERAGE {
    tag "rcoverage"
    label 'process_high' 

    conda "bioconda::metamaps=0.1.98102e9"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/metamaps:0.1.98102e9--h176a8bc_0':
        'rocker/tidyverse:latest' }"

    when:
    params.rcoverage_figure
    
    input:
    path coveragefiles

    output:
    path "coverage_distribution_group_*.pdf"

    script:
    """
    Coverage.R ${coveragefiles}
    """
}
