#!/bin/bash

### ExomeDepth_BRCA.sh
### Author: Rebecca Haines (rebecca.haines@nuh.nhs.uk)
### version: v1
### Date: 2016/08/29
### Bash script for running ExomeDepth, annotating variants with BRCA1 and BRCA2 exon information 
### Results are filtered to display only BRCA1 and BRCA2 variants to the user.

echo "ExomeDepth_BRCA.sh version v1 (2016/08/29)"
echo "Calling CNVs using ExomeDepth"

# print end date and time
start=$(date)
echo "Start date and time: $start"

# call Rscript to call variants and annotate BRCA1 and BRCA2 variants
Rscript --vanilla R_codefiles/TSC_ExomeDepth_ControlsLoop_v2.R

echo "python version"
python --version

# python script to filter for BRCA1 variants
echo "Filter BRCA1 variants"
python ExomeDepth_csv_gene_filter_v1.py Control_Validation_Data/FemalePos/BRCA_varcalls BRCA1

# python script to filter for BRCA2 variants]
echo "Filter BRCA2 variants"
python ExomeDepth_csv_gene_filter_v1.py Control_Validation_Data/FemalePos/BRCA_varcalls BRCA2

# print end date and time
end=$(date)
echo "End date and time: $end"
