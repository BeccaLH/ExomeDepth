library("ExomeDepth")
library("GenomicRanges")

Alignment_folder <- '/home/rebecca/ExomeDepth/Control_Validation_Data/MaleCtrl'
setwd(Alignment_folder)
bed <- '/home/rebecca/ExomeDepth/TSC_CNV_120bp.bed'
reference.fasta <- '/home/rebecca/ReferenceGenome/hg19.fasta'

panel.version <- "TSC"

#get list of sample BAM files
bams.positive <- list.files(path = Alignment_folder, pattern = "ExD_ctrl_M.*\\.bam$", full.names = TRUE)
bais.positive <- list.files(path = Alignment_folder, pattern = "ExD_ctrl_M.*\\.bai", full.names = TRUE)

dir.base <- NULL
dir.output <- NULL
dir.results <- NULL

bams.selected <- c(bams.positive)
bais.selected <- c(bais.positive)
# Create counts dataframe for all BAMs
my.counts <- getBamCounts(bed.file = bed, bam.files = bams.selected, index.files = bais.selected, min.mapq = 20, include.chr = FALSE, referenceFasta = reference.fasta)
ExomeCount.dafr <- as(my.counts[, colnames(my.counts)], 'data.frame')
ExomeCount.dafr$chromosome <- gsub(as.character(ExomeCount.dafr$space),pattern = 'chr',replacement = '')

# Create matrix
MaleExomeCount.mat <- as.matrix(ExomeCount.dafr[, grep(names(ExomeCount.dafr), pattern = '*.bam')])

dir.base <- sprintf("/home/rebecca/ExomeDepth/Control_Validation_Data/")	
dir.output <- file.path(dir.base)	
dir.create(dir.output)
save.image( sprintf("%s/male_ExomeDepth_ctrl_count.RData", dir.output) )
