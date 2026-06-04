#' ---
#' title: "DAP-seq SPL1 TF peak annotation overview"
#' author: "Teitur Ahlgren Kalman"
#' date: "`r Sys.Date()`"
#' output:
#'   html_document:
#'     toc: true
#'     number_sections: true
#'     code_folding: hide
#' ---
#'
#' # Description
#'
#' Overview of annotation features intersecting DAP-seq SPL1 TF consensus peaks.
#' The analysis classifies each overlap by feature type, extracts gene IDs, and
#' summarizes both total peak feature overlaps and unique gene feature overlaps.
#' It also summarizes selected promoter region overlaps, defined here as peaks
#' overlapping the 5 kb upstream TSS region or 5' UTR. I also explore the 
#' count of peak overlap in the 5-10kb region upstream and first intron.  
#' 
#' I also test promoter peak overlap against the DE gene set in three ways: 
#' whether SPL1 peaks overlap positive DE genes more often than negative DE genes,
#' whether SPL1 peaks overlap negative DE genes more often than positive DE
#' genes, and whether SPL1 peaks overlap DE genes as a group more than expected
#' from the expressed gene background.

# ----

#' # Libraries and functions
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(here)
  library(stringr)
  library(ggplot2)
  library(openxlsx)
})

remove_redundant_annotation_hits <- function(annotation_table) {
  annotation_table %>%
    mutate(
      is_intergenic = annotation == ".",
      is_whole_gene = str_detect(
        annotation,
        "^ID=[^;.]+_[Gg][0-9]+$"
      ),
      is_parent_mrna = str_detect(
        annotation,
        "^ID=[^;]+\\.mRNA\\.[^.;]+;Parent=[^;]+$"
      )
    ) %>%
    filter(
      is_intergenic | (!is_whole_gene & !is_parent_mrna)
    ) %>%
    select(-is_intergenic, -is_whole_gene, -is_parent_mrna)
}

add_annotation_features <- function(annotation_table) {
  annotation_table %>%
    mutate(
      peak_id = paste(peak_chr, peak_start, peak_end, sep = ":"),
      feature_type = case_when(
        annotation == "." ~ "intergenic",
        str_detect(annotation, regex("\\.promoter5kb", ignore_case = TRUE)) ~ "upstream TSS 5kb",
        str_detect(annotation, regex("\\.upstream_TSS_5to10kb", ignore_case = TRUE)) ~ "upstream TSS 5-10kb",
        str_detect(annotation, regex("\\.downstream_promoter5kb", ignore_case = TRUE)) ~ "downstream TES 5kb",
        str_detect(annotation, regex("\\.downstream_TES_5to10kb", ignore_case = TRUE)) ~ "downstream TES 5-10kb",
        str_detect(annotation, regex("cds", ignore_case = TRUE)) ~ "cds",
        str_detect(annotation, regex("\\.intron\\.1(;|$)", ignore_case = TRUE)) ~ "first intron",
        str_detect(annotation, regex("intron", ignore_case = TRUE)) ~ "other intron",
        str_detect(annotation, regex("five_prime_UTR", ignore_case = TRUE)) ~ "5' UTR",
        str_detect(annotation, regex("three_prime_UTR", ignore_case = TRUE)) ~ "3' UTR",
        TRUE ~ NA_character_
      ),
      gene_id = case_when(
        annotation == "." ~ NA_character_,
        TRUE ~ str_match(annotation, "^ID=([^.;]+_[Gg][0-9]+)")[, 2]
      )
    ) %>%
    filter(!is.na(feature_type)) %>%
    select(
      peak_id,
      peak_chr,
      peak_start,
      peak_end,
      feature_chr,
      feature_start,
      feature_end,
      annotation,
      feature_type,
      gene_id,
      score,
      strand,
      overlap_bp
    )
}

