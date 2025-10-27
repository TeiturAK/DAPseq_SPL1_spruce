#!/bin/bash -l

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

sif=$HOME/storage2/singularity/bedtools_2.30.0.sif

# SPL1
fnam=SPL1
a=$HOME/storage2/Sami_DAPseq/macs3/SPL1_1_peaks.narrowPeak
b=$HOME/storage2/Sami_DAPseq/macs3/SPL1_2_peaks.narrowPeak
out=$HOME/storage2/Sami_DAPseq/macs3.consensus_peaks/SPL1

if [ ! -d $out ]; then
  mkdir -p $out
fi

sbatch -A $proj -t 1:00:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
  -J $fnam -p batch -c 18 -n 1 ../more_runners/runBEDToolsConsensusPeaks.sh $sif $a $b $out/$fnam.consensus_peaks.narrowPeak
