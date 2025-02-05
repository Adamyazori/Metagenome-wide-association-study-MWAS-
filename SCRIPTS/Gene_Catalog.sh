#!/bin/bash

##############Part3 Construction of the gene catalog###########################
CleanData=./CleanData
Assembly=./Assembly
GeneCatalog=./Gene_Catalog
Scripts=~/Scripts

module purge
module load prodigal/2.60

prodigal -i final.contigs.fa -p meta -d final.contigs.genes.fna -a final.contigs.genes.faa



