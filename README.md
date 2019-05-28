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
