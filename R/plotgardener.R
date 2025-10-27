library(plotgardener)
library(txdbmaker)

#' Data
SPL1_1_signal <- "C:/Users/Teitur/Desktop/DAPseq_Sami/deepTools/bamCoverage_SPL1_1/JZ25141633-SPL1_1-SPL1_1_combined_trimmomatic.filtered.markdup.sorted.bw"
SPL1_2_signal <- "C:/Users/Teitur/Desktop/DAPseq_Sami/deepTools/bamCoverage_SPL1_2/JZ25141634-SPL1_2-SPL1_2_combined_trimmomatic.filtered.markdup.sorted.bw"

SPL1_consensus_peaks <- "C:/Users/Teitur/Desktop/DAPseq_Sami/macs3.consensus_peaks/SPL1/SPL1.consensus_peaks.narrowPeak"

DAL55_BLAST_HIT.df <- data.frame("chr" = c("PA_chr10", "PA_chr10"),
                                 "start" = c(211031963, 211209482),
                                 "end" = c(211032018 , 211211212))

#' Making a TxDb object for the spruce genome
fai <- read.table("C:/Users/Teitur/Desktop/DAPseq_Sami/fasta/pabies-2.0_chromosomes_and_unplaced.fa.fai", 
                  header = FALSE, 
                  col.names = c("NAME", "LENGTH", "OFFSET", "LINEBASES", "LINEWIDTH"))

chrominfo <- data.frame(
  chrom = fai$NAME,
  length = fai$LENGTH,
  is_circular = c(rep(FALSE, NROW(fai)))
)

txdb <- txdbmaker::makeTxDbFromGFF(file = "C:/Users/Teitur/Desktop/DAPseq_Sami/Pabies_annotation/Picab02_230926_at01_longest_no_TE_sorted.only_PASA_PASN.gff3", 
                                   format = "gff3", 
                                   organism = "Picea abies", 
                                   chrominfo = chrominfo)

PA <- assembly(
  Genome = "Picea abies",
  TxDb = txdb,
  OrgDb = NULL,
  gene.id.column = "gene_id",
  display.column = "gene_id",
  BSgenome = NULL
)

#' Plot PA_chr07_G003407 (DAL1)
pageCreate(width = 25.5, height = 13.5, default.units = "cm", xgrid = TRUE, ygrid = TRUE, showGuides = FALSE)

region1 <- pgParams(
  chrom = "PA_chr07",
  chromstart = 792232683,
  chromend = 792252684,
  assembly = PA
)

plotGenomeLabel(
  params = region1,
  scale = "Kb",
  x = 0.25, y = 0, length = 25, default.units = "cm", fontsize = 14,
)

plotGenes(params = region1,
          width = 25, 
          height = 4,
          default.units = "cm",
          x = 0.25, y = 1,
          fontsize = 14, strandLabels = TRUE)

plotText(
  label = "Genes", fonsize = 10, fontcolor = "black",
  x = 1, y = 3, just = c("left"),
  default.units = "cm"
)

plotRanges(data = SPL1_consensus_peaks,
           params = region1,
           x = 0.25, y = 2.5, height = 3, width = 25,
           default.units = "cm", 
           linecolor = "black")

plotText(
  label = "SPL1 consensus peaks", fonsize = 10, fontcolor = "black",
  x = 1, y = 5.2, just = c("left"),
  default.units = "cm"
)

plotSignal(
  data = SPL1_1_signal,
  params = region1,
  x = 0.25, y = 6.5, height = 3, width = 25, default.units = "cm"
)

plotText(
  label = "SPL1 rep1", fonsize = 10, fontcolor = "black",
  x = 1, y = 7.7, just = c("left"),
  default.units = "cm"
)

plotSignal(
  data = SPL1_2_signal,
  params = region1,
  x = 0.25, y = 10, height = 3, width = 25, default.units = "cm"
)

plotText(
  label = "SPL1 rep2", fonsize = 10, fontcolor = "black",
  x = 1, y = 11.5, just = c("left"),
  default.units = "cm"
)


#' Plot PA_chr01_G000442 (DAL14)
pageCreate(width = 25.5, height = 13.5, default.units = "cm", xgrid = TRUE, ygrid = TRUE, showGuides = FALSE)


region2 <- pgParams(
  chrom = "PA_chr01",
  chromstart = 130605900,
  chromend = 130625955,
  assembly = PA
)

plotGenomeLabel(
  params = region2,
  scale = "Kb",
  x = 0.25, y = 0, length = 25, default.units = "cm", fontsize = 14,
)

plotGenes(params = region2,
          width = 25, 
          height = 4,
          default.units = "cm",
          x = 0.25, y = 1,
          fontsize = 14, strandLabels = TRUE)

plotText(
  label = "Genes", fonsize = 10, fontcolor = "black",
  x = 1, y = 3, just = c("left"),
  default.units = "cm"
)

