# 使用vcf文件进行候选基因关联分析的流程
# 需要在工作目录下执行脚本

library(rMVP)
library(tidyverse)
library(openxlsx)
library(vcfR)
library(vroom)

args <- commandArgs(T)

GeneID <- args[1]
file_vcf <- args[2]
file_phe <- args[3]
userUID <- args[4]

# Example :
# GeneID <- "TraesCS1B03G1235100"
# file_vcf="data/TraesCS1B03G1235100.vcf.gz"
# file_phe="data/Example_trait_file.xlsx"
# userUID <- "20240727_test"


dir.create(paste0("out/",userUID,"/SGAT_OUT"),recursive = T)

file.copy(file_vcf,paste0("out/",userUID,"/"))

# get trait
df_phe <- read.xlsx(file_phe) %>% as.data.frame()
sample_list <- df_phe$ID
phe_list <- colnames(df_phe)[-1]

write_tsv(df_phe,file = paste0("out/",userUID,"/user_upload_trait.tsv"),col_names = T,na = "NA")


# get vcf
system(paste0("gunzip ",file_vcf))

df_vcf <- read.vcfR(str_remove(file_vcf,".gz"))
df_out <- cbind(df_vcf@fix,df_vcf@gt) %>% as_tibble()
sample_list <- colnames(df_out)[-c(1:10)]
SNP_list <- df_out$ID

# MVP data
MVP.Data(fileVCF=str_remove(file_vcf,".gz"),
         filePhe=paste0("out/",userUID,"/user_upload_trait.tsv"),
         sep.phe = "\t",
         fileKin=TRUE,
         ncpus = 1 ,
         filePC=TRUE,
         out=paste0("out/",userUID,"/SGAT_OUT/","MVP_Data")
)

# MVP Run
mvp_data_prefix <- paste0("out/",userUID,"/SGAT_OUT/","MVP_Data")
genotype <- attach.big.matrix(paste0(mvp_data_prefix,".geno.desc"))
phenotype <- read.table(paste0(mvp_data_prefix,".phe"),head=TRUE)
map <- read.table(paste0(mvp_data_prefix,".geno.map") , head = TRUE)
Kinship <- attach.big.matrix(paste0(mvp_data_prefix,".kin.desc"))

for(i in 2:ncol(phenotype)){
  imMVP <- MVP(
    phe=phenotype[, c(1, i)],
    geno=genotype,
    map=map,
    #K=Kinship,
    #CV.GLM=Covariates,
    #CV.MLM=Covariates,
    #CV.FarmCPU=Covariates,
    nPC.GLM=5,
    nPC.MLM=3,
    nPC.FarmCPU=3,
    priority="speed",
    #ncpus=10,
    vc.method="BRENT",
    maxLoop=10,
    method.bin="static",
    #permutation.threshold=TRUE,
    #permutation.rep=100,
    threshold=0.05,
    method=c("MLM","FarmCPU"),
    verbose=F,
    ncpus = 1,
    outpath = paste0("out/",userUID,"/SGAT_OUT"),
    file.output=c("pmap", "pmap.signal", "plot", "log")
  )
  gc()
}


# Result Filter
dir.create(paste0("out/",userUID,"/Summary"))
for (model in c("MLM","FarmCPU")){
  for (phe in phe_list){
    cli::cli_alert_success(str_c("--------------------------------Running :",GeneID,"\t",phe,"\t",model))
    df_mvp <- vroom(paste0("out/",userUID,"/SGAT_OUT/",phe,".",model,".csv"))
    df_p <- df_mvp[,c(2,3,8)] %>% as.data.frame() %>% drop_na()
    colnames(df_p) <- c("Chr","Pos","P")
    write.table(df_p,file = str_c("out/",userUID,"/Summary/",phe,"_",model,"_Pvalue.csv"),quote = F,row.names = F,col.names = F,sep = ",")
    
    
    system(str_c(sep = " ",
                 "LDBlockShow",
                 "-InVCF",str_remove(file_vcf,".gz"),
                 "-InGWAS",str_c("out/",userUID,"/Summary/",phe,"_",model,"_Pvalue.csv"),
                 "-OutPut",paste0("out/",userUID,"/Summary/",phe,"_",model),
                 "-Region",paste0(df_p$Chr[1],":",min(df_p$Pos)-1,"-",max(df_p$Pos)+1),
                 # "-OutPdf",
                 "-SeleVar 4 -TopSite",
                 "-NoShowLDist 5000000"
    ))
    
    system(str_c(sep = " ",
                 "ShowLDSVG",
                 "-InPreFix",paste0("out/",userUID,"/Summary/",phe,"_",model),
                 "-InGWAS",str_c("out/",userUID,"/Summary/",phe,"_",model,"_Pvalue.csv"),
                 "-OutPut",paste0("out/",userUID,"/Summary/",phe,"_",model,"_KeyPoint"),
                 "-crBegin 75,176,116 -crMiddle 33,138,140  -crEnd 53,71,108",
                 # "-OutPdf",
                 "-TopSite",
                 "-Cutline", 7,
                 "-NoShowLDist",700681000
    ))
    
  }
}


#system("bash ~/sendmsg.sh SGAT_finish!")
