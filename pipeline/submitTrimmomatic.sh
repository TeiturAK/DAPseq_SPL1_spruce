#!/bin/bash

## be verbose and print
set -ex

## variables
proj=hpc2n2025-086

mail=teitur.ahlgren.kalman@umu.se

trimmomatic_sif=$HOME/storage2/singularity/trimmomatic_0.39.sif

in=$HOME/storage2/Sami_DAPseq/raw
out=$HOME/storage2/Sami_DAPseq/trimmomatic

adpt=$HOME/storage2/Sami_DAPseq/TruSeq3-PE-2.fa
trim="SLIDINGWINDOW:5:20 MINLEN:50"

## create the out dir
if [ ! -d $out ]; then
    mkdir -p $out
fi

#Usage:
#    Paired end: $0 [options] <singularity file> <adapter file> <fwd fastq file> <rev fastq file> <output dir> [trimmomatic trimming options]
#    Single end: $0 -s <singularity file> <adapter file> <fastq file> <output dir> [trimmomatic trimming options]

## run
for f in $(find $in -type f -name "*_R1.fastq.gz"); do
  fnam=$(basename ${f/_R1_001.fastq.gz/})
  sbatch -A $proj --mail-user=$mail -t 40:00:00 -e $out/$fnam.err -o $out/$fnam.out \
  -J $fnam -p batch -c 18 -n 1 ../UPSCb-common/pipeline/runTrimmomatic.sh -t $trimmomatic_sif $adpt $f ${f/_R1.fastq.gz/_R2.fastq.gz} $out $trim
done

