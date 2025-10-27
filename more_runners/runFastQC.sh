#!/bin/bash -l

## stop on error but be verbose
set -ex

ml FastQC/0.12.1-Java-11

out=$1
shift

file=$1
shift

options=$@

## start
fastqc $options --noextract --outdir $out $file
