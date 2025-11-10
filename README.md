## DAPseq_SPL1_spruce
### Processing and analysis of SPL1 TF in spruce

## Pipeline overview
### Quality control and read cleaning

1. submitFastQC.sh – Run initial quality control on raw reads.

2. submitMultiQC.sh – Aggregate FastQC reports for an overview of sequencing quality.

3. submitTrimmomatic.sh – Trim adapters and low-quality bases.

4. submitFastQC.sh – Re-run FastQC on trimmed reads to assess improvement.

5. submitMultiQC.sh – Summarize post-trimming QC results.

### Alignment and read filtering

6. submitBowtie2.sh – Align cleaned reads to the reference genome.

7. submitSamtoolsViewFilter.sh – Filter alignments (mapping quality, pairing).

8. submitSamtoolsMarkdup.sh – Remove duplicate reads.

### Signal visualization, peak calling, and feature intersect

9. submitMacs3.sh – Call peaks for each replicate.

10. submitBEDToolsConsensusPeaks.sh – Generate consensus peaks across replicates.

11. submitBEDToolsIntersect.sh – Intersect peaks with genomic features.

12. submitBamCoverage.sh – Generate coverage tracks (bigWig) for visualization.

### Motif Identification

13. submitExtractStrongestNPeaks.sh – Select the strongest N peaks for motif discovery.

14. submitMemeChIP.sh – Perform motif enrichment and discovery analysis.
