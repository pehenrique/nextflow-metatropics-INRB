# nextflow-metatropics-INRB

git clone https://github.com/DaanJansen94/nextflow-metatropics-INRB.git # downloads pipelines
sudo apt-get install git-lfs # download git-lfs (if not present on your environment)
git lfs pull --include "Databases/Human.zip" 
unzip Databases/Human.zip
unzip Databases/ViralRefseq.zip

# Alternatively you can download both Human and ViralRefSeq database from
# 1) Download Human Database
https://zenodo.org/uploads/12518452
# Unzip and place in

# 2) Downlaod Viral Refseq Datase for Metamaps
https://zenodo.org/records/12518358

# Run pipeline
nextflow run nf-metatropics/ -profile docker -params-file params.yaml -resume
