#!/bin/bash


#module load python/2.7
cd 01_CleanData # this should be the folder that has all your clean fastqs for a sample group

R1s=`ls ./*.1.fastq.gz | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`
R2s=`ls ./*.2.fastq.gz | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

module load megahit/1.2

megahit -1 $R1s -2 $R2s --min-contig-len 1000 -m 0.85 --k-min 27 --k-max 127 --k-step 10 -o ASSEMBLY -t 64 --continue -o ASSEMBLY
