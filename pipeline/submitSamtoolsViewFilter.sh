#!/bin/bash

## be verbose and print
set -eux

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

in=$HOME/storage2/Sami_DAPseq/bowtie2
out=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20

samtools_sif=$HOME/storage2/singularity/samtools_1.16.sif

if [ ! -d $out ]; then
  mkdir -p $out
fi

## https://broadinstitute.github.io/picard/explain-flags.html
# Run
for f in $(find $in -name "*.bam"); do
	fnam=$(basename ${f/.bam/})
	sbatch -A $proj -t 24:00:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
	-J $fnam -p batch -c 18 -n 1 ../more_runners/runSamtoolsViewFilter.sh $samtools_sif $f $out 18 -f 3 -F 12 -q 20
done
