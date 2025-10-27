suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
  library(ggplot2)
  library(forcats)
})


#' Data
SPL1_intersect.df <- read.table("C:/Users/Teitur/Desktop/DAPseq_Sami/macs3.consensus_peaks.bedtools_peak_intersect_annotation/SPL1.consensus_peaks.annotation_intersect.tsv")

#' Classify intersect and remove "exon" and "gene" intersect as these are redundant
feature_from_v7 <- function(v7) {
  case_when(
    str_detect(v7, fixed("downstream_promoter10kb")) ~ "downstream_promoter10kb",
    str_detect(v7, fixed("intergenic")) ~ "intergenic",
    str_detect(v7, fixed("five_prime_UTR")) ~ "five_prime_UTR",
    str_detect(v7, fixed("three_prime_UTR")) ~ "three_prime_UTR",
    str_detect(v7, fixed("exon")) ~ "exon",
    str_detect(v7, fixed("cds")) ~ "cds",
    str_detect(v7, fixed("intron")) ~ "intron",
    str_detect(v7, fixed("promoter10kb")) ~ "promoter10kb",
    TRUE ~ "gene"
  )
}

desired_order <- c(
  "intergenic",
  "promoter10kb",
  "five_prime_UTR",
  "cds",
  "intron",
  "three_prime_UTR",
  "downstream_promoter10kb",
  "gene", # still present pre-filter so order is consistent
  "exon") # still present pre-filter so order is consistent

feature_colors <- c(
  intergenic = "#999999", # neutral gray
  promoter10kb = "#E69F00", # orange
  five_prime_UTR = "#56B4E9", # sky blue
  cds = "#009E73", # bluish green
  intron = "#F0E442", # yellow
  three_prime_UTR = "#0072B2", # blue
  downstream_promoter10kb = "#CC79A7", # reddish purple
  gene = "black",
  exon = "black")

SPL1_intersect.df <- SPL1_intersect.df %>%
  mutate(feature = factor(feature_from_v7(V7), levels = desired_order)) %>%
  filter(!feature %in% c("gene", "exon")) %>%
  droplevels()


ft_SPL1_genome_wide <- data.frame(table(SPL1_intersect.df$feature))

ggplot(ft_SPL1_genome_wide, aes(x = Var1, y = Freq, fill = Var1)) +
  geom_col(color = "black", linewidth = 0.3) +                # black outlines
  geom_text(aes(label = Freq), vjust = -0.3, size = 4) +      # counts above bars
  scale_fill_manual(values = feature_colors[levels(ft_SPL1_genome_wide$Var1)]) +
  scale_y_continuous(expand = expansion(mult = c(0.02, 0.12))) +  # room for labels
  guides(fill = "none") +
  labs(x = "Feature", y = "Count", title = "SPL1 genome wide consensus peak intersect") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))    # 45° CCW labels



# What does the peak count look like in the SPL1 GOIs?
gene_id_from_v7 <- function(v7) stringr::str_extract(v7, "(?<=ID=)[^.]+")

SPL1_intersect.df <- SPL1_intersect.df %>%
  filter(feature != "intergenic") %>%
  mutate(gene_id = gene_id_from_v7(V7)) %>%
  droplevels()

#' DAL14 PA_chr01_G000442
ft_SPL1_DAL14 <- data.frame(table(SPL1_intersect.df$feature[SPL1_intersect.df$gene_id == "PA_chr01_G000442"]))

ggplot(ft_SPL1_DAL14, aes(x = Var1, y = Freq, fill = Var1)) +
  geom_col(color = "black", linewidth = 0.3) +                # black outlines
  geom_text(aes(label = Freq), vjust = -0.3, size = 4) +      # counts above bars
  scale_fill_manual(values = feature_colors[levels(ft_SPL1_DAL14$Var1)]) +
  scale_y_continuous(expand = expansion(mult = c(0.02, 0.12))) +  # room for labels
  guides(fill = "none") +
  labs(x = "Feature", y = "Count", title = "SPL1 consensus peak intersect at DAL14") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))    # 45° CCW labels

#' DAL1 PA_chr07_G003407
ft_SPL1_DAL1 <- data.frame(table(SPL1_intersect.df$feature[SPL1_intersect.df$gene_id == "PA_chr07_G003407"]))

ggplot(ft_SPL1_DAL1, aes(x = Var1, y = Freq, fill = Var1)) +
  geom_col(color = "black", linewidth = 0.3) +                # black outlines
  geom_text(aes(label = Freq), vjust = -0.3, size = 4) +      # counts above bars
  scale_fill_manual(values = feature_colors[levels(ft_SPL1_DAL1$Var1)]) +
  scale_y_continuous(expand = expansion(mult = c(0.02, 0.12))) +  # room for labels
  guides(fill = "none") +
  labs(x = "Feature", y = "Count", title = "SPL1 consensus peak intersect at DAL1") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))    # 45° CCW labels

#' SPL1 PA_chr12_G002466
ft_SPL1_SPL1 <- data.frame(table(SPL1_intersect.df$feature[SPL1_intersect.df$gene_id == "PA_chr12_G002466"]))

ggplot(ft_SPL1_SPL1, aes(x = Var1, y = Freq, fill = Var1)) +
  geom_col(color = "black", linewidth = 0.3) +                # black outlines
  geom_text(aes(label = Freq), vjust = -0.3, size = 4) +      # counts above bars
  scale_fill_manual(values = feature_colors[levels(ft_SPL1_SPL1$Var1)]) +
  scale_y_continuous(expand = expansion(mult = c(0.02, 0.12))) +  # room for labels
  guides(fill = "none") +
  labs(x = "Feature", y = "Count", title = "SPL1 consensus peak intersect at SPL1") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))    # 45° CCW labels
