#!/bin/bash -l

## be verbose and print
set -eux

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

deeptools_sif=$HOME/storage2/singularity/deeptools-3.5.5.sif

#in=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20.markdup/JZ25141633-SPL1_1-SPL1_1_combined_trimmomatic.filtered.markdup.sorted.bam
#out=$HOME/storage2/Sami_DAPseq/deepTools/bamCoverage_SPL1_1

in=$HOME/storage2/Sami_DAPseq/bowtie2.filtered_q20.markdup/JZ25141634-SPL1_2-SPL1_2_combined_trimmomatic.filtered.markdup.sorted.bam
out=$HOME/storage2/Sami_DAPseq/deepTools/bamCoverage_SPL1_2

## create the out dir
if [ ! -d $out ]; then
    mkdir -p $out
fi

## Run
fnam=$(basename ${in/.bam/})
sbatch -A $proj --mail-user=$mail -t 24:00:00 -e $out/$fnam.err -o $out/$fnam.out \
  -J $fnam -p batch -c 20 -n 1 ../more_runners/runBamCoverage.sh $deeptools_sif -b $in -o $out/$fnam.bw --outFileFormat bigwig \
  --numberOfProcessors 20 --normalizeUsing RPGC --binSize 200

