#!/bin/bash

## be verbose and print
set -eux

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

bowtie2_sif=$HOME/storage2/singularity/bowtie2_2.4.5.sif
samtools_sif=$HOME/storage2/singularity/samtools_1.16.sif

in=$HOME/storage2/Sami_DAPseq/trimmomatic
out=$HOME/storage2/Sami_DAPseq/bowtie2

index=$HOME/storage2/fasta/bowtie2/Picab02_chromosomes_and_unplaced

## create the out dir
if [ ! -d $out ]; then
    mkdir -p $out
fi

for f in $(find $in -type f -name "*_trimmomatic_1.f*q.gz"); do
  fnam=$(basename ${f/_1.f*q.gz/})
  sbatch -A $proj --mail-user=$mail -t 2-00:00:00 -e $out/$fnam.err -o $out/$fnam.out \
  -J $fnam -p batch -c 18 -n 1 ../more_runners/runBowtie2.sh $bowtie2_sif $samtools_sif $index $f ${f/_1.f*q.gz/_2.f*q.gz} $out 18 \
  --very-sensitive --end-to-end --dovetail --minins 50 --maxins 1000
done

