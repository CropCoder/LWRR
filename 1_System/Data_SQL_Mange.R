library(RSQLite)

db <- dbConnect(drv = SQLite(),dbname="SQL_DataBase.db")

df_year <- read.csv("3_Data/TMP_Dalte/SampleInfo_2232_样品信息表.csv")
df_year <- df_year[which(df_year$ID %in% S1_sample$RunID),c(2,6,10,11)]
colnames(df_year)[1] <- "RunID"
S1_sample <- left_join(S1_sample,df_year,by="RunID")
colnames(S1_sample)[50] <- "Year_Group"
colnames(S1_sample)[10] <- "Year"
dbWriteTable(db,"S1SampleInfo",S1_sample)
dbWriteTable(db,"S2QTLfreq",S2_QTL_freq)
dbWriteTable(db,"S3QTLgt",S3_QTL_GT)
dbWriteTable(db,"S4GeneTPM",S4_GeneTPM)
dbWriteTable(db,"S6QTLregionEnv",S6_QTL_Find_envs)


df_QTL_Yr <- read.xlsx("3_Data/S2_QTL431_Postion_Freqency.xlsx",sheet = 2) %>% filter(!is.na(Text))
dbWriteTable(db,"YrKnownGene",df_QTL_Yr)


library(vroom)

mydf <- read.xlsx("../NG文章-重要数据与信息/admixture/data20240824.csv.xlsx")
mydf <- mydf[which(mydf$ID %in% S1_sample$RunID),]
dbWriteTable(db,"PopAdmixture",mydf)

df_pca <- S8_PCA_df[which(S8_PCA_df$id %in% S1_sample$RunID),]
df_pca <- df_pca[,-1]
colnames(df_pca)[1] <- "ID"
dbWriteTable(db,"PopPCA",df_pca)

# Fst Test
myfst <- vroom("../NG文章-重要数据与信息/Fst/Fst_5Group_Plot_K9_selected_region_top0.05.txt")
myfst$type <- "Test"
colnames(myfst) <- c("chr","start","end","fst","type")
dbWriteTable(db,"PopFst",myfst)

# Pi
mypi <- vroom("../NG文章-重要数据与信息/pi/data/pi_group_k3/group_3_out_K1_Chr1A.windowed.pi")
mypi$type <- "Test_chr1A"
colnames(mypi) <- c("chr","start","end","numvars","pi","type")
dbWriteTable(db,"PopPi",mypi)

# dbGetQuery(db,"SELECT fst FROM PopFst WHERE start == 34500001")

dbDisconnect(db)


# Pi ----
df <- as.data.frame(matrix(nrow = 0,ncol = 5))
for (i in str_c("Chr",chr_convert$new)){
    df_pi <- vroom(str_c("3_Data/PopPi/",i,"_all_pi.windowed.pi"))
    df <- rbind(df,df_pi)
}

colnames(df) <- c("Chr","Start","End","NumVars","Pi")
dbWriteTable(db,"PopAllPi",df)

df_gene <- vroom("3_Data/CS21_Ref/GeneIDconvert_Taes3G_2G_1G_geneID_list.txt",
                 col_names = c("CS01G","CS02G","CS03G")) %>% as.data.frame()
dbWriteTable(db,"RefCSGeneIDConvert",df_gene)

df_ann <- vroom("3_Data/CS21_Ref/iwgsc_refseqv2.1_functional_annotation.csv",
                col_names = c("GeneID","DB","Domain","NumberIndex","FunctionLabel")) %>% as.data.frame()
df_ann <- df_ann[-1,]
dbWriteTable(db,"RefCSGeneAnnotation",df_ann)

df_gff <- vroom("3_Data/CS21_Ref/iwgsc_refseqv2.1_assembly_HCLC.sort.gff3.gz",
                col_names = c("Chr","Version","Type","Start","End","Score","SeqUP","CDS","Info"))
dbWriteTable(db,"RefCSGeneGFF",df_gff)

df_genePOS <- vroom("3_Data/CS21_Ref/wheat_3G_all_gene_position_description.txt") %>% as.data.frame()
dbWriteTable(db,"RefCSGenePostion",df_genePOS)


df_fst <- vroom("3_Data/TMP_Dalte/RSFst_1Mb_100K.windowed.weir.fst")
dbWriteTable(db,"PopFstRS",df_fst)


# 添加Pi
pop_Pi <- vroom("3_Data/LWRR_Pi_21Chr_BG_LC.csv")
dbWriteTable(db,"PopBGPi",pop_Pi)

# 添加Fst
pop_fst <- vroom("3_Data/LWRR_Fst_21Chr_BG_LC.csv")
colnames(pop_fst)[5:9] <- c("BG1RvsLC","BG2RvsLC","BG3RvsLC","BG4RvsLC","NLCRvsLC")
dbWriteTable(db,"PopBGFst",pop_fst)

# 添加tajmd
pop_tajimd <- vroom("3_Data/LWRR_TajimaD_21Chr_BG_LC.csv") %>% drop_na()
dbWriteTable(db,"PopBGtajimD",pop_tajimd)


# 增加QTLdb
MQTLDB <- read.xlsx("3_Data/QTL/1-QTLdb-1126MQTL.xlsx")
MQTLDB$StartV1 <- as.numeric(MQTLDB$StartV1)
MQTLDB$EndV1 <- as.numeric(MQTLDB$EndV1)
MQTLDB$StartV2 <- as.numeric(MQTLDB$StartV2)
MQTLDB$EndV2 <- as.numeric(MQTLDB$EndV2)
MQTLDB$PosV1 <- as.numeric(MQTLDB$PosV1)
MQTLDB$Size <- as.numeric(MQTLDB$Size)
dbWriteTable(db,"QTLDB1125",MQTLDB)

# df_QHR <- read.xlsx("3_Data/QTL/2-QHRdb-85.xlsx")
# dbWriteTable(db,"QTLQHR",df_QHR)

df_LDB <- read.xlsx("3_Data/QTL/3-LDblockDB.xlsx")
dbWriteTable(db,"QTLblockLD",df_LDB)



