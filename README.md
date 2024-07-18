[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23metatropics-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/metatropics)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.nf/launch?pipeline=https://github.com/nf-core/metatropics)

# Nextflow-metatropics-INRB
The metatropics pipeline is a [Nextflow](https://www.nextflow.io/)-driven workflow designed for viral identification and the creation of consensus genomes from nanopore (metagenomic) sequencing data. It leverages container systems like [Docker](https://www.docker.com) and [Singularity](https://sylabs.io/docs/), utilizing one container per process to avoid software dependency conflicts and simplifies maintainenance. This container-based approach ensures that installation is straightforward and results are highly reproducible. 

### Pipeline summary on Linux

![Figure](./nf-metatropics//Metatropics.jpg)

For a more detailed description see [Metatropics description](https://github.com/DaanJansen94/nf-metatropics)

### 1. Download metatropics pipeline
```
git clone https://github.com/DaanJansen94/nextflow-metatropics-INRB.git
```

### 2. Install Nextflow (and Java)
Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.1`)
```
sudo apt-get update
sudo apt-get install curl
curl -s https://get.sdkman.io | bash

Open a new terminal

sdk install java 17.0.10-tem
java -version
curl -s https://get.nextflow.io | bash
chmod +x nextflow
sudo mv nextflow /usr/local/bin 
nextflow info
```

### 3. Install container system
Install any of the following container systems [`Docker`](https://docs.sevenbridges.com/docs/install-docker-on-linux), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility. 

Docker example:  
```
curl -fsSL https://get.docker.com/ | sh
sudo usermod -aG docker <your_username>
sudo chmod 666 /var/run/docker.sock
docker run hello-world
sudo service docker restart
```

### 4. Download Databases 
This includes: i) Viral Refseq, ii) Human genome and iii) Mosquito (host) genomes databases

```
cd nextflow-metatropics-INRB/Databases
wget https://zenodo.org/records/12657225/files/combined_databases.tar.gz
tar -xzvf combined_databases.tar.gz
rm combined_databases.tar.gz
```

### 5. Set PATHs

**Note:** Use params.yaml file for processing from raw reads (FASTQ format) and switch to the params2.yml file when dealing with squiggles (FAST5/POD5 format).

```
cd nextflow-metatropics-INRB
nano params.yml

input: change to input PATH
outdir: change to output PATH
fasta: change to human genome file PATH
dbmeta: change to ViralRefseq database PATH
```

### 6. Set Input

**Note:** The format of the `mpox.csv` [Input](https://github.com/DaanJansen94/nextflow-metatropics-INRB/tree/main/Input) file differs based on your starting data:
- For raw reads (FASTQ): (<u>use params.yml</u>)
```
The params.yaml file contains the most important paths
sample,single_end,barcode
sample_name01,True,/home/antonio/metatropics/nf-metatropics/fastq/barcode01.fastq
sample_name02,True,/home/antonio/metatropics/nf-metatropics/fastq/barcode02.fastq
```

- For squiggle data (FAST5/POD5): (<u>use params2.yml</u>)
```
sample,single_end,barcode
sample_name01,True,barcode01
sample_name02,True,barcode02
```

### 7. Runing pipeline

```
nextflow run nf-metatropics/ -profile docker -params-file params.yaml -resume
```

   ```
   nextflow run nf-metatropics/ --help

   Input/output options
    --input                       [string]  Path to comma-separated file containing information about the samples in the experiment.
    --input_dir                   [string]  Input directory with fast5 [default: None]
    --outdir                      [string]  The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure.
   Reference genome options
    --fasta                       [string]  Path to FASTA human genome file.
    --host_fasta                  [string]  Path to FASTA host genome file.
    --dbmeta                      [string]  Path for the MetaMaps database for read classification. [default: None]
   Generic options
    --basecall                    [boolean] In case fast5 is the input, that option shoud be true. Default is false.
    --model                       [string]  In case fast5 is the input, the guppy model for basecalling should be provide. [default:dna_r9.4.1_450bps_hac.cfg]
    --minLength                   [integer] Minimum length for a read to be analyzed. [default: 200]
    --minVirus                    [number]  Minimum virus data frequency in the raw data to be part of the output. [default: 0.001]
    --usegpu                      [boolean] In case fast5 is the input, the use of GPU Nvidia should be true.
    --pair                        [boolean] If barcodes were added at both sides of a read (true) or only at one side (false).
    --quality                     [integer] Minimum quality for a base to build the consensus [default: 7]
    --agreement                   [number]  Minimum base frequency to be called without ambiguity [default: 0.7]
    --depth                       [integer] Minimum depth of a position to build the consensus [default: 5]
    --front                       [integer] Number of bases to delete at 5 prime of the read [default: 0]
    --tail                        [integer] Number of bases to delete at 3 prime of the read [default: 0]
    --rcoverage                   [string]  Coverage figures [default: false]
   ```

### 8. Output
Below one can see the output directories and their description. `guppy` and `guppydemulti` will exist only in case the user has used FAST5 files as input.

1. [`guppy`] - fastq files after the basecalling without being demultiplexed
2. [`guppydemulti`] - directories and fastq files produced after the demultiplexing
3. [`fix`] - gziped fastq files for each sample of the run
3. [`fastp`] - results after trimming analysis performed by FASTP
4. [`nanoplot`] - quality results for the sequencing data just after demultiplexing
5. [`minimap2`] - BAM files about mapping against host genome
6. [`nohuman`] - gziped fastq files without reads mapping to human genome
7. [`nohost`] - gziped fastq files without reads mapping to host genome (-optional)
8. [`metamaps`] - results from both steps of Metamaps execution for read classification (mapDirectly and Classify)
9. [`r`] - intermediate table report and graphical PDF report for each sample
10. [`ref`] - header of the reads and fasta reference genomes for each virus found for each sample
11. [`krona`] - HTML files for each sample with interactive composition pie chart
12. [`reffix`] - fasta refence genomes with fixed header for each virus found during the run
13. [`seqtk`] - gziped fastq file for each set of read classified to a virus for each sample
14. [`medaka`] - BAM file for each virus with mapping results from the virus genome reference for each sample
15. [`samtools`] - mapping statistics calculated to BAM files present in the `medaka` directory
16. [`ivar`] - consensus sequences produced for each virus found in each sample
17. [`bam`] - detailed statistics for the BAM files from `medaka` directory for each position of virus refence genome
18. [`homopolish`] - consensus sequence for each virus in each sample polished for the indel variations
19. [`addingDepth`] - table report for each virus in each sample
23. [`final`] - final table report for all the run
24. [`pipeline_info`] - reports on the execution of the pipeline produced by NextFlow
25. [`rcoverage`] - PDF files including coverage figures of identified viruses  

**Note:** For the INRB mpox analysis, the most important files are the polished consensus sequences (18), the final report (23), and the coverage figures (25).
