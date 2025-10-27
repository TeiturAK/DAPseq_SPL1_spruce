#!/bin/bash
set -eux

## variables
proj=hpc2n2025-086
mail=teitur.ahlgren.kalman@umu.se

#in=$HOME/storage2/Sami_DAPseq/raw
#out=$HOME/storage2/Sami_DAPseq/fastqc

in=$HOME/storage2/Sami_DAPseq/trimmomatic
out=$HOME/storage2/Sami_DAPseq/fastqc.trimmomatic

## create the out dir
if [ ! -d $out ]; then
    mkdir -p $out
fi

## execute
for f in $(find $in -name "*.fq.gz" -type f); do
	fnam=$(basename $f).fastQC
	sbatch -A $proj -t 12:00:00 --mail-user=$mail -e $out/$fnam.err -o $out/$fnam.out \
	-J $fnam -p batch -c 18 -n 1 ../more_runners/runFastQC.sh $out $f
done
