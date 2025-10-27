#!/bin/bash

set -eux

ml GCC/13.2.0 OpenMPI/4.1.6 MultiQC/1.22.3

in=$1
shift

out=$1
shift

options=$@

## start
multiqc $options -o $out $in
