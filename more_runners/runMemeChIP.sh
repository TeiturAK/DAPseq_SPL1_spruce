#!/bin/bash -l

set -eux

bedtools_sif=$1
shift

MEME_sif=$1
shift

bed=$1
shift

genome=$1
shift

genomefasta=$1
shift

motif_DB=$1
shift

out=$1
shift

MEME_options=$@

fnam=$(basename ${bed/.bed/})

singularity exec $bedtools_sif bedtools slop -b 250 -i $bed -g $genome > $out/$fnam.summits.slop_250bp.bed

singularity exec $bedtools_sif bedtools getfasta -fi $genomefasta -bed $out/$fnam.summits.slop_250bp.bed > $out/$fnam.summits.slop_250bp.fasta

singularity exec $MEME_sif meme-chip -db $motif_DB -oc $out/$fnam $MEME_options $out/$fnam.summits.slop_250bp.fasta