make_feature_count_table <- function(annotation_table) {
  annotation_table %>%
    count(feature_type, name = "count") %>%
    mutate(
      feature_type = factor(
        feature_type,
        levels = c(
          "upstream TSS 5-10kb",
          "upstream TSS 5kb",
          "5' UTR",
          "cds",
          "first intron",
          "other intron",
          "3' UTR",
          "downstream TES 5kb",
          "downstream TES 5-10kb",
          "intergenic"
        )
      )
    ) %>%
    arrange(feature_type)
}

make_unique_feature_count_table <- function(annotation_table) {
  annotation_table %>%
    filter(feature_type != "intergenic") %>%
    filter(!is.na(gene_id)) %>%
    distinct(gene_id, feature_type) %>%
    count(feature_type, name = "count") %>%
    mutate(
      feature_type = factor(
        feature_type,
        levels = c(
          "upstream TSS 5-10kb",
          "upstream TSS 5kb",
          "5' UTR",
          "cds",
          "first intron",
          "other intron",
          "3' UTR",
          "downstream TES 5kb",
          "downstream TES 5-10kb"
        )
      )
    ) %>%
    arrange(feature_type)
}

make_feature_count_plot <- function(feature_count_table, plot_title) {
  ggplot(feature_count_table, aes(x = feature_type, y = count)) +
    geom_col() +
    geom_text(
      aes(label = count),
      vjust = -0.3,
      size = 4
    ) +
    scale_y_continuous(
      expand = expansion(mult = c(0, 0.15))
    ) +
    labs(
      title = plot_title,
      x = NULL,
      y = "Count"
    ) +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
}

make_selected_feature_union_table <- function(annotation_table) {
  feature_combinations <- list(
    "upstream TSS 5-10kb + upstream TSS 5kb\n+ 5' UTR + first intron" =
      c("upstream TSS 5-10kb", "upstream TSS 5kb", "5' UTR", "first intron"),
    
    "upstream TSS 5-10kb + upstream TSS 5kb\n+ 5' UTR" =
      c("upstream TSS 5-10kb", "upstream TSS 5kb", "5' UTR"),
    
    "upstream TSS 5kb + 5' UTR" =
      c("upstream TSS 5kb", "5' UTR"),
    
    "5' UTR + first intron" =
      c("5' UTR", "first intron")
  )
  
  gene_feature_table <- annotation_table %>%
    filter(feature_type != "intergenic") %>%
    filter(!is.na(gene_id)) %>%
    distinct(gene_id, feature_type)
  
  bind_rows(
    lapply(names(feature_combinations), function(combination_name) {
      selected_features <- feature_combinations[[combination_name]]
      
      gene_feature_table %>%
        filter(feature_type %in% selected_features) %>%
        summarise(
          feature_combination = combination_name,
          gene_count = n_distinct(gene_id),
          .groups = "drop"
        )
    })
  ) %>%
    mutate(
      feature_combination = factor(
        feature_combination,
        levels = names(feature_combinations)
      )
    )
}

make_selected_feature_union_plot <- function(feature_union_table, plot_title) {
  ggplot(feature_union_table, aes(x = feature_combination, y = gene_count)) +
    geom_col() +
    geom_text(
      aes(label = gene_count),
      vjust = -0.3,
      size = 4
    ) +
    scale_y_continuous(
      expand = expansion(mult = c(0, 0.15))
    ) +
    labs(
      title = plot_title,
      x = NULL,
      y = "Unique genes"
    ) +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
}

#' # Data

annotation_intersect_file <- here("data/SPL1.consensus_peaks.annotation_intersect.tsv")

de_file <- here("data/TableS6_PsSPL1_DE_with_v2_ids.xlsx")

gene_universe_file <- here("data/genes_expressed_in_lateral_organs_expAbove0_with_v2_ids.xlsx")

tf_name <- str_remove(
  basename(annotation_intersect_file),
  "\\.consensus_peaks\\.annotation_intersect\\.tsv$"
)

