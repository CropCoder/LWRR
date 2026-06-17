run_GeneHAP <- function(file_vcf,file_phe,userUID,hap_num,select_phe){

my_opt_hapNum <- hap_num

dir.create(paste0("www/OUT/",userUID,"/GeneHAP_Result/"))

my_input_gene <- userUID

# 创建条件格式
mycol <- c("#1abc9c", "#cec8d1", "#e67e22") # 分别表示缺失、00、杂合、11

# 初始基因编号
input_gene <- my_input_gene
job_ID <- my_input_gene

# 提取基因型信息
df_vcf_map <- read.table(str_c("www/OUT/",userUID,"/SGAT_OUT/MVP_Data.geno.map"),head=TRUE)

mychr <- unique(df_vcf_map$CHROM)
mystart <- min(df_vcf_map$POS)
myend <- max(df_vcf_map$POS)

# 提取VCF信息
tmp_vcf <- file_vcf


# 整理VCF
# 对单个基因的VCF文件进行处理
df_vcf <- read.vcfR(tmp_vcf)
df_fix <- df_vcf@fix %>% as.data.frame()
df_gt <- extract.gt(df_vcf)

if (nrow(df_gt) < 2) {
    stop("Error: No key SNP found")
}

vcf <- cbind(df_fix, df_gt) # 得到VCF文件

# 转置并替换基因型格式
t_vcf <- t(vcf) %>%
    as.data.frame() %>%
    mutate(across(everything(), ~ str_replace_all(., "/", "|")))

write.table(t_vcf, paste0("www/OUT/",userUID,"/GeneHAP_Result/GeneHAP_Data.txt"),
    row.names = T, col.names = F, quote = F
)

df_gt <- t_vcf[10:nrow(t_vcf), -1]
df_gt <- apply(df_gt, 1:2, function(x) {
    if (is.na(x)) {
        1
    } else { # 缺失基因型为-1
        if (x == "1|1") {
            2
        } else { # 纯合突变位2
            if (x == "0|0") {
                0
            } else { # 纯合参考为0
                1 # 杂合位点为1
            }
        }
    }
}) %>% as.data.frame()

# 将pheatmap转换为plotly热图
df_gt_plot_new <- as.matrix(df_gt)

plotly_heatmap <- plot_ly(
    x = rownames(vcf),
    y = rownames(df_gt_plot_new),
    z = df_gt_plot_new,
    type = "heatmap",
    colors = mycol,
    showscale = TRUE,
    colorbar = list(
        ticktext = c("0/0", "NA", "1/1"),
        tickvals = c(0, 1, 2)
    )
) %>%
layout(
    xaxis = list(showticklabels = FALSE),
    yaxis = list(showticklabels = FALSE)
)

pheat_plot <- pheatmap(df_gt,
    filename = paste0("www/OUT/",userUID,"/GeneHAP_Result/GeneHAP_heatmap.pdf"),
    width = 19,
    height = 7,
    show_rownames = F,
    show_colnames = F,
    cluster_cols = F,
    cluster_rows = T,
    cutree_rows = my_opt_hapNum,
    legend_breaks = 0:2,
    border_color = NA,
    legend_labels = c("0/0", "NA", "1/1"),
    color = mycol
)

row_dendrogram <- as.dendrogram(pheat_plot$tree_row)
row_order <- order.dendrogram(row_dendrogram)
df_gt_order_auto <- df_gt[row_order, ]

# 获取自动聚类的结果
clusters <- cutree(as.hclust(row_dendrogram), k = my_opt_hapNum)

sample_cluster <- as.data.frame(matrix(nrow = 0, ncol = 2))
colnames(sample_cluster) <- c("ID", "cluster")
for (i in 1:my_opt_hapNum) {
    tmp_cluster <- which(clusters == i)
    tmp_id <- names(tmp_cluster)
    tmp_type <- rep(paste0("Hap", i), length(tmp_id))
    tmp_addtion <- data.frame(tmp_id, tmp_type)
    sample_cluster <- rbind(sample_cluster, tmp_addtion)
}

colnames(sample_cluster) <- c("ID", "cluster")

df_phe <- read.xlsx(file_phe)
df_phe <- df_phe[,c(1,which(colnames(df_phe) == select_phe))] %>% drop_na()

# 统计表型和基因型
df_gt_phe <- left_join(df_phe,sample_cluster,by="ID")

write.csv(df_gt_phe,paste0("www/OUT/",userUID,"/GeneHAP_Result/GeneHAP_HAP_Trait.csv"),row.names =F)


df_plot <- df_gt_phe
colnames(df_plot) <- c("ID","Value","Cluster")
df_plot <- df_plot %>% drop_na()

p_phe <- ggplot(df_plot,aes(x=Cluster,y=Value,fill=Cluster))+
#  geom_jitter(alpha = 0.8,position = position_jitter(0.2), 
#                         aes(color = Cluster)) +
 geom_boxplot(aes(fill = Cluster),alpha = 0.1,position=position_dodge(1.2))+
 theme_bw()

plotly_phe <- ggplotly(p_phe)

df_plot <- df_plot %>% drop_na()
my_comparisons <- combn(str_c("Hap",1:my_opt_hapNum), 2, simplify = FALSE)

df_plot_single <- df_plot
my_select_phe <- select_phe
p_test <- ggboxplot(df_plot_single, x="Cluster",y = "Value",
               add.params = list(size = 0.1, jitter = 0.2),
               color = "Cluster",add = "jitter",ylab = my_select_phe,outlier.shape = NA)  +
  scale_x_discrete(limits=unique(df_plot_single$Cluster)) +
  stat_compare_means(comparisons = my_comparisons,size=3,label="p.signif",bracket.size = 1)+
  theme_bw()

out_DT <- df_plot[,c("ID","Cluster","Value")]

ggsave(paste0("www/OUT/",userUID,"/GeneHAP_Result/GeneHAP_HAP_Trait_plot.png"),plot=p_test,width = 4,height = 4)

# system(str_c("bash ./get_gz_out.sh ",job_ID," ","/srv/shiny-server/zhaojiwen/RiceGeneHAP_ZWQ/www/TMP/"))

    return(list(
        out_DT=out_DT,
        plotly_phe=plotly_phe,
        plotly_heatmap=plotly_heatmap

    ))

}