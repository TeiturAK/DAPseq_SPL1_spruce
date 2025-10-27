#!/bin/bash -l
#SBATCH --mail-type=all

set -eux

samtools_simg=$1
shift

in=$1
shift

outdir=$1
shift

threads=$1
shift

samtools_flags=$@

fnam=$(basename ${in/.sorted.bam/})

singularity exec $samtools_simg samtools view -@ $threads -h -b $samtools_flags $in | singularity exec $samtools_simg samtools sort -@ $threads -o $outdir/$fnam.filtered.sorted.bam

singularity exec $samtools_simg samtools index -@ $threads -c $outdir/$fnam.filtered.sorted.bam

