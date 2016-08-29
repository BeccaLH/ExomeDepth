# ExomeDepth for cnv calling from TruSight Cancer 

Author: Rebecca Haines (rebecca.haines@nuh.nhs.uk)

Date modified: 2016/08/29

A workflow to call and annotate copy number variants from TruSight Cancer NGS data. 
Annotation and filtering performed for *BRCA1* and *BRCA2* variants only.

## Running the workflow

Executable bash script `ExomeDepth_BRCA.sh`. To run the workflow:
```
nohup ./ExomeDepth_BRCA.sh > logfile.txt
```

This Bash script calls the R script `TSC_ExomeDepth_ControlsLoop_v2.R` for CNV calling and annotation and the python script `ExomeDepth_csv_gene_filter_v1.py` to filter for calls in *BRCA1* and *BRCA2*.

Running the workflow using nohup will ensure it completes even if the user logs off. 
The name of logfile.txt should be changed to an appropriate filename for the analysis.

#### Workflow inputs and outputs

Input: .bam (and .bai index) files for each sample. These should all be stored in the same folder. 
If .bai files are not available these can be generated using:
```
samtools index filename.bam
```

Output for each sample:

- \_Annotation.csv file containing all variants, annotated with BRCA1/BRCA2 exon information.
- jpeg graphs showing *BRCA1* and *BRCA2* reads ratio
- BRCA1filtered.csv and BRCA2filtered.csv files containing only *BRCA1* or *BRCA2* variants.

## Data/files used

#### Control data sets

Known BRCA1/2 negative control samples (Samples that have been sequenced on TruSight Cancer and *BRCA1* and *BRCA2* MLPA performed and no CNVs identified). Control .bam and .bai files are in the folder `Control_Validation_Data/FemaleCtrl/BRCA_ctrl/`.

Read count data generated using R script `TSC_female_v1.r` and saved as R data object `ctrl_counts_BRCA.RData`.

#### BRCA reference sequences

*BRCA1* ref seq: NM_007294

*BRCA2* ref seq: NM_000059

