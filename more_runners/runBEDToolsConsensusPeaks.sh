#!/bin/bash -l

set -eux

sif=$1
shift

a=$1
shift

b=$1
shift

out=$1

singularity exec $sif bedtools intersect -u -a $a -b $b > $out.tmp1
singularity exec $sif bedtools intersect -u -a $a -b $b > $out.tmp2

n1=$(wc -l < $a)
n2=$(wc -l < $b)
ca=$(wc -l < $out.tmp1)
cb=$(wc -l < $out.tmp2)
cn=$((ca+cb))
consensus_pct=$(awk -v cn="$cn" -v n="$((n1+n2))" 'BEGIN{ if(n==0){print "NA"; exit} printf "%.6f", 100*cn/n }')
echo "consensus_pct=$consensus_pct" >&2

cat $out.tmp1 $out.tmp2 | singularity exec $sif bedtools sort -i - | singularity exec $sif bedtools merge -i - > $out

rm $out.tmp1
rm $out.tmp2
