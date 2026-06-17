f_chrmap <- S6_QTL_Find_envs[,c(1,3,4,5,9)]

f_chrmap$url <- str_c("/?tab=QTL&QTL_search=",f_chrmap$QTL,"#input_QTL_ID")
f_chrmap$QTL <- str_c(f_chrmap$QTL,"【Click to detail】")
f_chrmap$Find_time <- "QTL Click here"

write.table(f_chrmap,"3_Data/chromap_QTL_anno.txt",sep = "\t",col.names = F,row.names = F,quote = F)
