#!/bin/bash -l

set -eux

sif=$1
shift

narrowPeak=$1
shift

out=$1
shift

n_peaks=$1

fnam=$(basename ${narrowPeak/.narrowPeak/})

# Extract top n signalValue
sort -t$'\t' -k7,7rn $narrowPeak | head -n $n_peaks > $out/$fnam.tmp

# Sort
singularity exec $sif bedtools sort -i $out/$fnam.tmp > $out/$fnam.topSignal.narrowPeak

# narrowPeak format spec https://genome.ucsc.edu/FAQ/FAQformat.html#format12:~:text=ENCODE-,narrowPeak,-%3A%20Narrow%20(or%20Point
# Extract summits from narrowPeak and put in BED3 format
awk -F '\t' -v OFS='\t' '{print $1, $2 + int(($3-$2)/2), $2 + int(($3-$2)/2) + 1 }' $out/$fnam.topSignal.narrowPeak > $out/$fnam.topSignal.bed #Made this change because of suspected bug with MACS3 with negative summit positions

#awk -v OFS="\t" '{print $1,$2+$10,$2+$10+1}' $out/$fnam.topSignal.narrowPeak > $out/$fnam.topSignal.bed

rm $out/$fnam.tmp
