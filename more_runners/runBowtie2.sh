#!/bin/bash -l
#SBATCH --mail-type=ALL

set -eux

bowtie2_sif=$1
shift

samtools_sif=$1
shift

index=$1
shift

fwd=$1
shift

rev=$1
shift

out=$1
shift

threads=$1
shift

bowtie2_options=$@


fnam=$(basename ${fwd/_1.f*q.gz/})

singularity exec $bowtie2_sif bowtie2 $bowtie2_options -x $index -1 $fwd -2 $rev --threads $threads | singularity exec $samtools_sif samtools sort -@ $threads -O bam -o $out/$fnam.sorted.bam
singularity exec $samtools_sif samtools index -c -@ $threads $out/$fnam.sorted.bam
