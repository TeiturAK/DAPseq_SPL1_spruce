#!/bin/bash -l

set -eux

sif=$1
shift

a=$1
shift

b=$1
shift

out=$1
shift

options=$@

# Get fasta
singularity exec $sif bedtools intersect $options -a $a -b $b > $out