plotRanges(data = SPL1_consensus_peaks,
           params = region2,
           x = 0.25, y = 2.5, height = 3, width = 25,
           default.units = "cm", 
           linecolor = "black")

plotText(
  label = "SPL1 consensus peaks", fonsize = 10, fontcolor = "black",
  x = 1, y = 5.2, just = c("left"),
  default.units = "cm"
)

plotSignal(
  data = SPL1_1_signal,
  params = region2,
  x = 0.25, y = 6.5, height = 3, width = 25, default.units = "cm"
)

plotText(
  label = "SPL1 rep1", fonsize = 10, fontcolor = "black",
  x = 1, y = 7.7, just = c("left"),
  default.units = "cm"
)

plotSignal(
  data = SPL1_2_signal,
  params = region2,
  x = 0.25, y = 10, height = 3, width = 25, default.units = "cm"
)

plotText(
  label = "SPL1 rep2", fonsize = 10, fontcolor = "black",
  x = 1, y = 11.5, just = c("left"),
  default.units = "cm"
)


#' Plot PA_chr12_G002466 (SPL1)
pageCreate(width = 25.5, height = 13.5, default.units = "cm", xgrid = TRUE, ygrid = TRUE, showGuides = FALSE)

region3 <- pgParams(
  chrom = "PA_chr12",
  chromstart = 692186694,
  chromend = 692206709,
  assembly = PA
)

plotGenomeLabel(
  params = region3,
  scale = "Kb",
  x = 0.25, y = 0, length = 25, default.units = "cm", fontsize = 14,
)

plotGenes(params = region3,
          width = 25, 
          height = 4,
          default.units = "cm",
          x = 0.25, y = 1,
          fontsize = 14, strandLabels = TRUE)

plotText(
  label = "Genes", fonsize = 10, fontcolor = "black",
  x = 1, y = 3, just = c("left"),
  default.units = "cm"
)

plotRanges(data = SPL1_consensus_peaks,
           params = region3,
           x = 0.25, y = 2.5, height = 3, width = 25,
           default.units = "cm", 
           linecolor = "black")

plotText(
  label = "SPL1 consensus peaks", fonsize = 10, fontcolor = "black",
  x = 1, y = 5.2, just = c("left"),
  default.units = "cm"
)

plotSignal(
  data = SPL1_1_signal,
  params = region3,
  x = 0.25, y = 6.5, height = 3, width = 25, default.units = "cm"
)

plotText(
  label = "SPL1 rep1", fonsize = 10, fontcolor = "black",
  x = 1, y = 7.7, just = c("left"),
  default.units = "cm"
)

plotSignal(
  data = SPL1_2_signal,
  params = region3,
  x = 0.25, y = 10, height = 3, width = 25, default.units = "cm"
)

plotText(
  label = "SPL1 rep2", fonsize = 10, fontcolor = "black",
  x = 1, y = 11.5, just = c("left"),
  default.units = "cm"
)

#' Plot MA-30261g0010 (DAL55)
pageCreate(width = 25.5, height = 13.5, default.units = "cm", xgrid = TRUE, ygrid = TRUE, showGuides = FALSE)

region4 <- pgParams(
  chrom = "PA_chr10",
  chromstart = 211200473,
  chromend = 211220517,
  assembly = PA
)

plotGenomeLabel(
  params = region4,
  scale = "Kb",
  x = 0.25, y = 0, length = 25, default.units = "cm", fontsize = 14,
)


plotRanges(data = DAL55_BLAST_HIT.df,
           params = region4,
           x = 0.25, y = 1, height = 3, width = 25,
           default.units = "cm", 
           fill = "pink3",
           linecolor = "black")


plotText(
  label = "DAL55 5'UTR BLAST HIT", fonsize = 10, fontcolor = "black",
  x = 1, y = 3, just = c("left"),
  default.units = "cm"
)

plotRanges(data = SPL1_consensus_peaks,
           params = region4,
           x = 0.25, y = 2.5, height = 3, width = 25,
           default.units = "cm", 
           linecolor = "black")

plotText(
  label = "SPL1 consensus peaks", fonsize = 10, fontcolor = "black",
  x = 1, y = 5.2, just = c("left"),
  default.units = "cm"
)

plotSignal(
  data = SPL1_1_signal,
  params = region4,
  x = 0.25, y = 6.5, height = 3, width = 25, default.units = "cm"
)

plotText(
  label = "SPL1 rep1", fonsize = 10, fontcolor = "black",
  x = 1, y = 7.7, just = c("left"),
  default.units = "cm"
)

plotSignal(
  data = SPL1_2_signal,
  params = region4,
  x = 0.25, y = 10, height = 3, width = 25, default.units = "cm"
)

plotText(
  label = "SPL1 rep2", fonsize = 10, fontcolor = "black",
  x = 1, y = 11.5, just = c("left"),
  default.units = "cm"
)

