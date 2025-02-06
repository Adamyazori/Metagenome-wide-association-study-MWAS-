library(data.table)
library(dplyr)
library(stringr)
library(matrixStats)

setwd("E:/Rumen Microbiome/Raw")
raw = list.files(path = "E:/Rumen Microbiome/Raw")

presence_count = data.table()
abundance_count = data.table()
missing_data = data.table()

for(i in 1){
  data = fread(file=raw[i], header = T) %>%
    filter(length > 100)
  need_reads = data %>% 
    summarise_if(is.numeric, max) %>% 
    select_if(function(.) last(.) == 0) %>%
    colnames()
  if(length(need_reads) > 0){
    missing_data_here = cbind(raw[i], need_reads)
    missing_data = rbind(missing_data, missing_data_here)
    data = data[,(need_reads):=NULL]
  } else {
    data = data
  }
  gc()
  
  data[,3:ncol(data)] = lapply(data[,3:ncol(data)], function(x){x/sum(x)})
  
  maxes = cbind(data[,1], rowMaxs(as.matrix(data[,-c(1:2)])))
  abundance_count = cbind(abundance_count, maxes)
  rm(maxes)
  gc()
  
  presence =  rowSums(data[,-c(1,2)] != 0)
  presence = cbind(data[,1], presence)
  presence_count = cbind(presence_count, presence)
  rm(presence)
  rm(data, i, need_reads)
  gc()
}

for(i in 2:length(raw)){
  data = fread(file=raw[i], header = T) %>%
    filter(length > 100)
  need_reads = data %>% 
    summarise_if(is.numeric, max) %>% 
    select_if(function(.) last(.) == 0) %>%
    colnames()
  if(length(need_reads) > 0){
  missing_data_here = cbind(raw[i], need_reads)
  missing_data = rbind(missing_data, missing_data_here)
  data = data[,(need_reads):=NULL]
  } else {
    data = data
  }
  gc()
  
  data[,3:ncol(data)] = lapply(data[,3:ncol(data)], function(x){x/sum(x)})
  
  maxes = cbind(data[,1], rowMaxs(as.matrix(data[,-c(1:2)])))
  abundance_count = merge(abundance_count, maxes, by = "contig")
  maxes = rowMaxs(as.matrix(abundance_count[,-c(1)]))
  abundance_count = cbind(abundance_count[,1], maxes)
  rm(maxes)
  gc()
  
  
  if(sum(is.na(abundance_count[,2])) > 0){
    print(i)
  } else{
  
  presence =  rowSums(data[,-c(1,2)] != 0)
  presence = cbind(data[,1], presence)
  presence_count = merge(presence_count, presence, by = "contig")
  rm(presence)
  gc()
  
  presence_count = cbind(presence_count[,1], (presence_count[,2]+presence_count[,3]))
  gc()
  if(sum(is.na(presence_count[,2])) > 0){
    print(i)
  } else{
  
  rm(data, i, need_reads, missing_data_here)
  gc()
   }
  }
}

#write.table(abundance_count, file = "E:/Rumen Microbiome/raw_adundance_max.txt" ,row.names = F, quote = F)
#write.table(presence_count,file = "E:/Rumen Microbiome/raw_prevalence_total.txt", row.names = F, quote = F)
#write.table(missing_data,file = "E:/Rumen Microbiome/raw_missing_reads.txt", row.names = F, quote = F)

#Abundance threshold 0.01%
abundance_filter = abundance_count %>%
  filter(maxes >= 0.0001) 

#Prevalence threshold 10%
prevalence_filter = presence_count %>%
  filter(presence.x >= 75)

for(i in 1:length(raw)){
  setwd("E:/Rumen Microbiome/Raw")
  library(stringr)
  library(tidyr)
  library(dplyr)
  library(data.table)
  id = str_remove(raw[i],".tsv")
  
  data = fread(file=raw[i], header = T) %>%
    filter(length > 100) 
  need_reads = data %>% 
    summarise_if(is.numeric, max) %>% 
    select_if(function(.) last(.) == 0) %>%
    colnames()
  if(length(need_reads) > 0){
    data = data[,(need_reads):=NULL]
  } else {
    data = data
  }
  gc()
  
  data[,3:ncol(data)] = lapply(data[,3:ncol(data)], function(x){x/sum(x)})

  data = data %>%
    filter(contig %in% prevalence_filter$contig) %>%
    filter(contig %in% abundance_filter$contig)
  
  setwd("E:/Rumen Microbiome/Filtered_by_Gene")
  
  write.table(data, paste0("Filtered_", id, ".txt"), col.names = T, row.names = F, quote = F)
  
  
  rm(data, i, need_reads)
  gc()
}



