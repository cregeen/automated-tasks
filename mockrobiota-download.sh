#!/usr/bin/env bash

set -euo pipefail

#========================================================================================================================================#
# Sara Javornik Cregeen | May-2019 | ver 1 | mockrobiota-download.sh
#
# Download desired mock community from Mockrobiota repository info in inventory.tsv
# Creates a directory based on the downloaded MOCK, deposits the raw reads in 'reads' and downloads sample and dataset metadata files.
# 
# For more information on the Mockrobiota project see: https://github.com/caporaso-lab/mockrobiota
# Citation: Bokulich NA, Rideout JR, Mercurio WG, Shiffer A, Wolfe B, Maurice CF, Dutton RJ, 
#           Turnbaugh PJ, Knight R, Caporaso JG. 2016. mockrobiota: a Public Resource for 
#           Microbiome Bioinformatics Benchmarking. mSystems 1 (5): e00062-16. DOI: 10.1128/mSystems.00062-16.
#========================================================================================================================================#

VERSION=0.1.0
SUBJECT="Mockrobiota Download"
USAGE="mockrobiota-download.sh [OPTIONS] -m  <mock community> -t <type of reads> -d <output directory>"
CITATION="Bokulich et al. 2016. mockrobiota: a Public Resource for Microbiome Bioinformatics Benchmarking. mSystems 1 (5): e00062-16. DOI: 10.1128/mSystems.00062-16."

function usage() {
    cat << EOF
    Download Mockrobiota dataset from https://github.com/caporaso-lab/mockrobiota
    Usage: $USAGE
    Citation: $CITATION

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

EOF
}


# --- Setting variables -------------------------------------------
MOCK="PLACEHOLDER"
TYPE="PLACEHOLDER"
DIR="$HOME/Desktop"

skip_inventory=0
skip_meta=0

# --- Functions -------------------------------------------------

# Download inventory file (into wd)
function InventoryDownload(){
    wget https://raw.githubusercontent.com/caporaso-lab/mockrobiota/master/inventory.tsv
}

# Type specific downloads
function FwdRev(){
    cd ${MOCK}/reads
    FR=$(cat $DIR/inventory.tsv | grep "$MOCK" | cut -f3,4 | grep "$MOCK")
    for i in $FR;do 
        wget $i;
    done
}

function FwdRevBar(){
    cd ${MOCK}/reads
    FRB=$(cat $DIR/inventory.tsv | grep "$MOCK" | cut -f3,4,5 | grep "$MOCK")
    for i in $FRB;do 
        wget $i;
    done
}

function FwdBar(){
    cd ${MOCK}/reads
    FB=$(cat $DIR/inventory.tsv | grep "$MOCK" | cut -f3,5 | grep "$MOCK")
    for i in $FB;do 
        wget $i;
    done
}

# Download sample and dataset metadata files
function metadata(){
    cd $DIR/$MOCK
    wget https://raw.githubusercontent.com/caporaso-lab/mockrobiota/master/data/${MOCK}/sample-metadata.tsv
    wget https://raw.githubusercontent.com/caporaso-lab/mockrobiota/master/data/${MOCK}/dataset-metadata.tsv
}

# --- Main -------------------------------------------------

while [ $# -gt 0 ]; do
  case $1 in
     -m|--mock)
       shift
       MOCK=$1
       ;;
     -t|--type)
       shift
       TYPE=$1
       ;;
     -d|--dir)
       shift
       DIR=$1
       ;;
     -si|--skip_inv)
       skip_inventory=1
       ;;
     -sm|--skip_meta)
       skip_meta=1
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


echo -e "Starting $SUBJECT $VERSION" "\n""You chose to download dataset $MOCK" "\n""Citation: $CITATION" 

echo -e "\n" "----" "\n"

# create directory structure for download
cd $DIR
mkdir -p "${MOCK}/reads"

if [ "$MOCK" == "PLACEHOLDER" ];
  then echo -e "ERROR:""\n""Please provide a Mock community name with the -m option""\n" && exit;
  else echo -e "$MOCK - Good to go!";
fi

if [ "$TYPE" == "PLACEHOLDER" ];
  then echo -e "ERROR:""\n""Please provide type of download with the -t option""\n" && exit;
  else echo -e "$TYPE - Good to go!";
fi;

echo -e "\n" "----" "\n"

if [ $skip_inventory == 0 ]; 
    then InventoryDownload; echo "Downloaded inventory.tsv file.";
    else echo "You skipped Downloading inventory.tsv"; 
fi

echo -e "\n" "----" "\n"

if [ $TYPE == "FR" ]; 
  then FwdRev; echo "Downloaded fwd and rev reads.";
elif [ $TYPE == "FRB" ]; 
  then FwdRevBar; echo "Downloaded fwd, rev and barcodes.";
elif [ $TYPE == "FB" ]; 
  then FwdBar; echo "Downloaded fwd reads and barcodes.";
fi

echo -e "\n" "----" "\n"   

if [ $skip_meta == 0 ]; 
    then metadata; echo "Downloaded sample and dataset metadata.";
    else echo "You skipped Downloading metadata files"; 
fi

echo -e "----" "\n"
echo -e "Download is completed." "\n""Go to https://github.com/caporaso-lab/mockrobiota for notes, known issues and more information about your dataset." "\n"