# 单倍型分析流程-单个基因
library(getopt)
library(tidyverse)
library(vcfR)
library(readr)
library(stats)
library(pheatmap)
library(openxlsx)

args <- commandArgs(T)

GeneID <- args[1]
file_vcf <- args[2]
file_phe <- args[3]
userUID <- args[4]

# GeneID <- "TraesCS1B03G1235100"
# file_vcf="data/TraesCS1B03G1235100.vcf.gz"
# file_phe="data/Example_trait_file.xlsx"
# userUID <- "20240727_test"

## 1.设置参数----
# 输入参数
myjob <- paste0("GeneHAP_",GeneID,"_",userUID) # 项目名称
opt_cluster <- F  # 选择是否选择聚类，若为F则不进行聚类分析
mygene <- GeneID
my_show_which_phe <- c() # 选择表型
my_show_which_vartype <- c() # 选择变异位点类型
my_show_which_sample <- c() # 选择样品
# 添加表达量信息
my_TPM_D <- vroom::vroom("data/RNAseq_339_fromquota_D.csv")
my_TPM_DC <- vroom::vroom("data/RNAseq_339_fromquota_DC.csv")

# 选择样品
my_show_which_sample <- read.table("data/sample_锈病有表型材料清单_869.txt",header = F) %>% pull(V1)
# my_show_which_sample <- read.table("data/Sample_ID_ForOtherRust_843.txt",header = F) %>% pull(V1)

my_region_updownstream_length <- 3000 # 上下游添加的范围

my_hap_num <- 6 # 指定划分的初始单倍型个数，0表示按照默认算法划分6种
# mycol <- c("#ced6e0","#22a6b3","#8e44ad","#c23616") # 分别表示缺失、00、杂合、11
mycol <- c("#22a6b3","#8e44ad","#c23616") # 分别表示缺失、00、杂合、11
# 创建条件格式
Style_0 <- createStyle(bgFill = mycol[1]) #00
Style_1 <- createStyle(bgFill = mycol[2]) #01 10
Style_2 <- createStyle(bgFill = mycol[3]) #11
# Style_x <- createStyle(bgFill = mycol[1]) #NA
# set.seed(626)
# uid <- uuid::UUIDgenerate() # 生成唯一项目ID
# uid <- str_c(Sys.Date(),"-",myjob,"-",str_sub(uid,1,8))
# 
# dir.create(paste0("out/",uid))
# out_dir_all <- paste0("out/",uid,"/")
# # out_dir
# gene_list <- read.table("./geneid.txt") %>% pull(V1)

dir.create(paste0("out/",userUID,"/GeneHAP_OUT"))
out_dir_all <- paste0("out/",userUID,"/GeneHAP_OUT/")

## 2.读取文件----
# 读入文件数据-重测序基因型-有注释信息

df_chr <- read.table("/data_disk/wheat/convert/wheat_21_chrome_name_id_convert_1_1A_Chr1A_chr1A.txt",header = T)
df_gene_region <- read.csv("/data_disk/wheat/convert/wheat_gene_positon_name_CHR.csv")
var_no_syn <- read.table("data/no_syn.txt")
df_phe <- read_tsv(paste0("out/",userUID,"/user_upload_trait.tsv"))


## 3.提取基因VCF----
# 创建日志文件
out_dir <- out_dir_all
write.table(str_c("########################## ",mygene," Analysis Log"),
            paste0(out_dir_all,"work.log"),row.names = F,col.names = F,append = T)

## 4.VCF文件整理----
# 对单个基因的VCF文件进行处理
df_vcf <- read.vcfR(paste0("out/",userUID,"/",GeneID,".vcf.gz"))
df_fix <- df_vcf@fix %>% as.data.frame()
df_gt <- df_vcf@gt %>% as.data.frame()

## 样品过滤----
df_gt <- df_gt[,c(1,which(colnames(df_gt) %in% my_show_which_sample))]

write.table(str_c(Sys.time(),"\t",mygene,"\t","Number of Vars:",nrow(df_gt)),
            paste0(out_dir_all,"work.log"),row.names = F,col.names = F,append = T)
write.table(str_c(Sys.time(),"\t",mygene,"\t","Number of Samples:",ncol(df_gt)-1),
            paste0(out_dir_all,"work.log"),row.names = F,col.names = F,append = T)
