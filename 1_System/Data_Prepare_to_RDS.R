
# Sample_Info
df_s1_sample_info <- read.xlsx("3_Data/S1_Sample_info_group_trait.xlsx",sheet = 1)
df_s5_location <- read_tsv("3_Data/sample_name.tsv")
df_s5_location <- df_s5_location[,c(4,6,7)]
colnames(df_s5_location)[1] <- "RunID"
df_s1_sample_info <- left_join(df_s1_sample_info,df_s5_location,by="RunID")
write_rds(df_s1_sample_info,"3_Data/RDataBase/S1_sample_info.rds")
write.xlsx(S1_sample,"3_Data/S1_Sample_info_group_trait.xlsx")


# QTL

S1_sample <- read.xlsx("3_Data/S1_Sample_info_group_trait.xlsx",sheet = 1)
S2_QTL_freq <- read.xlsx("3_Data/S2_QTL431_Postion_Freqency.xlsx",sheet = 1)
S3_QTL_GT <- read.xlsx("3_Data/S3_QTL431_Sample_GT.xlsx",sheet = 1)
S4_GeneTPM <- read.xlsx("3_Data/S4_QTL431_Genes_TPM.xlsx",sheet = 1)

write_rds(S2_QTL_freq,"3_Data/RDataBase/S2_QTL_freq.rds")
write_rds(S3_QTL_GT,"3_Data/RDataBase/S3_QTL_GT.rds")
write_rds(S4_GeneTPM,"3_Data/RDataBase/S4_GeneTPM.rds")



