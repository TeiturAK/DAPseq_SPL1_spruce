#!/bin/bash

## be verbose and print
set -eux

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

macs3_sif=$HOME/storage2/singularity/macs3_v3.0.0b3.sif
out=$HOME/storage2/Sami_DAPseq/Sami_DAPseq/macs3

#fnam=SPL1_1
#TF=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20.markdup/JZ25141633-SPL1_1-SPL1_1_combined_trimmomatic.filtered.markdup.sorted.bam
#control=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20.markdup/JZ25141639-SPL1_Input-SPL1_Input_combined_trimmomatic.filtered.markdup.sorted.bam

fnam=SPL1_2
TF=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20.markdup/JZ25141634-SPL1_2-SPL1_2_combined_trimmomatic.filtered.markdup.sorted.bam
control=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20.markdup/JZ25141639-SPL1_Input-SPL1_Input_combined_trimmomatic.filtered.markdup.sorted.bam

effective_genome_size=14150000000

if [ ! -d $out ]; then
  mkdir -p $out
fi

sbatch -A $proj -t 03:00:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
  -J $fnam -p batch -c 18 -n 1 ../more_runners/runMacs3.sh $macs3_sif $TF $out $effective_genome_size --name $fnam --keep-dup all -f BAMPE -c $control