if (nrow(df_gt) < 2){next}
vcf <- cbind(df_fix,df_gt) #得到VCF文件
for (k in 1:nrow(vcf)){
  vcf$INFO[k] <- vcf$INFO[k] %>% str_split("[|]") %>% .[[1]] %>% .[2] # 变异类型
}

# 计算关键变异的数量
var_key_sum <- sum(vcf$INFO %in% var_no_syn$V1)
write.table(str_c(Sys.time(),"\t",mygene,"\t","Number of KeyVarType: ",var_key_sum,"(",nrow(df_gt),")"),
            paste0(out_dir_all,"work.log"),row.names = F,col.names = F,append = T)

my_num_var <- nrow(df_fix)

# 转置并替换基因型格式
t_vcf <- t(vcf) %>% as.data.frame() %>% 
  mutate(across(everything(), ~str_replace_all(., "/", "|")))

write.table(t_vcf,paste0(out_dir,mygene,".all.data.tvcf.txt"),
            row.names = T,col.names = F,quote = F)

# 附加：海涛师兄排序算法 ----
system(str_c(
  "bash","function/sort_ht.sh",paste0("./",out_dir,mygene,".all.data.tvcf.txt"),
  paste0("./",out_dir,mygene,".all.data.tvcf.htsorted.txt"),sep = " "
))

df_htsort <- read.table(paste0("./",out_dir,mygene,".all.data.tvcf.htsorted.txt"),header = F)

# 转换编码方式
rownames(df_htsort) <- df_htsort$V1
df_gt <- df_htsort[10:nrow(df_htsort),-1]
df_gt <- apply(df_gt, 1:2, function(x){
  if ( is.na(x) ){-1}else{ # 缺失基因型为-1
    if ( x == "1|1" ){2} else{ # 纯合突变位2
      if ( x == "0|0" ){0}else{ # 纯合参考为0
        1 # 杂合位点为1
      }
    }
  } 
}) %>% as.data.frame()

## 绘制热图----
# 原始顺序画图
pheat_plot <- pheatmap(df_gt,
                       filename = paste0(out_dir,mygene,".all.plot.heatmap.htsort.fullname.pdf"),
                       width = 80,
                       height = 220,
                       show_rownames = T,
                       show_colnames = T,
                       cluster_cols = F,
                       cluster_rows = F,
                       legend_breaks = -1:2 ,
                       border_color = NA,
                       legend_labels = c("N/A", "0/0", "0/1", "1/1"),
                       color = mycol)
pheat_plot <- pheatmap(df_gt,
                       filename = paste0(out_dir,mygene,".all.plot.heatmap.htsort.small.pdf"),
                       width = 19,
                       height = 9,
                       show_rownames = F,
                       show_colnames = F,
                       cluster_cols = F,
                       cluster_rows = F,
                       legend_breaks = -1:2 ,
                       border_color = NA,
                       legend_labels = c("N/A", "0/0", "0/1", "1/1"),
                       color = mycol)
# 输出Excel----
# 构造输出矩阵
out_rightregion <- df_htsort # 右侧区域的基因型
colnames(out_rightregion) <- out_rightregion[3,]
# 添加表型和样品信息
sample_cluster <- as.data.frame(matrix(nrow = 0,ncol = 2))
colnames(sample_cluster) <- c("ID","Index")
for (m in 10:nrow(df_htsort)){
  tmp_addtion <- data.frame(df_htsort$V1[m],m)
  sample_cluster <- rbind(sample_cluster,tmp_addtion)
}
colnames(sample_cluster) <- c("ID","Index")

# 统计表型信息
df_sam_cluster_phe <- left_join(sample_cluster,df_phe,by="ID")
df_sam_cluster_phe <- df_sam_cluster_phe[,c(1,3:ncol(df_sam_cluster_phe),5)]

# write.csv(df_sam_cluster_phe,paste0(out_dir,mygene,".all.data.SamplePhe.csv"),row.names = T)