annotation_intersect <- read_tsv(
  annotation_intersect_file,
  col_names = c(
    "peak_chr",
    "peak_start",
    "peak_end",
    "feature_chr",
    "feature_start",
    "feature_end",
    "annotation",
    "score",
    "strand",
    "overlap_bp"
  ),
  show_col_types = FALSE
)

de_table <- read.xlsx(de_file) %>%
  mutate(
    gene_id = str_remove(v2_gene_id, "\\.mRNA.*")
  )

gene_universe <- read.xlsx(gene_universe_file) %>%
  mutate(
    gene_id = str_remove(v2_gene_id, "\\.mRNA.*")
  )

#' # Analysis

clean_annotation_intersect <- annotation_intersect %>%
  remove_redundant_annotation_hits() %>%
  add_annotation_features()

feature_count_table <- make_feature_count_table(clean_annotation_intersect)

unique_feature_count_table <- make_unique_feature_count_table(clean_annotation_intersect)

selected_feature_union_table <- make_selected_feature_union_table(
  clean_annotation_intersect
)

#' Selected peak genes

#' Select genes with a peak in the region upstream TSS 5kb or 5' UTR for significance testing 
#' of overlap with DE genes.
selected_peak_gene_features <- clean_annotation_intersect %>%
  filter(feature_type %in% c("upstream TSS 5kb", "5' UTR")) %>%
  filter(!is.na(gene_id)) %>%
  distinct(gene_id, feature_type) %>%
  group_by(gene_id) %>%
  summarise(
    has_upstream_tss_5kb_peak = any(feature_type == "upstream TSS 5kb"),
    has_5utr_peak = any(feature_type == "5' UTR"),
    selected_peak_feature = case_when(
      has_upstream_tss_5kb_peak & has_5utr_peak ~ "upstream TSS 5kb + 5' UTR",
      has_upstream_tss_5kb_peak ~ "upstream TSS 5kb",
      has_5utr_peak ~ "5' UTR"
    ),
    .groups = "drop"
  )

selected_peak_genes <- selected_peak_gene_features %>%
  distinct(gene_id)

#' Positive and negative genes in DE set

de_genes <- de_table %>%
  filter(!is.na(gene_id)) %>%
  distinct(gene_id)

positive_de_genes <- de_table %>%
  filter(Avg..log2FC > 0) %>%
  filter(!is.na(gene_id)) %>%
  distinct(gene_id)

negative_de_genes <- de_table %>%
  filter(Avg..log2FC < 0) %>%
  filter(!is.na(gene_id)) %>%
  distinct(gene_id)

#' Fisher tests within DE genes

de_peak_table <- de_genes %>%
  left_join(
    selected_peak_gene_features,
    by = "gene_id"
  ) %>%
  mutate(
    has_upstream_tss_5kb_peak = if_else(
      is.na(has_upstream_tss_5kb_peak),
      FALSE,
      has_upstream_tss_5kb_peak
    ),
    has_5utr_peak = if_else(
      is.na(has_5utr_peak),
      FALSE,
      has_5utr_peak
    ),
    selected_peak_feature = if_else(
      is.na(selected_peak_feature),
      "no selected peak",
      selected_peak_feature
    ),
    has_selected_peak = selected_peak_feature != "no selected peak",
    is_positive_de = gene_id %in% positive_de_genes$gene_id,
    is_negative_de = gene_id %in% negative_de_genes$gene_id
  )

positive_de_enrichment_matrix <- table(
  selected_peak_gene = factor(
    de_peak_table$has_selected_peak,
    levels = c(TRUE, FALSE)
  ),
  positive_de = factor(
    de_peak_table$is_positive_de,
    levels = c(TRUE, FALSE)
  )
)

positive_de_enrichment_test <- fisher.test(
  positive_de_enrichment_matrix,
  alternative = "greater"
)

