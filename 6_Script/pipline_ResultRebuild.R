library(tidyverse)
library(vroom)
library(openxlsx)
library(vcfR)

args <- commandArgs(T)

GeneID <- args[1]
file_vcf <- args[2]
file_phe <- args[3]
userUID <- args[4]

# GeneID <- "TraesCS1B03G1235100"
# file_vcf="data/TraesCS1B03G1235100.vcf.gz"
# file_phe="data/Example_trait_file.xlsx"
# userUID <- "20240727_test"

SGAT_OUT_dir <- paste0("out/",userUID,"/SGAT_OUT")

# get trait
df_phe <- read.xlsx(file_phe) %>% as.data.frame()
sample_list <- df_phe$ID
phe_list <- colnames(df_phe)[-1]

df_vcf <- read.vcfR(paste0("out/",userUID,"/",GeneID,".vcf.gz"))
tmp_SNP <- df_vcf@fix %>% as.data.frame()
for (i in 1:nrow(tmp_SNP)){
  tmp_SNP$eff[i] <- tmp_SNP$INFO[i] %>% str_split(";") %>% .[[1]] %>% .[20] %>% str_split("\\|") %>% .[[1]] %>% .[2]
}

for (model in c("MLM","FarmCPU")){
  print(model)
  for (phe in phe_list){
    print(phe)
    
    df_MVP_out <- vroom(paste0(
      SGAT_OUT_dir,"/",phe,".",model,".csv"
    ),show_col_types = FALSE)
    
    df_MVP_out <- df_MVP_out[,c(1,8)]
    colnames(df_MVP_out) <- c("SNP","P")
    df_MVP_out$log10P <- -log10(df_MVP_out$P)
    
    colnames(df_MVP_out) <- c("ID",paste0(phe,"_",model),paste0("log10P_",phe,"_",model))
    tmp_SNP <- left_join(tmp_SNP,df_MVP_out,by="ID")
    
  }
}

write.xlsx(tmp_SNP,str_c("out/",userUID,"/",GeneID,"_GWAS_All_Pvalue.xlsx"))
