## DAPseq_SPL1_spruce
### Processing and analysis of SPL1 TF in spruce

## Pipeline overview
### Quality control and read Cleaning
submitFastQC.sh – Run initial quality control on raw reads.

submitMultiQC.sh – Aggregate FastQC reports for an overview of sequencing quality.

submitTrimmomatic.sh – Trim adapters and low-quality bases.

submitFastQC.sh – Re-run FastQC on trimmed reads to assess improvement.

submitMultiQC.sh – Summarize post-trimming QC results.