out_leftdown <- df_sam_cluster_phe
out_leftup_NULL <- as.data.frame(matrix(nrow = 9,ncol = ncol(out_leftdown)))
colnames(out_leftup_NULL) <- colnames(out_leftdown)
out_leftup_NULL$ID[1:nrow(out_leftup_NULL)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
out_leftregion <- rbind(out_leftup_NULL,out_leftdown)
out <- left_join(out_leftregion,out_rightregion,by="ID")

# 重命名格式：
out[1:nrow(out_leftup_NULL),ncol(out_leftregion)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
out[9,1:ncol(out_leftregion)] <- colnames(out_leftdown)
out[1:8,1] <- NA

# 添加表达量信息
TPM_D_Gene <- my_TPM_D[which(my_TPM_D$Name == mygene),] %>% 
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("ID")
colnames(TPM_D_Gene) <- c("ID","D_TPM_Rust")
out <- left_join(out,TPM_D_Gene,by="ID")

TPM_DC_Gene <- my_TPM_DC[which(my_TPM_DC$Name == mygene),] %>% 
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("ID")
colnames(TPM_DC_Gene) <- c("ID","DC_TPM_Rust")
out <- left_join(out,TPM_DC_Gene,by="ID")

# write_csv(out,paste0(out_dir,mygene,".all.data.htsort.out.csv"))

## 11.保存Excel文件
# 保存并输出为xlsx文件
wb <- createWorkbook() # 创建工作簿
addWorksheet(wb, "finalout") # 添加工作表

writeData(wb, "finalout", out)

# 匹配条件格式
conditionalFormatting(wb, "finalout",
                      cols = (ncol(out_leftregion)+1):ncol(out),
                      rows = 9:nrow(out), 
                      rule = 'ISNUMBER(SEARCH("0|0", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_0
)
conditionalFormatting(wb, "finalout",
                      cols = (ncol(out_leftregion)+1):ncol(out),
                      rows = 9:nrow(out), 
                      rule = 'ISNUMBER(SEARCH("0|1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_1
)
conditionalFormatting(wb, "finalout",
                      cols = (ncol(out_leftregion)+1):ncol(out),
                      rows = 9:nrow(out), 
                      rule = 'ISNUMBER(SEARCH("1|0", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_1
)
conditionalFormatting(wb, "finalout",
                      cols = (ncol(out_leftregion)+1):ncol(out),
                      rows = 9:nrow(out), 
                      rule = 'ISNUMBER(SEARCH("1|1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_2
)
# conditionalFormatting(wb, "finalout",
#                       cols = (ncol(out_leftregion)+1):ncol(out),
#                       rows = 9:nrow(out), 
#                       rule = 'ISNUMBER(SEARCH("NA", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_x
# )

# 调整单元格宽度
setColWidths(wb, "finalout", cols = 2:(ncol(out_leftregion) - 1), widths = 3)
setColWidths(wb, "finalout", cols = (ncol(out_leftregion)+1):ncol(out), widths = 3)

# 输出保存
saveWorkbook(wb, paste0(out_dir,mygene,".all.final.htsorted.xlsx"),
             overwrite = TRUE)

# 以下开始其他方法----


# 选择是否进行聚类
if (opt_cluster == TRUE){
  ## 5.转换012格式----
  # 转换编码方式
  df_gt <- t_vcf[10:nrow(t_vcf),]
  df_gt <- apply(df_gt, 1:2, function(x){
    if ( is.na(x) ){-1}else{ # 缺失基因型为-1
      if ( x == "1|1" ){2} else{ # 纯合突变位2
        if ( x == "0|0" ){0}else{ # 纯合参考为0
          1 # 杂合位点为1
        }
      }
    } 
  }) %>% as.data.frame()
  
  ## 6.绘制自动聚类热图----
  # 原始顺序画图
  pheat_plot <- pheatmap(df_gt,
                         filename = paste0(out_dir,mygene,".all.plot.hapheatmap.cluster.byID.pdf"),
                         width = 16,
                         height = 9,
                         show_rownames = F,
                         show_colnames = F,
                         cluster_cols = F,
                         cluster_rows = T,
                         cutree_rows = my_hap_num ,
                         legend_breaks = -1:2 ,
                         legend_labels = c("N/A", "0/0", "0/1", "1/1"),
                         color = mycol)
  pheat_plot <- pheatmap(df_gt,
                         filename = paste0(out_dir,mygene,".all.plot.hapheatmap.cluster.byID.bySNP.pdf"),
                         width = 16,
                         height = 9,
                         show_rownames = F,
                         show_colnames = F,
                         cluster_cols = T,
                         cluster_rows = T,
                         cutree_rows = my_hap_num ,
                         legend_breaks = -1:2 ,
                         legend_labels = c("N/A", "0/0", "0/1", "1/1"),
                         color = mycol)
  
  ## 7.获取聚类分组次序----
  # 进一步获得排序后的基因型矩阵
  row_dendrogram <- as.dendrogram(pheat_plot$tree_row)
  row_order <- order.dendrogram(row_dendrogram)
  df_gt_order_auto <- df_gt[row_order,]
  
  # 获取自动聚类的结果
  clusters <- cutree(as.hclust(row_dendrogram), k = my_hap_num)
  
  sample_cluster <- as.data.frame(matrix(nrow = 0,ncol = 2))
  colnames(sample_cluster) <- c("ID","cluster")
  for (i in 1:my_hap_num){
    tmp_cluster <- which(clusters == i)
    tmp_id <- names(tmp_cluster)
    tmp_type <- rep(paste0("Hap",i),length(tmp_id))
    tmp_addtion <- data.frame(tmp_id,tmp_type)
    sample_cluster <- rbind(sample_cluster,tmp_addtion)
  }
  colnames(sample_cluster) <- c("ID","cluster")
  
  ## 8.匹配样品表型数据----
  # 统计表型信息
  df_sam_cluster_phe <- left_join(sample_cluster,df_phe,by="ID")
  # write.csv(df_sam_cluster_phe,paste0(out_dir,mygene,".data.SampleHapPhe.csv"),row.names = T)
  
  ## 9.聚类版基因型处理----
  df <- df_gt_order_auto
  df <- rbind(t_vcf[1:9,],df)
  df <- cbind(rownames(df),df)
  colnames(df) <- df[3,] # df是聚类排序后的转置vcf
  
  ## 10.输出Excel大纲----
  # 构造输出矩阵
  out_rightregion <- df # 右侧区域时基因型
  out_leftdown <- df_sam_cluster_phe[,c(1:ncol(df_sam_cluster_phe),5,2)]
  out_leftup_NULL <- as.data.frame(matrix(nrow = 9,ncol = ncol(out_leftdown)))
  colnames(out_leftup_NULL) <- colnames(out_leftdown)
  out_leftup_NULL$ID[1:nrow(out_leftup_NULL)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
  out_leftregion <- rbind(out_leftup_NULL,out_leftdown)
  out <- left_join(out_leftregion,out_rightregion,by="ID")
  
  # 重命名格式：
  out[1:nrow(out_leftup_NULL),ncol(out_leftregion)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
  out[9,1:ncol(out_leftregion)] <- colnames(out_leftdown)
  out[1:8,1] <- NA
  
  # write_csv(out,paste0(out_dir,mygene,".all.data.cluster.out.csv"))
  
  ## 11.保存Excel文件----
  # 保存并输出为xlsx文件
  wb <- createWorkbook() # 创建工作簿
  addWorksheet(wb, "finalout") # 添加工作表
  
  writeData(wb, "finalout", out)
  
  # 匹配条件格式
  conditionalFormatting(wb, "finalout",
                        cols = (ncol(out_leftregion)+1):ncol(out),
                        rows = 9:nrow(out), 
                        rule = 'ISNUMBER(SEARCH("0", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_0
  )
  conditionalFormatting(wb, "finalout",
                        cols = (ncol(out_leftregion)+1):ncol(out),
                        rows = 9:nrow(out), 
                        rule = 'ISNUMBER(SEARCH("1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_1
  )
  conditionalFormatting(wb, "finalout",
                        cols = (ncol(out_leftregion)+1):ncol(out),
                        rows = 9:nrow(out), 
                        rule = 'ISNUMBER(SEARCH("2", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_2
  )
  conditionalFormatting(wb, "finalout",
                        cols = (ncol(out_leftregion)+1):ncol(out),
                        rows = 9:nrow(out), 
                        rule = 'ISNUMBER(SEARCH("-1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_x
  )
  
  # 调整单元格宽度
  setColWidths(wb, "finalout", cols = 2:(ncol(out_leftregion) - 2), widths = 3)
  setColWidths(wb, "finalout", cols = (ncol(out_leftregion)+1):ncol(out), widths = 2)
  
  # 输出保存
  saveWorkbook(wb, paste0(out_dir,mygene,".all.final.clusterout.xlsx"),
               overwrite = TRUE)
}






# 附加：只排序不聚类(淘汰)----
# df_ready_sort <- df_gt %>% as.data.frame()
# df_ready_sort <- apply(df_ready_sort, 1:2, function(x){
#   if ( x == -1 ){"A"}else{ # 缺失基因型为-1
#     if ( x == 0 ){"B"} else{ # 纯合突变位2
#       if ( x == 1 ){"C"}else{ # 纯合参考为0
#         if (x == 2 ){"D"} # 杂合位点为1
#       }
#     }
#   } 
# }) %>% as.data.frame()
# 
# colnames(df_ready_sort) <- t_vcf[3,]
# 
# 
# df_ready_sort$seq <- NA
# for (i in 1:nrow(df_ready_sort)){
#   df_ready_sort$seq[i] <- str_c(df_ready_sort[i,1:(ncol(df_ready_sort) - 1)],
#                                 collapse = "",sep = "")
# }
# 
# df_sorted <- df_ready_sort %>% arrange(seq)
# 
# df_plot_sorted <- df_gt[rownames(df_sorted),]
# rownames(df_plot_sorted) <- rownames(df_sorted)
# colnames(df_plot_sorted) <- t_vcf[3,]
# pheatmap::pheatmap(df_plot_sorted,
#                    filename = paste0(out_dir,mygene,".plot.strseq.hapheatmap.pdf"),
#                    width = 16,
#                    height = 9,
#                    show_rownames = F,
#                    show_colnames = F,
#                    cluster_cols = F,
#                    cluster_rows = F,
#                    legend_breaks = -1:2 ,
#                    legend_labels = c("N/A", "0/0", "0/1", "1/1"),
#                    color = mycol
#                    )
# 
# write_csv(df_plot_sorted,paste0(out_dir,mygene,".data.strseq.out.csv"))
# 
# # 构造输出矩阵
# out_rightregion <- df # 右侧区域时基因型
# rownames(df_sam_cluster_phe) <- df_sam_cluster_phe$ID
# df_sam_cluster_phe <- df_sam_cluster_phe[rownames(df_sorted),]
# out_leftdown <- df_sam_cluster_phe[,c(1:ncol(df_sam_cluster_phe),5,2)]
# out_leftup_NULL <- as.data.frame(matrix(nrow = 9,ncol = ncol(out_leftdown)))
# colnames(out_leftup_NULL) <- colnames(out_leftdown)
# out_leftup_NULL$ID[1:nrow(out_leftup_NULL)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
# out_leftregion <- rbind(out_leftup_NULL,out_leftdown)
# out <- left_join(out_leftregion,out_rightregion,by="ID")
# 
# # 重命名格式：
# out[1:nrow(out_leftup_NULL),ncol(out_leftregion)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
# out[9,1:ncol(out_leftregion)] <- colnames(out_leftdown)
# out[1:8,1] <- NA
# 
# write_csv(out,paste0(out_dir,mygene,".data.ordf.out.sorted.csv"))
# 
# 
# # 保存并输出为xlsx文件
# wb <- createWorkbook() # 创建工作簿
# addWorksheet(wb, "sorted") # 添加工作表
# 
# # 创建条件格式
# Style_0 <- createStyle(bgFill = mycol[1])
# Style_1 <- createStyle(bgFill = mycol[2])
# Style_2 <- createStyle(bgFill = mycol[3])
# Style_x <- createStyle(bgFill = mycol[4])
# 
# writeData(wb, "sorted", out)
# 
# # 匹配条件格式
# conditionalFormatting(wb, "sorted",
#                       cols = (ncol(out_leftregion)+1):ncol(out),
#                       rows = 9:nrow(out), 
#                       rule = 'ISNUMBER(SEARCH("0", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_0
# )
# conditionalFormatting(wb, "sorted",
#                       cols = (ncol(out_leftregion)+1):ncol(out),
#                       rows = 9:nrow(out), 
#                       rule = 'ISNUMBER(SEARCH("1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_1
# )
# conditionalFormatting(wb, "sorted",
#                       cols = (ncol(out_leftregion)+1):ncol(out),
#                       rows = 9:nrow(out), 
#                       rule = 'ISNUMBER(SEARCH("2", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_2
# )
# conditionalFormatting(wb, "sorted",
#                       cols = (ncol(out_leftregion)+1):ncol(out),
#                       rows = 9:nrow(out), 
#                       rule = 'ISNUMBER(SEARCH("-1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_x
# )
# 
# # 调整单元格宽度
# setColWidths(wb, "sorted", cols = 2:(ncol(out_leftregion) - 2), widths = 3)
# setColWidths(wb, "sorted", cols = (ncol(out_leftregion)+1):ncol(out), widths = 2)
# 
# # 输出保存
# saveWorkbook(wb, paste0(out_dir,mygene,".final.strseq.xlsx"),
#              overwrite = TRUE)


# 仅保留关键变异----

## 4.VCF文件整理----
# 对单个基因的VCF文件进行处理
df_vcf <- read.vcfR(paste0("out/",userUID,"/",GeneID,".vcf.gz"))
df_fix <- df_vcf@fix %>% as.data.frame()
df_gt <- df_vcf@gt %>% as.data.frame()

## 样品过滤----
df_gt <- df_gt[,c(1,which(colnames(df_gt) %in% my_show_which_sample))]

if (nrow(df_gt) < 2){next}
vcf <- cbind(df_fix,df_gt) #得到VCF文件
for (k in 1:nrow(vcf)){
  vcf$INFO[k] <- vcf$INFO[k] %>% str_split("[|]") %>% .[[1]] %>% .[2] # 变异类型
}

# 计算关键变异的数量
var_key_sum <- sum(vcf$INFO %in% var_no_syn$V1)

# 关键步骤：筛选关键变异
vcf <- vcf %>% filter(INFO %in% var_no_syn$V1)

if (nrow(vcf) < 2){next}
# 转置并替换基因型格式
t_vcf <- t(vcf) %>% as.data.frame() %>% 
  mutate(across(everything(), ~str_replace_all(., "/", "|")))

write.table(t_vcf,paste0(out_dir,mygene,".keyvar.data.tvcf.txt"),
            row.names = T,col.names = F,quote = F)

# 附加：海涛师兄排序算法 ----
system(str_c(
  "bash","function/sort_ht.sh",paste0("./",out_dir,mygene,".keyvar.data.tvcf.txt"),
  paste0("./",out_dir,mygene,".keyvar.data.tvcf.htsorted.txt"),sep = " "
))

df_htsort <- read.table(paste0("./",out_dir,mygene,".keyvar.data.tvcf.htsorted.txt"),header = F)

# 转换编码方式
rownames(df_htsort) <- df_htsort$V1
df_gt <- df_htsort[10:nrow(df_htsort),-1]
df_gt <- apply(df_gt, 1:2, function(x){
  if ( is.na(x) ){-1}else{ # 缺失基因型为-1
    if ( x == "1|1" ){2} else{ # 纯合突变位2
      if ( x == "0|0" ){0}else{ # 纯合参考为0
        1 # 杂合位点为1
      }
    }
  } 
}) %>% as.data.frame()

## 绘制热图----
# 原始顺序画图
pheat_plot <- pheatmap(df_gt,
                       filename = paste0(out_dir,mygene,".keyvar.plot.heatmap.htsort.fullname.pdf"),
                       width = 80,
                       height = 220,
                       show_rownames = T,
                       show_colnames = T,
                       cluster_cols = F,
                       cluster_rows = F,
                       legend_breaks = -1:2 ,
                       border_color = NA,
                       legend_labels = c("N/A", "0/0", "0/1", "1/1"),
                       color = mycol)
pheat_plot <- pheatmap(df_gt,
                       filename = paste0(out_dir,mygene,".keyvar.plot.heatmap.htsort.small.pdf"),
                       width = 19,
                       height = 9,
                       show_rownames = F,
                       show_colnames = F,
                       cluster_cols = F,
                       cluster_rows = F,
                       legend_breaks = -1:2 ,
                       border_color = NA,
                       legend_labels = c("N/A", "0/0", "0/1", "1/1"),
                       color = mycol)
# 输出Excel----
# 构造输出矩阵
out_rightregion <- df_htsort # 右侧区域的基因型
colnames(out_rightregion) <- out_rightregion[3,]
# 添加表型和样品信息
sample_cluster <- as.data.frame(matrix(nrow = 0,ncol = 2))
colnames(sample_cluster) <- c("ID","Index")
for (m in 10:nrow(df_htsort)){
  tmp_addtion <- data.frame(df_htsort$V1[m],m)
  sample_cluster <- rbind(sample_cluster,tmp_addtion)
}
colnames(sample_cluster) <- c("ID","Index")

# 统计表型信息
df_sam_cluster_phe <- left_join(sample_cluster,df_phe,by="ID")
df_sam_cluster_phe <- df_sam_cluster_phe[,c(1,3:ncol(df_sam_cluster_phe),5)]

# write.csv(df_sam_cluster_phe,paste0(out_dir,mygene,".keyvar.data.SamplePhe.csv"),row.names = T)

out_leftdown <- df_sam_cluster_phe
out_leftup_NULL <- as.data.frame(matrix(nrow = 9,ncol = ncol(out_leftdown)))
colnames(out_leftup_NULL) <- colnames(out_leftdown)
out_leftup_NULL$ID[1:nrow(out_leftup_NULL)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
out_leftregion <- rbind(out_leftup_NULL,out_leftdown)
out <- left_join(out_leftregion,out_rightregion,by="ID")

# 重命名格式：
out[1:nrow(out_leftup_NULL),ncol(out_leftregion)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
out[9,1:ncol(out_leftregion)] <- colnames(out_leftdown)
out[1:8,1] <- NA


# 添加表达量信息
TPM_D_Gene <- my_TPM_D[which(my_TPM_D$Name == mygene),] %>% 
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("ID")
colnames(TPM_D_Gene) <- c("ID","D_TPM_Rust")
out <- left_join(out,TPM_D_Gene,by="ID")

TPM_DC_Gene <- my_TPM_DC[which(my_TPM_DC$Name == mygene),] %>% 
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column("ID")
colnames(TPM_DC_Gene) <- c("ID","DC_TPM_Rust")
out <- left_join(out,TPM_DC_Gene,by="ID")

# write_csv(out,paste0(out_dir,mygene,".keyvar.data.htsort.out.csv"))

## 11.保存Excel文件
# 保存并输出为xlsx文件
wb <- createWorkbook() # 创建工作簿
addWorksheet(wb, "finalout") # 添加工作表

writeData(wb, "finalout", out)

# 匹配条件格式
conditionalFormatting(wb, "finalout",
                      cols = (ncol(out_leftregion)+1):ncol(out),
                      rows = 9:nrow(out), 
                      rule = 'ISNUMBER(SEARCH("0|0", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_0
)
conditionalFormatting(wb, "finalout",
                      cols = (ncol(out_leftregion)+1):ncol(out),
                      rows = 9:nrow(out), 
                      rule = 'ISNUMBER(SEARCH("0|1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_1
)
conditionalFormatting(wb, "finalout",
                      cols = (ncol(out_leftregion)+1):ncol(out),
                      rows = 9:nrow(out), 
                      rule = 'ISNUMBER(SEARCH("1|0", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_1
)
conditionalFormatting(wb, "finalout",
                      cols = (ncol(out_leftregion)+1):ncol(out),
                      rows = 9:nrow(out), 
                      rule = 'ISNUMBER(SEARCH("1|1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_2
)
# conditionalFormatting(wb, "finalout",
#                       cols = (ncol(out_leftregion)+1):ncol(out),
#                       rows = 9:nrow(out), 
#                       rule = 'ISNUMBER(SEARCH("NA", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_x
# )

# 调整单元格宽度
setColWidths(wb, "finalout", cols = 2:(ncol(out_leftregion) - 1), widths = 3)
setColWidths(wb, "finalout", cols = (ncol(out_leftregion)+1):ncol(out), widths = 3)

# 输出保存
saveWorkbook(wb, paste0(out_dir,mygene,".keyvar.final.htsorted.xlsx"),
             overwrite = TRUE)

# 以下开始其他方法----

if (opt_cluster == TRUE){
  ## 5.转换012格式----
  # 转换编码方式
  df_gt <- t_vcf[10:nrow(t_vcf),]
  df_gt <- apply(df_gt, 1:2, function(x){
    if ( is.na(x) ){-1}else{ # 缺失基因型为-1
      if ( x == "1|1" ){2} else{ # 纯合突变位2
        if ( x == "0|0" ){0}else{ # 纯合参考为0
          1 # 杂合位点为1
        }
      }
    } 
  }) %>% as.data.frame()
  
  ## 6.绘制自动聚类热图----
  # 原始顺序画图
  pheat_plot <- pheatmap(df_gt,
                         filename = paste0(out_dir,mygene,".keyvar.plot.hapheatmap.cluster.byID.pdf"),
                         width = 16,
                         height = 9,
                         show_rownames = F,
                         show_colnames = F,
                         cluster_cols = F,
                         cluster_rows = T,
                         cutree_rows = my_hap_num ,
                         legend_breaks = -1:2 ,
                         legend_labels = c("N/A", "0/0", "0/1", "1/1"),
                         color = mycol)
  pheat_plot <- pheatmap(df_gt,
                         filename = paste0(out_dir,mygene,".keyvar.plot.hapheatmap.cluster.byID.bySNP.pdf"),
                         width = 16,
                         height = 9,
                         show_rownames = F,
                         show_colnames = F,
                         cluster_cols = T,
                         cluster_rows = T,
                         cutree_rows = my_hap_num ,
                         legend_breaks = -1:2 ,
                         legend_labels = c("N/A", "0/0", "0/1", "1/1"),
                         color = mycol)
  
  ## 7.获取聚类分组次序----
  # 进一步获得排序后的基因型矩阵
  row_dendrogram <- as.dendrogram(pheat_plot$tree_row)
  row_order <- order.dendrogram(row_dendrogram)
  df_gt_order_auto <- df_gt[row_order,]
  
  # 获取自动聚类的结果
  clusters <- cutree(as.hclust(row_dendrogram), k = my_hap_num)
  
  sample_cluster <- as.data.frame(matrix(nrow = 0,ncol = 2))
  colnames(sample_cluster) <- c("ID","cluster")
  for (i in 1:my_hap_num){
    tmp_cluster <- which(clusters == i)
    tmp_id <- names(tmp_cluster)
    tmp_type <- rep(paste0("Hap",i),length(tmp_id))
    tmp_addtion <- data.frame(tmp_id,tmp_type)
    sample_cluster <- rbind(sample_cluster,tmp_addtion)
  }
  colnames(sample_cluster) <- c("ID","cluster")
  
  ## 8.匹配样品表型数据----
  # 统计表型信息
  df_sam_cluster_phe <- left_join(sample_cluster,df_phe,by="ID")
  # write.csv(df_sam_cluster_phe,paste0(out_dir,mygene,".data.SampleHapPhe.csv"),row.names = T)
  
  ## 9.聚类版基因型处理----
  df <- df_gt_order_auto
  df <- rbind(t_vcf[1:9,],df)
  df <- cbind(rownames(df),df)
  colnames(df) <- df[3,] # df是聚类排序后的转置vcf
  
  ## 10.输出Excel大纲----
  # 构造输出矩阵
  out_rightregion <- df # 右侧区域时基因型
  out_leftdown <- df_sam_cluster_phe[,c(1:ncol(df_sam_cluster_phe),5,2)]
  out_leftup_NULL <- as.data.frame(matrix(nrow = 9,ncol = ncol(out_leftdown)))
  colnames(out_leftup_NULL) <- colnames(out_leftdown)
  out_leftup_NULL$ID[1:nrow(out_leftup_NULL)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
  out_leftregion <- rbind(out_leftup_NULL,out_leftdown)
  out <- left_join(out_leftregion,out_rightregion,by="ID")
  
  # 重命名格式：
  out[1:nrow(out_leftup_NULL),ncol(out_leftregion)] <- out_rightregion$ID[1:nrow(out_leftup_NULL)]
  out[9,1:ncol(out_leftregion)] <- colnames(out_leftdown)
  out[1:8,1] <- NA
  
  # write_csv(out,paste0(out_dir,mygene,".keyvar.data.cluster.out.csv"))
  
  ## 11.保存Excel文件----
  # 保存并输出为xlsx文件
  wb <- createWorkbook() # 创建工作簿
  addWorksheet(wb, "finalout") # 添加工作表
  
  # 创建条件格式
  
  writeData(wb, "finalout", out)
  
  # 匹配条件格式
  conditionalFormatting(wb, "finalout",
                        cols = (ncol(out_leftregion)+1):ncol(out),
                        rows = 9:nrow(out), 
                        rule = 'ISNUMBER(SEARCH("0", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_0
  )
  conditionalFormatting(wb, "finalout",
                        cols = (ncol(out_leftregion)+1):ncol(out),
                        rows = 9:nrow(out), 
                        rule = 'ISNUMBER(SEARCH("1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_1
  )
  conditionalFormatting(wb, "finalout",
                        cols = (ncol(out_leftregion)+1):ncol(out),
                        rows = 9:nrow(out), 
                        rule = 'ISNUMBER(SEARCH("2", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_2
  )
  conditionalFormatting(wb, "finalout",
                        cols = (ncol(out_leftregion)+1):ncol(out),
                        rows = 9:nrow(out), 
                        rule = 'ISNUMBER(SEARCH("-1", INDIRECT(ADDRESS(ROW(),COLUMN()))))', style = Style_x
  )
  
  # 调整单元格宽度
  setColWidths(wb, "finalout", cols = 2:(ncol(out_leftregion) - 2), widths = 3)
  setColWidths(wb, "finalout", cols = (ncol(out_leftregion)+1):ncol(out), widths = 2)
  
  # 输出保存
  saveWorkbook(wb, paste0(out_dir,mygene,".keyvar.final.clusterout.xlsx"),
               overwrite = TRUE)
}

