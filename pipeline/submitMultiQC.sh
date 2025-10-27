#!/bin/bash
set -eux

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

#in=$HOME/storage2/Sami_DAPseq/fastqc
#out=$HOME/storage2/Sami_DAPseq/multiqc

in=$HOME/storage2/Sami_DAPseq/fastqc.trimmomatic
out=$HOME/storage2/Sami_DAPseq/multiqc.trimmomatic

## create the out dir
if [ ! -d $out ]; then
    mkdir -p $out
fi

## execute
fnam=$(basename $in).multiQC
sbatch -A $proj -t 12:00:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
  -J $fnam -p batch -c 18 -n 1 ../more_runners/runMultiQC.sh $in $out
