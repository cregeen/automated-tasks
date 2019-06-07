#!/usr/bin/env bash

set -euxo pipefail

# --- Description -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# QIIME2 wrapper - importing data
# Sara Javornik Cregeen | June-2019 | ver 1 | q2-upload.sh
#
# Import sequence reads as q2 artefact file and demultiplex when needed. If fastqs are compressed it must be .gz
#
# OPT 1: upload raw reads + demultiplex
#  Requierments: The raw sequence reads need to be in their own folder and named forward.fastq.gz, reverse.fastq.gz, barcodes.fastq.gz. These are the only files in that folder.
# 
# OPT 2: upload raw, demultiplexed reads. 
#  Requierments: A "manifest.tsv" file is required.
#
# make sure that `conda activate qiime2-2019.4`
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

# --- Setting variables -------------------------------------------

DIR=$PWD
READS="reads"
METADATA=""
NAME=""
OUTPUT="q2-reads"

# --- Functions -------------------------------------------

function seq-check(){
  if ls $READS | grep -Fq "forward.fastq.gz"; then echo "Found \"forward.fastq.gz\"" ; else echo "Missing \"forward.fastq.gz\" file" && exit; fi
  if ls $READS | grep -Fq "reverse.fastq.gz"; then echo "Found \"reverse.fastq.gz\"" ; else echo "Missing \"reverse.fastq.gz\" file" && exit; fi
  if ls $READS | grep -Fq "barcodes.fastq.gz"; then echo "Found \"barcodes.fastq.gz\"" ; else echo "Missing \"barcodes.fastq.gz\" file" && exit; fi
}

function Q2-import(){
    qiime tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-path $METADATA \
        --output-path ${OUTPUT}/${NAME}-demux.qza \
        --input-format PairedEndFastqManifestPhred33V2
    
    qiime demux summarize \
        --i-data ${OUTPUT}/${NAME}-demux.qza \
        --o-visualization ${OUTPUT}/${NAME}-demux.qzv
}

function Q2-demux(){
    qiime tools import \
        --type EMPPairedEndSequences \
        --input-path ${READS} \
        --output-path ${OUTPUT}/${NAME}-reads.qza
    
    qiime demux emp-paired \
        --m-barcodes-file $METADATA \
        --m-barcodes-column BarcodeSequence \
        --i-seqs ${OUTPUT}/${NAME}-reads.qza \
        --o-per-sample-sequences ${OUTPUT}/${NAME}-demux.qza \
        --o-error-correction-details ${OUTPUT}/${NAME}-demux-error.qza

    qiime demux summarize \
        --i-data ${OUTPUT}/${NAME}-demux.qza \
        --o-visualization ${OUTPUT}/${NAME}-demux.qzv
}

# --- Main -------------------------------------------------

while [ $# -gt 0 ]; do
  case $1 in
     -m|--meta)
       shift
       METADATA=$1
       ;;
     -n|--name)
       shift
       NAME=$1
       ;;
     -d|--dir)
       shift
       DIR=$1
       ;;
     -r|--reads)
       shift
       READS=$1
       ;;
     -h|--help)
       usage
       exit 0
       ;;
     *) 
       echo "invalid command: no parameter included with argument $1"
       exit 0
       ;;
  esac
  shift
done


# ------------ Different ways to check parameters ------------#


echo -e "Starting $SUBJECT $VERSION" "\n""Citation: $CITATION" 

echo -e "\n" "----" "\n"

# create directory structure for download
cd $DIR
mkdir -p "${OUTPUT}"

#check required arguments
if ls $METADATA 1> /dev/null 2>&1; then echo "Found Metadata file" ; else echo -e "ERROR:""\n""Please provide a metadata file with the -m option""\n" && exit; fi

if [ "$METADATA" == "sample-metadata.tsv" ]; 
  then seq-check; echo "Checked sequence files."
fi

echo -e "\n" "----" "\n"

if [ "$METADATA" == "manifest.tsv" ];
    then Q2-import; echo "Importing raw reads, no demultiplexing.";
    else Q2-demux; echo "Importing raw reads and demultiplexing."; 
fi

echo -e "\n" "----" "\n"

echo -e "Import is completed." "\n"