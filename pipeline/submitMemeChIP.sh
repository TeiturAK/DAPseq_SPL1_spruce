#!/bin/bash

## be verbose and print
set -eux

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

bedtools_sif=$HOME/storage2/singularity/bedtools_2.30.0.sif
MEME_sif=$HOME/storage2/singularity/memesuite_5.5.2.sif

## Spruce
in=$HOME/storage2/Sami_DAPseq/macs3.top5000
out=$HOME/storage2/Sami_DAPseq/MEME

genome=$HOME/storage2/fasta/pabies-2.0_chromosomes_and_unplaced.fa.fai
genomefasta=$HOME/storage2/fasta/pabies-2.0_chromosomes_and_unplaced.fa

databasepath=$HOME/storage2/PlantTFDB/Ath_TF_binding_motifs.meme

## create the out dir
if [ ! -d $out ]; then
    mkdir -p $out
fi

## execute
for f in $(find $in -name "*.bed"); do
    fnam=$(basename ${f/.topSignal.bed/})
    sbatch -A $proj -t 06:00:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
    -J $fnam -p batch -c 18 -n 1 ../more_runners/runMemeChIP.sh $bedtools_sif $MEME_sif $f $genome $genomefasta $databasepath $out -meme-mod anr # arguments added after $out get passed as options to MEME-ChIP
done
