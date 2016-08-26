# ExomeDepth development readme

Author: Rebecca Haines
Date modified: 25/08/2016

## Preparing the bed file

ExomeDepth uses depth count data across regions of interest (windows) taken from a bed file. The TSC bed file ROIs are whole exons, some of which are very large (eg BRCA1 exon 11). Advice from Andrew Parrish (AP, Exeter lab) is that 120bp windows give best results. Python script provided by AP was used to subdivide the TSC bed file. File is called `panel_CNV_120bp.bed`. 

To generate this file:
`python cnv_bed_files.py trusight_cancer_manifest_a.bed`

**bed file name**: `panel_CNV_120bp.bed`

## Generating the control data sets

Control samples were selected from TruSight Cancer runs (Cancer_72 and earlier) based on testing being completed and negative MLPA results.

|Genes tested|Males    |Females  |
|------------|:-------:|:-------:|
|non-BRCA    |24       |15       |
|BRCA        |6        |49       |

Many samples tested for BRCA also tested for other breast/ovarian cancer panel genes.

Details of samples used recorded in `Controls_ExomeDepth_Validation.xls` in my H drive STPDocs/CBI8 folder. This file contains original sample ids and runs.

### Preparing the control bam files

All control samples were identified and copied to the folder `/home/rebecce/ExomeDepth/Control_Validation_Data` using:
`cp /path/to/file/on/SeqPilot /home/rebecce/ExomeDepth/Control_Validation_Data`

ExomeDepth requires bam files to be indexed. Used samtools to index them (generate .bai files)
`samtools index Filename.bam`

### Running ExomeDepth to get depth count data for all regions of interest

Using R script `TSC_female_v1.r` for female controls and `TSC_male_v1.r` for male controls.

Ran both scripts in RStudio. Dataframes generated for FemaleExomeCount and MaleExomeCount. All other data removed from the RStudio console environment then saved as an RData object. 

**Controls depth count data object:**`TSC_controls.RData`

## Running ExomeDepth on positive control samples

