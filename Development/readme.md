# ExomeDepth for TruSight Cancer CNV calling development readme

Author: Rebecca Haines (rebecca.haines@nuh.nhs.uk)

Date modified: 29/08/2016

Description of the development work performed for ExomeDepth calling. 

#### Software versions used

Development work using R was performed using R Studio. Python scripts were run from the command line after modification using the Canopy Python IDE.

|          |Version   |
|----------|:--------:|
|RStudio   |0.99.903  |
|R         |3.3.1     |
|python    |2.7.9     |
|Canopy    |1.5.5.3123|
|ExomeDepth|1.1.10    |

ExomeDepth is published by Plagnol et al (2012, Bioinformatics 28:2747-2554 [DOI:10.1093/bioinformatics/bts526](http://bioinformatics.oxfordjournals.org/content/28/21/2747.long))

## Preparing the bed file

ExomeDepth uses depth count data across regions of interest (windows) taken from a bed file. The TSC bed file ROIs are whole exons, some of which are very large (eg BRCA1 exon 11). Advice from Andrew Parrish (AP, Exeter lab) is that 120bp windows give best results. Python script provided by AP was used to subdivide the TSC bed file.

To generate this file:
```
python cnv_bed_files.py trusight_cancer_manifest_a.bed
```

**bed file name**: `panel_CNV_120bp.bed`

## Generating the control data sets

Details of samples used recorded in `Controls_ExomeDepth_Validation.xls` in my H drive STPDocs/CBI8 folder. This file contains original sample ids and runs.

#### Negative controls

Control samples were selected from TruSight Cancer runs (Cancer_72 and earlier) based on testing being completed and negative MLPA results.

|Genes tested|Males    |Females  |
|------------|:-------:|:-------:|
|non-BRCA    |24       |15       |
|BRCA        |6        |49       |

Many samples tested for BRCA also tested for other breast/ovarian cancer panel genes.

#### Positive Controls

Samples were selected from the Cancer active list and samples identified by LPD for Multiplicom testing. Samples were identified that had been on a TruSight Cancer run and had a positive MLPA result (in any gene).

|mutations identified|Males   |Females  |
|--------------------|:------:|:-------:|
|non-BRCA            |2       |4        |
|BRCA                |0       |6        |

#### Preparing the control bam files

All control samples were identified and copied to the folder `/home/rebecca/ExomeDepth/Control_Validation_Data` using:
```
cp /path/to/file/on/SeqPilot /home/rebecca/ExomeDepth/Control_Validation_Data
```

ExomeDepth requires bam files to be indexed. Used samtools to index them (generate .bai files)
```
samtools index filename.bam
```

#### Running ExomeDepth to get depth count data for all regions of interest in negative controls

Using R script `TSC_female_v1.r` for female controls and `TSC_male_v1.r` for male controls.

Ran both scripts in RStudio. Dataframes generated for FemaleExomeCount and MaleExomeCount. All other data removed from the RStudio console environment then saved as an RData object. 

**Controls depth count data object:**`TSC_controls.RData`

## Running ExomeDepth on positive control samples

Using R script `TSC_ExomeDepth_ControlsLoop_v2.R`. Script must be modified for female or male samples. 
For details see comments in the script.

Details of positive control samples used are recorded in `Controls_ExomeDepth_Validation.xls` in my H drive STPDocs/CBI8 folder. This file contains original sample ids, TruSight cancer runs, and variants. The file `ExomeDepth_Controls` has anonymised sample IDs and variant information only.

#### CNV calling

Uses the `TSC_CNV_120bp.bed` file (with 120bp windows for CNV calling) and the coverage depth count results in `TSC_controls.RData`. Depth count data is generated for all of the samples. GC content is taken in to account (ExomeDepth does this when the reference genome fasta is supplied. CNVs are then called on all samples.

The results are written to a .csv file that contains details of the region (using genomic coordinates), the Bayes Factor (statistical support for each CNV), and the reads ratio. The reads ratio can be interpreted in a similar way to MLPA dosage quotient scores, i.e. a score ~1 means no change, ~0.5 means a heterozygous deletion and ~1.5 is a heterozygous duplication.

#### CNV annotation- BRCA exons

An annotation file was generated containing the names of TruSight Cancer regions of interest with exon numbers added (based on those used in the lab, so eg BRCA1 does not have an exon 4). CNV calls can be annotated with this file so that variants in *BRCA1* and *BRCA2* can be easily identified. These annotations are added to the .csv file.

#### Generating graphs for BRCA1 and BRCA2

Graphs showing results (reads ratio) for the *BRCA1* and *BRCA2* genes are generated for each sample and saved as jpegs in the same folder as the .csv output file.

## Filtering the output files for only genes of interest

Python script `ExomeDepth_csv_gene_filter_v1.py` written to filter ExomeDepth output .csv files to include only genes of interest for that sample. The script takes two arguments: /path/to/csvfiles and gene_name

## Automating the workflow

Bash script `ExomeDepth_BRCA.sh` written to automate variant calling and filtering of the variants and generate audit log. File is executable so CNV calling can be performed using:
```
nohup ./ExomeDepth_BRCA.sh > logfile.txt
```

The name of the output logfile.txt can be changed to any appropriate file name. Nohup is used to ensure the execution of the script will complete even if the computer is logged off.
