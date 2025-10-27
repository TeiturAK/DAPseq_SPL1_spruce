#!/bin/bash -l

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

sif=$HOME/storage2/singularity/bedtools_2.30.0.sif

in=$HOME/storage2/Sami_DAPseq/macs3.consensus_peaks
out=$HOME/storage2/Sami_DAPseq/macs3.consensus_peaks.bedtools_peak_intersect_annotation

annotation=$HOME/storage2/Pabies_annotation/Picab02_230926_at01_longest_no_TE_sorted.only_PASA_PASN.gene_annotation_with_10kb_upstream_TSS_and_10kb_downstream_TES_and_intergenic_space.bed

if [ ! -d $out ]; then
  mkdir -p $out
fi

for f in $(find $in -name "*.narrowPeak"); do
        fnam=$(basename ${f/.narrowPeak/})
        sbatch -A $proj -t 1:00:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
        -J $fnam -p batch -c 18 -n 1 ../more_runners/runBEDToolsIntersect.sh $sif $f $annotation $out/$fnam.annotation_intersect.tsv -wo
done
