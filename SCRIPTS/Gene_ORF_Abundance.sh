#!/bin/bash


##############Abundance estimation###########################
GeneCatalog=./03_Gene_Catalog
Abundance=./Abundance


###Gene abundance
cd Gene
SAF=./Abundance/final_cds.fna.saf
mkdir sam sort_bam flagstat abundance
bwa mem -M -Y -t 8 -o sam/${SampleID}.sam ${GeneCatalog}/02_cdhit_cluster/PIGC90_cds.fna ${CleanData}/${SampleID}.clean_R1.fastq.gz ${CleanData}/${SampleID}.clean_R1.fastq.gz
samtools sort -@ 8 -o sort_bam/${SampleID}.sort.bam sam/${SampleID}.sam && \
     samtools flagstat -@ 8 sort_bam/${SampleID}.sort.bam > flagstat/${SampleID}.flagstat

#counts	 
featureCounts -T 8 -p -a $SAF -F SAF --tmpDir ../../${temp} -o abundance/${SampleID}.counts sort_bam/${SampleID}.sort.bam

#fpkm					
total_counts=$(cat abundance/${SampleID}.counts | grep -v -w '^Geneid' | awk '{a+=$NF}END{print a}')
awk -v "counts=$total_counts" '{if(NR>1){print $1"\t"1000000*1000*$NF/($(NF-1)*counts)}else{print $1"\t"$NF}}' abundance/${SampleID}.counts > abundance/${SampleID}.fpkm.txt 
#merge all samples
paste -d '\t' abundance/*.fpkm.txt >abundance/sample500.fpkm.txt

#return to initial directory
cd ../../
