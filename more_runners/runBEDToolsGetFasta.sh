#!/bin/bash -l

set -eux

sif=$1
shift

narrowPeak=$1
shift

out=$1
shift

fasta=$1
shift

options=$@

fnam=$(basename $narrowPeak)

# Get fasta
singularity exec $sif bedtools getfasta $options -fi $fasta -bed $narrowPeak > $out/$fnam.fa

