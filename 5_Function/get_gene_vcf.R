get_gene_vcf <- function(geneid,select_phe){

    mygeneid <- geneid %>% as.character()
    # get vcf
    mychr <- dbGetQuery(db, str_c(
        "SELECT Chrome FROM S4GeneTPM WHERE Gene_ID='", mygeneid, "'"
    )) %>% paste0("Chr", .)
    mystart <- dbGetQuery(db, str_c(
        "SELECT Start_CS21 FROM S4GeneTPM WHERE Gene_ID='", mygeneid, "'"
    ))
    myend <- dbGetQuery(db, str_c(
        "SELECT End_CS21 FROM S4GeneTPM WHERE Gene_ID='", mygeneid, "'"
    ))

    # 提取VCF信息
    tmp_vcf <- str_c("./www/TMP/", mygeneid, ".vcf")

    # 如果存在
    if (file.exists(tmp_vcf)) {
        # 对单个基因的VCF文件进行处理
        df_vcf <- read.vcfR(tmp_vcf)
        df_fix <- df_vcf@fix %>% as.data.frame()
        df_gt <- extract.gt(df_vcf)

        if (nrow(df_gt) < 2) {
            shinyalert("Tips", "没有找到关键变异位点", type = "error")
            return()
        }

        vcf <- cbind(df_fix, df_gt) # 得到VCF文件

        # 提取VCF文件的第1到第5列
        out_vcf <- vcf[, 1:5]

        return(list(
            out_vcf = out_vcf,
            pheat_plot = paste0("TMP/", mygeneid, ".heatmap.cluster.ID.png"),
            LD_plot = paste0("TMP/", mygeneid, ".ld_block_result_fix.svg")
        ))
    } else {
        system(str_c("/app/build/bcftools-1.21/bcftools view",
            "-r", paste0(mychr, ":", mystart, "-", myend),
            myvcf_file, ">", tmp_vcf,
            sep = " "
        ))

        mychr <- mychr
        mystat <- mystart
        myend <- myend

        system(str_c(sep=" ",
        "/app/build/LDBlockShow-1.40/bin/LDBlockShow",
        "-InVCF",tmp_vcf,
        "-Region",paste0(mychr,":",mystat,"-",myend),
        "-SeleVar 4 -TopSite",
        "-NoShowLDist 5000000",
        "-OutPut",paste0("www/TMP/",mygeneid,".ld_block_result")
        ))

        system(str_c(sep = " ",
                 "/app/build/LDBlockShow-1.40/bin/ShowLDSVG",
                 "-InPreFix",paste0("www/TMP/",mygeneid,".ld_block_result"),
                 "-OutPut",paste0("www/TMP/",mygeneid,".ld_block_result_fix"),
                 "-crBegin 75,176,116 -crMiddle 33,138,140  -crEnd 53,71,108",
                 # "-OutPdf",
                 "-TopSite",
                 "-Cutline", 7,
                 "-NoShowLDist",700681000
        ))


        # 整理VCF
        # 对单个基因的VCF文件进行处理
        df_vcf <- read.vcfR(tmp_vcf)
        df_fix <- df_vcf@fix %>% as.data.frame()
        df_gt <- extract.gt(df_vcf)

        if (nrow(df_gt) < 2) {
            shinyalert("Tips", "The queried gene is abnormal and no variant locus was obtained, please try another gene in the QTL candidate interval.", type = "error")
            return(NULL)
        }

        vcf <- cbind(df_fix, df_gt) # 得到VCF文件

        # 提取VCF文件的第1到第5列
        out_vcf <- vcf[, 1:5]

        # 转置并替换基因型格式
        t_vcf <- t(vcf) %>%
            as.data.frame() %>%
            mutate(across(everything(), ~ str_replace_all(., "/", "|")))

        df_gt <- t_vcf[10:nrow(t_vcf), ]
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

        # 绘制热图
        my_opt_hapNum <- 4
        mycol <- c("#6a89cc", "#82ccdd", "#b8e994")
        pheat_plot <- pheatmap(df_gt,
            filename = paste0("./www/TMP/", mygeneid, ".heatmap.cluster.ID.png"),
            width = 10,
            height = 4,
            show_rownames = F,
            show_colnames = T,
            cluster_cols = F,
            cluster_rows = T,
            cutree_rows = my_opt_hapNum,
            legend_breaks = 0:2,
            angle_col = c("45"),
            legend_labels = c("0/0", "0/1", "1/1"),
            color = mycol
        )

        row_dendrogram <- as.dendrogram(pheat_plot$tree_row)
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

        df_phe <- S1_sample[,c("RunID",select_phe)]
        df_phe <- df_phe %>% drop_na()

        colnames(df_phe) <- c("ID","Value")

        # 统计表型和基因型
        df_gt_phe <- left_join(df_phe,sample_cluster,by="ID")

        # write.csv(df_gt_phe,paste0("www/OUT/",userUID,"/GeneHAP_Result/GeneHAP_HAP_Trait.csv"),row.names =F)

        df_plot <- df_gt_phe
        colnames(df_plot) <- c("ID","Value","Cluster")
        df_plot <- df_plot %>% drop_na()

        p_phe <- ggplot(df_plot,aes(x=Cluster,y=Value,fill=Cluster))+
            geom_boxplot(aes(fill = Cluster),alpha = 0.1,position=position_dodge(1.2))+
            theme_bw()

        ggsave(paste0("www/TMP/",mygeneid,".GeneHAP_HAP_Trait_plot.png"),plot=p_phe,width = 5,height = 4)

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

        return(list(
            out_vcf = out_vcf,
            pheat_plot = paste0("TMP/", mygeneid, ".heatmap.cluster.ID.png"),
            LD_plot = paste0("TMP/", mygeneid, ".ld_block_result_fix.svg"),
            out_DT = out_DT,
            plotly_phe_hap_box = paste0("TMP/",mygeneid,".GeneHAP_HAP_Trait_plot.png")
        ))
        
    }
}
