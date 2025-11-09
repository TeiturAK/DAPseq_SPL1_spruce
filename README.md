## DAPseq_SPL1_spruce
### Processing and analysis of SPL1 TF in spruce

## Pipeline overview
### Quality control and read cleaning

submitFastQC.sh – Run initial quality control on raw reads.

submitMultiQC.sh – Aggregate FastQC reports for an overview of sequencing quality.

submitTrimmomatic.sh – Trim adapters and low-quality bases.

submitFastQC.sh – Re-run FastQC on trimmed reads to assess improvement.

submitMultiQC.sh – Summarize post-trimming QC results.

### Alignment and read filtering

submitBowtie2.sh – Align cleaned reads to the reference genome.

submitSamtoolsViewFilter.sh – Filter alignments (mapping quality, pairing).

submitSamtoolsMarkdup.sh – Remove duplicate reads.

### Signal visualization, peak calling, and feature intersect

submitMacs3.sh – Call peaks for each replicate.

submitBEDToolsConsensusPeaks.sh – Generate consensus peaks across replicates.

submitBEDToolsIntersect.sh – Intersect peaks with genomic features.

submitBamCoverage.sh – Generate coverage tracks (bigWig) for visualization.

### Motif Identification

submitExtractStrongestNPeaks.sh – Select the strongest N peaks for motif discovery.

submitMemeChIP.sh – Perform motif enrichment and discovery analysis.
