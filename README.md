# Repository for various scripts to automate tasks

### mockrobiota-download.sh

Download desired mock community from [Mockrobiota repository](https://github.com/caporaso-lab/mockrobiota) based on information in `inventory.tsv`. The script creates a directory based on for the downloaded mock community, deposits the raw reads in 'reads' and downloads sample and dataset metadata files.  

For more information on the Mockrobiota project see: https://github.com/caporaso-lab/mockrobiota    
_Bokulich NA, Rideout JR, Mercurio WG, Shiffer A, Wolfe B, Maurice CF, Dutton RJ, Turnbaugh PJ, Knight R, Caporaso JG. 2016. mockrobiota: a Public Resource for Microbiome Bioinformatics Benchmarking. mSystems 1 (5): e00062-16. DOI: 10.1128/mSystems.00062-16._  

```
VERSION=0.1.0
SUBJECT=MockrobiotaDownload
USAGE="mockrobiota-download.sh [OPTIONS] -m  <mock community> -t <type of reads> -d <output directory>"

Options:
        Required
        -m|--mock          Mock community to download - name as found on Mockrobiota github (REQUIRED)
        -t|--type          Type of download - options FR (fwd and rev reads), FB (fwd and barcode), FRB (fwd, rev and barcode) 
                           (REQUIRED)   
        
        General:
        -h|--help         Displays this help
        -d|--dir          Path to folder where the script will create output
                                (Default folder: $HOME/Desktop)
        -si|--skip_inv    Option to skip download inventory
                                (Default NO)
        -sm|--skip_meta   Option to skip download metadata files
                                (Default NO)
```

Notes:  
If an ouput directory is not specified, the files will be downloaded into a directory created on the user's Desktop. If the `skip_inv` option is also specified, then make sure that the `inventory.tsv` file is located on the `user/Desktop`.  

### q2-upload.sh  

Import sequence reads as q2 artefact file and demultiplex when needed.   
  
**Requirements:**  
1. If fastqs are compressed it must be .gz  
`for f in *.bz2; do bzcat "$f" | gzip -c >"${f%.*}.gz"; done`  
2. If uploading raw reads with barcodes for demultiplexing:  
The raw sequence reads need to be in their own folder *reads*; and named *forward.fastq.gz, reverse.fastq.gz, barcodes.fastq.gz*  
These are the only files in that folder.  
A *sample-metadata.tsv* file is required, containing at least *SampleID* and *BarcodeSequence* columns.  
If `-r|--reads` is not supplied and demultiplexing is required, then the `pwd` must contain a folder called `reads`.
3. If uploading raw, demultiplexed reads.  
A *manifest.tsv* file is required with the following information:  
```
sample-id       forward-absolute-filepath       reverse-absolute-filepath
sample-1        filepathforward-read.fastq.gz   filepath/reverse-read.fastq.gz
```
4. $DIR = folder where output will be created. Must contain the relevant metadata file.  

```
VERSION=0.1.0
SUBJECT="QIIME2 Data Import"
USAGE="q2-upload.sh [OPTIONS] -m  <path to metadat> -n <sample name>"
CITATION="Boylen E, et al. QIIME 2: Reproducible, interactive, scalable, and extensible microbiome data science. PeerJ Preprints 6:e27295v2 https://doi.org/10.7287/peerj.preprints.27295v2"

function usage() {
    cat << EOF
    Import sequence reads into qiime2.
    Usage: $USAGE
    Citation: $CITATION

    Options:
        Required
        -m|--meta          Metadata file (sample-metadata.tsv or manifest.tsv) (REQUIRED)
        -n|--name          Name of project (REQUIRED)
        
        General:
        -h|--help         Displays this help
        -d|--dir          Path to working directory - contains metadata file.
                                (Default folder: $PWD)
        -r|--reads        Path to folder containing the "reads" directory.
                                (Default folder: $PWD)                 
EOF
}
```
