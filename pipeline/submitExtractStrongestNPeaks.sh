#!/bin/bash -l

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

sif=$HOME/storage2/singularity/bedtools_2.30.0.sif

in=$HOME/storage2/Sami_DAPseq/macs3
out=$HOME/storage2/Sami_DAPseq/macs3.top5000

n_peaks=5000

if [ ! -d $out ]; then
  mkdir -p $out
fi

for f in $(find $in -name "*.narrowPeak"); do
        fnam=$(basename ${f/.narrowPeak/})
        sbatch -A $proj -t 15:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
        -J $fnam -p batch -c 18 -n 1 ../more_runners/runExtractStrongestNPeaks.sh $sif $f $out $n_peaks
done