positive_de_enrichment_summary <- data.frame(
  test = "positive DE genes enriched for SPL1 peaks within DE genes",
  background = "all genes in DE sheet",
  total_background_genes = nrow(de_peak_table),
  selected_peak_genes = sum(de_peak_table$has_selected_peak),
  positive_de_genes = sum(de_peak_table$is_positive_de),
  selected_positive_de_genes = sum(
    de_peak_table$has_selected_peak &
      de_peak_table$is_positive_de
  ),
  odds_ratio = unname(positive_de_enrichment_test$estimate),
  p_value = positive_de_enrichment_test$p.value
)

negative_de_enrichment_matrix <- table(
  selected_peak_gene = factor(
    de_peak_table$has_selected_peak,
    levels = c(TRUE, FALSE)
  ),
  negative_de = factor(
    de_peak_table$is_negative_de,
    levels = c(TRUE, FALSE)
  )
)

negative_de_enrichment_test <- fisher.test(
  negative_de_enrichment_matrix,
  alternative = "greater"
)

negative_de_enrichment_summary <- data.frame(
  test = "negative DE genes enriched for SPL1 peaks within DE genes",
  background = "all genes in DE sheet",
  total_background_genes = nrow(de_peak_table),
  selected_peak_genes = sum(de_peak_table$has_selected_peak),
  negative_de_genes = sum(de_peak_table$is_negative_de),
  selected_negative_de_genes = sum(
    de_peak_table$has_selected_peak &
      de_peak_table$is_negative_de
  ),
  odds_ratio = unname(negative_de_enrichment_test$estimate),
  p_value = negative_de_enrichment_test$p.value
)

#' Fisher test against expressed-gene background

expressed_gene_peak_table <- gene_universe %>%
  filter(!is.na(gene_id)) %>%
  distinct(gene_id) %>%
  mutate(
    has_selected_peak = gene_id %in% selected_peak_genes$gene_id,
    is_de = gene_id %in% de_genes$gene_id
  )

de_expressed_enrichment_matrix <- table(
  selected_peak_gene = factor(
    expressed_gene_peak_table$has_selected_peak,
    levels = c(TRUE, FALSE)
  ),
  de_gene = factor(
    expressed_gene_peak_table$is_de,
    levels = c(TRUE, FALSE)
  )
)

de_expressed_enrichment_test <- fisher.test(
  de_expressed_enrichment_matrix,
  alternative = "greater"
)

de_expressed_enrichment_summary <- data.frame(
  test = "DE genes enriched for SPL1 peaks against expressed-gene background",
  background = "expressed genes",
  total_background_genes = nrow(expressed_gene_peak_table),
  selected_peak_genes = sum(expressed_gene_peak_table$has_selected_peak),
  de_genes = sum(expressed_gene_peak_table$is_de),
  selected_de_genes = sum(
    expressed_gene_peak_table$has_selected_peak &
      expressed_gene_peak_table$is_de
  ),
  odds_ratio = unname(de_expressed_enrichment_test$estimate),
  p_value = de_expressed_enrichment_test$p.value
)

#' # Plots

feature_count_plot <- make_feature_count_plot(
  feature_count_table = feature_count_table,
  plot_title = paste0(tf_name, " peak annotation overlaps")
)

unique_feature_count_plot <- make_feature_count_plot(
  feature_count_table = unique_feature_count_table,
  plot_title = paste0(tf_name, " unique gene-feature annotation overlaps")
)

selected_feature_union_plot <- make_selected_feature_union_plot(
  feature_union_table = selected_feature_union_table,
  plot_title = paste0(tf_name, " unique genes in selected annotation regions")
)

#' # Tables and plots

#' ## Clean annotation table
clean_annotation_intersect

#' ## Total peak-feature overlap counts
feature_count_table

#' ## Unique gene-feature overlap counts
unique_feature_count_table

#' ## Unique genes in selected promoter-region combinations
selected_feature_union_table

