#!/bin/bash -l
#SBATCH --mail-type=all

#module load bioinfo-tools

set -eux

samtools_simg=$1
infile=$2
outdir=$3
threads=$4

filename=$(basename ${infile/.sorted.bam/})

## from http://www.htslib.org/doc/samtools-markdup.html

singularity exec $samtools_simg samtools collate -@ $threads --verbosity 3 -o $outdir/$filename.name-sorted.bam $infile

singularity exec $samtools_simg samtools fixmate -@ $threads -m $outdir/$filename.name-sorted.bam $outdir/$filename.fixmate.bam

singularity exec $samtools_simg samtools sort -@ $threads -o $outdir/$filename.sorted.bam $outdir/$filename.fixmate.bam

singularity exec $samtools_simg samtools markdup -@ $threads -S -s -r $outdir/$filename.sorted.bam $outdir/$filename.markdup.sorted.bam

singularity exec $samtools_simg samtools index -@ $threads -c $outdir/$filename.markdup.sorted.bam

rm $outdir/$filename.name-sorted.bam $outdir/$filename.fixmate.bam $outdir/$filename.sorted.bam
