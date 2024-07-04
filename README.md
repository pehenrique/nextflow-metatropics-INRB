[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23metatropics-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/metatropics)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.nf/launch?pipeline=https://github.com/nf-core/metatropics)

# Nextflow-metatropics-INRB
The metatropics pipeline is a [Nextflow](https://www.nextflow.io/)-driven workflow designed for viral identification and the creation of consensus genomes from nanopore (metagenomic) sequencing data. It leverages container systems like [Docker](https://www.docker.com) and [Singularity](https://sylabs.io/docs/), utilizing one container per process to avoid software dependency conflicts and simplifies maintainenance. This container-based approach ensures that installation is straightforward and results are highly reproducible. 

### Pipeline summary

![Figure](./nf-metatropics//Metatropics.jpg)

For a more detailed description see [Metatropics description](https://github.com/DaanJansen94/nf-metatropics)

### 1. Open metatropics pipeline
```
git clone https://github.com/DaanJansen94/nextflow-metatropics-INRB.git
```

### 2. Install Nextflow and Container systems
Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.1`)

Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility. Additionally, you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. 

In case of using singularity, some containers need to be build:

```
cd nf-metatropics/images
sudo singularity build R_plot.sif R_plot.txt
sudo singularity build guppy.sif guppy.txt
sudo singularity build homopolish.sif homopolish.txt
sudo singularity build metamaps.sif metamaps.txt
sudo singularity build samtools_minimap2.sif samtools_minimap2.txt
```

### 3. Download Databases

**Viral Refseq database**
```
cd Databases
wget https://zenodo.org/records/12518358/files/ViralRefseq.zip
unzip ViralRefseq.zip 
```

**Human genome database**
```
wget https://zenodo.org/records/12518452/files/Human.zip
unzip Human.zip
```

**Mosquito (or other) hosts (optional) database**
```
wget https://zenodo.org/records/12611397/files/Aedes.zip
unzip Aedes.zip
```

### 4. Run pipeline

```
nextflow run nf-metatropics/ -profile docker -params-file params.yaml -resume
```

<u>The params.yaml file contains the most important paths:</u>
- input: /data/Daan/Projects/INRB/Input/mpox.csv # csv files is different for fast5 and fastq files
- #input_dir: /data/Daan/Projects/INRB_r/Input/pod5
- outdir: /data/Daan/Projects/INRB/Output
- fasta: /data/Daan/Projects/nextflow-metatropics-INRB/Databases/Human/chm13v2.0.fa
- host_fasta: /data/Daan/Projects/nextflow-metatropics-INRB/Databases/Aedes/Aedes_aegypti.fasta
- dbmeta: /data/Daan/Projects/nextflow-metatropics-INRB/Databases/ViralRefseq
- #basecall: true 
- #usegpu: true 
- #model: dna_r10.4.1_e8.2_400bps_hac.cfg # model depends on your flowcel and kit used
- minLength: 200
- pair: true
- front: 18
- tail: 18
- minVirus: 0.01
- quality: 20
- depth: 5
- agreement: 0.7
- rcoverage_figure: true

**Note:** The format of the `mpox.csv` [Input](https://github.com/DaanJansen94/nextflow-metatropics-INRB/tree/main/Input) file differs based on your starting data:
- For raw reads (fastq files): 
```
sample,single_end,barcode
sample_name01,True,/home/antonio/metatropics/nf-metatropics/fastq/barcode01.fastq
sample_name02,True,/home/antonio/metatropics/nf-metatropics/fastq/barcode02.fastq
```
- For squiggle data (fast5/pod5 files):
```
sample,single_end,barcode
sample_name01,True,barcode01
sample_name02,True,barcode02
```





### 2. Summary of the metatropics pipeline



### 1 RUN
### 2 OUTPUT



5. Start running your own analysis!

   <!-- TODO nf-core: Update the example "typical command" below used to run the pipeline -->

   ```bash
   nextflow run nf-metatropics/ --help
   Input/output options
    --input                       [string]  Path to comma-separated file containing information about the samples in the experiment.
    --input_dir                   [string]  Input directory with fast5 [default: None]
    --outdir                      [string]  The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure.
    --multiqc_title               [string]  MultiQC report title. Printed as page header, used for filename if not otherwise specified.
   Reference genome options
    --fasta                       [string]  Path to FASTA genome file.
   Generic options
    --basecall                    [boolean] In case fast5 is the input, that option shoud be true. Default is false.
    --model                       [string]  In case fast5 is the input, the guppy model for basecalling should be provide. [default:dna_r9.4.1_450bps_hac.cfg]
    --minLength                   [integer] Minimum length for a read to be analyzed. [default: 200]
    --minVirus                    [number]  Minimum virus data frequency in the raw data to be part of the output. [default: 0.001]
    --usegpu                      [boolean] In case fast5 is the input, the use of GPU Nvidia should be true.
    --dbmeta                      [string]  Path for the MetaMaps database for read classification. [default: None]
    --pair                        [boolean] If barcodes were added at both sides of a read (true) or only at one side (false).
    --quality                     [integer] Minimum quality for a base to build the consensus [default: 7]
    --agreement                   [number]  Minimum base frequency to be called without ambiguity [default: 0.7]
    --depth                       [integer] Minimum depth of a position to build the consensus [default: 5]
    --front                       [integer] Number of bases to delete at 5 prime of the read [default: 0]
    --tail                        [integer] Number of bases to delete at 3 prime of the read [default: 0]
   ```


  
   The command line for this case:
   ```bash
   nextflow run nf-metatropics/ -profile singularity --input /home/itg.be/arezende/example3.csv --outdir /home/itg.be/arezende/testnf_fastq --fasta /home/itg.be/arezende/databases/chm13v2.0.fa --minLength 600 --dbmeta /home/itg.be/arezende/databases/virusDB2 --pair true -resume
   ```

   ## Output

<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->
Below one can see the output directories and their description. `guppy` and `guppydemulti` will exist only in case the user has used FAST5 files as input.

1. [`guppy`] - fastq files after the basecalling without being demultiplexed
2. [`guppydemulti`] - directories and fastq files produced after the demultiplexing
3. [`fix`] - gziped fastq files for each sample of the run
3. [`fastp`] - results after trimming analysis performed by FASTP
4. [`nanoplot`] - quality results for the sequencing data just after demultiplexing
5. [`minimap2`] - BAM files about mapping against host genome
6. [`nohuman`] - gziped fastq files without reads mapping to host genome
7. [`metamaps`] - results from both steps of Metamaps execution for read classification (mapDirectly and Classify)
8. [`r`] - intermediate table report and graphical PDF report for each sample
9. [`ref`] - header of the reads and fasta reference genomes for each virus found for each sample
10. [`krona`] - HTML files for each sample with interactive composition pie chart
11. [`reffix`] - fasta refence genomes with fixed header for each virus found during the run
12. [`seqtk`] - gziped fastq file for each set of read classified to a virus for each sample
13. [`medaka`] - BAM file for each virus with mapping results from the virus genome reference for each sample
14. [`samtools`] - mapping statistics calculated to BAM files present in the `medaka` directory
15. [`ivar`] - consensus sequences produced for each virus found in each sample
16. [`bam`] - detailed statistics for the BAM files from `medaka` directory for each position of virus refence genome
17. [`homopolish`] - consensus sequence for each virus in each sample polished for the indel variations
18. [`addingDepth`] - table report for each virus in each sample
19. [`mafft`] - multiple sequence alignment for each virus for all samples
20. [`snipit`] - SNP plot generated based on the aligments present in the directory `mafft`
21. [`multiqc`] - multiqc report for quality and data filtration, and information on sotware versions
22. [`final`] - final table report for all the run
23. [`pipeline_info`] - reports on the execution of the pipeline produced by NextFlow
## Documentation

The nf-core/metatropics pipeline comes with documentation about the pipeline [usage](https://nf-co.re/metatropics/usage), [parameters](https://nf-co.re/metatropics/parameters) and [output](https://nf-co.re/metatropics/output).

## Credits

nf-core/metatropics was originally written by Antonio Mauro Rezende.

We thank the following people for their extensive assistance in the development of this pipeline:
   > - Koen Vercauteren
   > - Tessa de Block

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#metatropics` channel](https://nfcore.slack.com/channels/metatropics) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations
De Baetselier, I., Van Dijck, C., Kenyon, C. et al. Retrospective detection of asymptomatic monkeypox virus infections among male sexual health clinic attendees in Belgium. Nat Med 28, 2288–2292 (2022). https://doi.org/10.1038/s41591-022-02004-w

Berens-Riha Nicole, De Block Tessa, Rutgers Jojanneke, Michiels Johan, Van Gestel Liesbeth, Hens Matilde, ITM monkeypox study group, Kenyon Chris, Bottieau Emmanuel, Soentjens Patrick, van Griensven Johan, Brosius Isabel, Ariën Kevin K, Van Esbroeck Marjan, Rezende Antonio Mauro, Vercauteren Koen, Liesenborghs Laurens. Severe mpox (formerly monkeypox) disease in five patients after recent vaccination with MVA-BN vaccine, Belgium, July to October 2022. Euro Surveill. 2022;27(48):pii=2200894. https://doi.org/10.2807/1560-7917.ES.2022.27.48.2200894



<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use  nf-core/metatropics for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
