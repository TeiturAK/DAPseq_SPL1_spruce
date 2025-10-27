#!/bin/bash -l
#SBATCH --mail-type=ALL

macs3_sif=$1
shift

bam=$1
shift

out=$1
shift

effective_genome_size=$1
shift

options=$@

singularity exec $macs3_sif macs3 callpeak -t $bam -g $effective_genome_size --outdir $out $options
