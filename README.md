# nextflow-metatropics-INRB

# Downloads pipelines
git clone https://github.com/DaanJansen94/nextflow-metatropics-INRB.git 

# Download git-lfs
sudo apt-get install git-lfs 
OR
pip install git-lfs

# Download complete Databases
git lfs pull --include "Databases/Human.zip" 
unzip Databases/Human.zip
unzip Databases/ViralRefseq.zip

# Alternatively you can download both Human and ViralRefSeq database from
# 1) Download Human Database
wget https://zenodo.org/records/12518358/files/ViralRefseq.zip
wget https://zenodo.org/records/12518452/files/Human.zip
Unzip both

# 2) Downlaod Viral Refseq Datase for Metamaps
https://zenodo.org/records/12518358

# Run pipeline
nextflow run nf-metatropics/ -profile docker -params-file params.yaml -resume
