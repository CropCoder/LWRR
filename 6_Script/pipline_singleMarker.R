# 单标记分析流程
library(tidyverse)

args <- commandArgs(T)

GeneID <- args[1]
file_vcf <- args[2]
file_phe <- args[3]
userUID <- args[4]

# Example :
# GeneID <- "TraesCS1B03G1235100"
# file_phe="data/Example_trait_file.xlsx"
# userUID <- "20240727_test"


df_phe <- read_tsv(paste0("out/",userUID,"/user_upload_trait.tsv"))
tran_df <- t(df_phe) %>% as.data.frame()
tran_df <- cbind(rownames(tran_df),tran_df)

write_tsv(tran_df,paste0("out/",userUID,"/single_mark_translate_trait.tsv"),col_names = F)


system(str_c(sep=" ",
  "python function/single.marker.analysis.py",
  "--phe",paste0("out/",userUID,"/single_mark_translate_trait.tsv"),
  "--vcf",paste0("out/",userUID,"/",GeneID,".vcf.gz"),
  "--out",paste0("out/",userUID,"/Single_Marker_Result.txt")
))