#' ## Total peak-feature overlap plot
feature_count_plot

#' ## Unique gene-feature overlap plot
unique_feature_count_plot

#' ## Unique genes in selected promoter-region combinations plot
selected_feature_union_plot

#' ## DE-only test: positive DE genes and SPL1 peak overlap
positive_de_enrichment_matrix
positive_de_enrichment_test
positive_de_enrichment_summary

#' ## DE-only test: negative DE genes and SPL1 peak overlap
negative_de_enrichment_matrix
negative_de_enrichment_test
negative_de_enrichment_summary

#' ## Expressed-gene background test: DE genes and SPL1 peak overlap
de_expressed_enrichment_matrix
de_expressed_enrichment_test
de_expressed_enrichment_summary

#' # Write to file

#' Selected promoter peak genes including 5-10 kb upstream TSS for DE output table for 
#' further analysis not done in significance testing of overlap with DE genes.
de_output_peak_gene_features <- clean_annotation_intersect %>%
  filter(feature_type %in% c("upstream TSS 5kb", "upstream TSS 5-10kb", "5' UTR")) %>%
  filter(!is.na(gene_id)) %>%
  distinct(gene_id, feature_type) %>%
  group_by(gene_id) %>%
  summarise(
    has_upstream_tss_5kb_peak = any(feature_type == "upstream TSS 5kb"),
    has_upstream_tss_5to10kb_peak = any(feature_type == "upstream TSS 5-10kb"),
    has_5utr_peak = any(feature_type == "5' UTR"),
    selected_peak_feature = paste(
      c(
        if (any(feature_type == "upstream TSS 5kb")) "upstream TSS 5kb",
        if (any(feature_type == "upstream TSS 5-10kb")) "upstream TSS 5-10kb",
        if (any(feature_type == "5' UTR")) "5' UTR"
      ),
      collapse = " + "
    ),
    .groups = "drop"
  )

positive_de_genes_with_selected_peak_ids <- de_table %>%
  filter(Avg..log2FC > 0) %>%
  filter(!is.na(gene_id)) %>%
  inner_join(
    de_output_peak_gene_features,
    by = "gene_id"
  ) %>%
  select(
    Gene.ID,
    gene_id,
    Avg..log2FC,
    has_upstream_tss_5to10kb_peak,
    has_upstream_tss_5kb_peak,
    has_5utr_peak
  ) %>%
  arrange(desc(Avg..log2FC))

negative_de_genes_with_selected_peak_ids <- de_table %>%
  filter(Avg..log2FC < 0) %>%
  filter(!is.na(gene_id)) %>%
  inner_join(
    de_output_peak_gene_features,
    by = "gene_id"
  ) %>%
  select(
    Gene.ID,
    gene_id,
    Avg..log2FC,
    has_upstream_tss_5to10kb_peak,
    has_upstream_tss_5kb_peak,
    has_5utr_peak
  ) %>%
  arrange(Avg..log2FC)

write.table(
  positive_de_genes_with_selected_peak_ids,
  file = here("/mnt/picea/home/tkalman/SPL1_positive_de_genes_with_peak_annotation.tsv"),
  quote = FALSE,
  col.names = c("V1_ID", "V2_ID", "Avg..log2FC", "has_upstream_tss_5to10kb_peak", "has_upstream_tss_5kb_peak", "has_5utr_peak"),
  row.names = FALSE,
  sep = "\t"
)

write.table(
  negative_de_genes_with_selected_peak_ids,
  file = "/mnt/picea/home/tkalman/SPL1_negative_de_genes_with_peak_annotation.tsv",
  quote = FALSE,
  col.names = c("V1_ID", "V2_ID", "Avg..log2FC", "has_upstream_tss_5to10kb_peak", "has_upstream_tss_5kb_peak", "has_5utr_peak"),
  row.names = FALSE,
  sep = "\t"
)