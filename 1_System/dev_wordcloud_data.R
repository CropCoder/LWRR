# 计算生成词云图数据

df_tmp <- as.data.frame(matrix(nrow = length(search_index_GeneName),ncol = 3))
df_tmp$V1 <- search_index_GeneName
colnames(df_tmp) <- c("Gene","Freq","Num")
for (i in 1:length(search_index_GeneName)){
    tmp_gene <- df_tmp$Gene[i]
    for (k in 1:nrow(S2_QTL_freq)){
        tmp_list <- S2_QTL_freq$Gene_name_index[k] %>% str_split(";") %>% unlist()
        if (tmp_gene %in% tmp_list){
            df_tmp$Freq[i] <- S2_QTL_freq$R_Frequency[k]
            df_tmp$Num[i] <- S2_QTL_freq$Gene_Number[k]
            break
        }
    }
}

write_rds(data_home_wordcloud,"3_Data/RDataBase/data_home_wordcloud.rds")
