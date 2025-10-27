#!/bin/bash -l

set -eux

deeptools_sif=$1
shift

options=$@

singularity exec $deeptools_sif bamCoverage $options

