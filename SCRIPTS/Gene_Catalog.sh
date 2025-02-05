#!/bin/bash

##############Part3 Construction of the gene catalog###########################
CleanData=./01_CleanData
Assembly=./02_Assembly
GeneCatalog=./03_Gene_Catalog
Scripts=~/Scripts

module purge
module load prodigal/2.60

prodigal -i final.contigs.fa -p meta -d final.contigs.genes.fna -a final.contigs.genes.faa



