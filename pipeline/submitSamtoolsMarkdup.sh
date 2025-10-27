#!/bin/bash

## be verbose and print
set -eux

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

in=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20
out=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20.markdup

samtools_sif=$HOME/storage2/singularity/samtools_1.16.sif

if [ ! -d $out ]; then
  mkdir -p $out
fi

for f in $(find $in -name "*.bam"); do
	fnam=$(basename $f).samtools-markdup
	sbatch -A $proj -t 24:00:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
	-J $fnam -p batch -c 18 -n 1 ../more_runners/runSamtoolsMarkdup.sh $samtools_sif $f $out 18
done
