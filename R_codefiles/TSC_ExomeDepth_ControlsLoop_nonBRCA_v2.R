### Author: Rebecca Haines
### Date: 27/08/2016
### for calling variants using the other (non-BRCA) -ve control set

library("ExomeDepth")
library("GenomicRanges")

load("/home/rebecca/ExomeDepth/ctrl_counts.RData")

output_folder <- '/home/rebecca/ExomeDepth/Control_Validation_Data/FemalePos/other_varcalls/'
setwd(output_folder)
bams_folder <- '/home/rebecca/ExomeDepth/Control_Validation_Data/FemalePos/bam_files_other/'

bed <- "/home/rebecca/ExomeDepth/TSC_CNV_120bp.bed"
reference.fasta <- '/home/rebecca/ReferenceGenome/hg19.fasta'

AnnotationFilterFile <- '/home/rebecca/ExomeDepth/BRCA_exons.csv'
AnnotationFilterBed <- read.csv(AnnotationFilterFile)

AnnotationFilter.GRanges <- GRanges(seqnames = AnnotationFilterBed$chromosome, 
                                    IRanges (start = AnnotationFilterBed$start, end = AnnotationFilterBed$end), 
                                    names = AnnotationFilterBed$id)

bams.positive <- list.files(path = bams_folder, pattern = "ExD_Pos_F.*\\.bam$", full.names = TRUE)
bais.positive <- list.files(path = bams_folder, pattern = "ExD_Pos_F.*\\.bam.bai", full.names = TRUE)

bams.selected <- c(bams.positive)
bais.selected <- c(bais.positive)
# Create counts dataframe for all BAMs
my.counts <- getBamCounts(bed.file = bed, bam.files = bams.selected, index.files = bais.selected, min.mapq = 20, include.chr = FALSE, referenceFasta = reference.fasta)
ExomeCount.dafr <- as(my.counts[, colnames(my.counts)], 'data.frame')
ExomeCount.dafr$chromosome <- gsub(as.character(ExomeCount.dafr$space),pattern = 'chr',replacement = '')

ExomeCount.mat <- as.matrix(ExomeCount.dafr[, grep(names(ExomeCount.dafr), pattern = "ExD_Pos_F*")])
nsamples <- ncol(ExomeCount.mat)
samplenames <- colnames(ExomeCount.mat)

for (i in 1:nsamples) {
  samplename <- samplenames[i]
  print(samplename)
  my.choice <- select.reference.set(test.counts = ExomeCount.mat[,i],
                                    reference.counts = FemaleExomeCount.mat[,-i],
                                    bin.length = (ExomeCount.dafr$end - ExomeCount.dafr$start)/1000,
                                    n.bins.reduced = 10000)

  my.reference.selected <- apply(X = FemaleExomeCount.mat[, my.choice$reference.choice], drop = FALSE,
                                 MAR = 1,
                                 FUN = sum)
  
  message('Now creating ExomeDepth object')
  all.exons <- new("ExomeDepth",
                   test = ExomeCount.mat[,i],
                   reference = my.reference.selected,
                   formula = "cbind(test, reference) ~ 1")

  ####now call the CNVs
  all.exons <- CallCNVs(x = all.exons,
                        transition.probability = 10^-4,
                        chromosome = ExomeCount.dafr$space,
                        start = ExomeCount.dafr$start,
                        end = ExomeCount.dafr$end,
                        name = ExomeCount.dafr$names)
  
  #plot BRCA1
  BRCA1_graphname <- paste(samplename,'_BRCA1.jpg', sep='') 
  jpeg(BRCA1_graphname)
  BRCA1_graphtitle <- paste(samplename,'_BRCA1', sep ='')
  plot(all.exons, sequence = "chr17",
       xlim = c(41196312 - 100000, 41277500 + 100000),
       count.threshold = 20,
       main = BRCA1_graphtitle,
       cex.lab = 0.8,
       with.gene = TRUE)
  dev.off()
  
  #plot BRCA2
  BRCA2_graphname <- paste(samplename,'_BRCA2.jpg', sep='') 
  jpeg(BRCA2_graphname)
  BRCA2_graphtitle <- paste(samplename,'_BRCA2', sep ='')
  plot(all.exons, sequence = "chr13",
       xlim = c(32889617 - 100000, 32973805 + 100000),
       count.threshold = 20,
       main = BRCA2_graphtitle,
       cex.lab = 0.8,
       with.gene = TRUE)
  dev.off()
  
 ### Handle samples with no CNV calls- do not annotate them, direct them to the output file 
  if (length(all.exons@CNV.calls) == 0) {
    print("no calls")
    output.file <- paste(samplename, "CNVcalls_120window_BRCA_Annotation.csv", sep = "")
    write.csv(file = output.file, x = all.exons@CNV.calls, row.names = FALSE)
  }
  ### annotate calls with the BRCA exons annotation file
  else {
  ####annotate with TSC bed
  all.exons <- AnnotateExtra(x = all.exons,
                             reference.annotation = AnnotationFilter.GRanges,
                             min.overlap = 0.01,
                             column.name = "BRCA_exons")
  
  output.file <- paste(samplename, "CNVcalls_120window_BRCA_Annotation.csv", sep = "")
  write.csv(file = output.file, x = all.exons@CNV.calls, row.names = FALSE)
  }
}
