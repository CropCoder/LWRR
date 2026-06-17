get_Search_Sample <- function(SampleID){
    SampleID <- as.character(SampleID)

    # 查样本的来源信息
    if (SampleID %in% search_index_Sample){
        
        df <- dbGetQuery(db,str_c(
            "SELECT * FROM S1SampleInfo WHERE RunID='",SampleID,"'"
        ))
    }else{
        if (SampleID %in% search_index_CN_name){
            df <- dbGetQuery(db,str_c(
                "SELECT * FROM S1SampleInfo WHERE NameCN='",SampleID,"'"
            ))
        }else{
            if (SampleID %in% search_index_EN_name){
                df <- dbGetQuery(db,str_c(
                    "SELECT * FROM S1SampleInfo WHERE Name='",SampleID,"'"
                ))
            }else{
                shinyalert(
                    "Error",
                    str_c("The sample you entered was not found:",SampleID),
                    "error"
                )
                return()
            }
        }
    }
    
    if (nrow(df) > 1 ){
        shinyalert(
            "Infomation",
            str_c("There may be duplicate samples:",SampleID),
            "info"
        )
    }
    
    RunID = df$RunID[1]
    
    # 表型
    df_trait <- df[1,c(17:45)] %>% 
        t() %>% 
        as.data.frame() %>% 
        drop_na()
    df_trait <- df_trait %>% rownames_to_column("Trait")
    colnames(df_trait) <- c("Trait","Value")
    
    
    # 样本表型图
    # IT 
    df_trait_IT <- df_trait[which(str_detect(df_trait$Trait,"IT")),] %>% drop_na()
    
    plot_IT <- df_trait_IT %>%
        e_charts(Trait) %>%
        e_bar(Value) %>% 
        e_legend(show = F) %>% 
        e_title(str_c("Infection Type (IT) of ",RunID),x="center") %>% 
        e_y_axis(max = 10, min = 0) %>%  # 设置Y轴最大值为10，最小值为0
        e_tooltip(trigger = "axis") %>%  # 增加tooltip提示
        e_color(color = "#1abc9c") %>% 
        e_x_axis(axisLabel = list(interval = 0, rotate = 45))  # 横轴标签旋转45度，并展示所有刻度
    
    # DS
    df_trait_DS <- df_trait[which(str_detect(df_trait$Trait,"DS") & !str_detect(df_trait$Trait,"LR")),] %>% 
        
        drop_na()
    
    plot_DS <- df_trait_DS %>%
        e_charts(Trait) %>%
        e_bar(Value) %>% 
        e_legend(show = F) %>% 
        e_title(str_c("Disease Severity (DS) of ",RunID),x="center") %>% 
        e_y_axis(max = 100, min = 0) %>%  # 设置Y轴最大值为10，最小值为0
        e_tooltip(trigger = "axis") %>%  # 增加tooltip提示
        e_color(color = "#3498db") %>% 
        e_x_axis(axisLabel = list(interval = 0, rotate = 45))  # 横轴标签旋转45度，并展示所有刻度
    
    # CYR
    df_trait_CYR <- df_trait[which(str_detect(df_trait$Trait,"CYR")),] %>% drop_na()
    
    plot_CYR <- df_trait_CYR %>%
        e_charts(Trait) %>%
        e_bar(Value) %>% 
        e_legend(show = F) %>% 
        e_title(str_c("Seed Phenotype (CYR) of ",RunID),x="center") %>% 
        e_y_axis(max = 10, min = 0) %>%  # 设置Y轴最大值为10，最小值为0
        e_tooltip(trigger = "axis") %>%  # 增加tooltip提示
        e_color(color = "#40739e") %>% 
        e_x_axis(axisLabel = list(interval = 0, rotate = 45))  # 横轴标签旋转45度，并展示所有刻度
    
    
    
    
    # QTL-查询样本对应存在的QTL----
    df_GT <- dbGetQuery(db,str_c(
        "SELECT * FROM S3QTLgt WHERE Sample='",RunID,"'"
    )) %>% t() %>% as.data.frame() %>% rownames_to_column("RunID")
    colnames(df_GT) <- c("QTL","GT")
    
    ref_QTL <- dbGetQuery(db,str_c(
        "SELECT `Index`,QTL_ID,Gene_name_index,R_Allele,Ref,Alt,Gene_Number,Start_CS21_MB,End_CS21_MB,Chrome FROM S2QTLfreq"
    ))
    colnames(ref_QTL)[1:2] <- c("QTL","QTLID")
    
    df_QTL_info <- left_join(df_GT,ref_QTL,by="QTL")
    df_QTL_info <- df_QTL_info[-1,c(3,2,5,6,7,8,11,9,10)]
    df_QTL_info$Type <- NA
    colnames(df_QTL_info) <- c("QTL","SampleGT","ResistAllele","Ref","Alt","GeneNumber","Chr","Start","End","Type")
    df_QTL_info <- df_QTL_info %>% filter(End<800)
    df_QTL_info$Type[which(df_QTL_info$SampleGT == df_QTL_info$ResistAllele)] <- "Presence"
    df_QTL_info$Type[which(df_QTL_info$SampleGT != df_QTL_info$ResistAllele)] <- "Absence"

    
    # 样本对应的抗病位点全景图----
    df_QTL_info_plot <- df_QTL_info
    df_QTL_info_plot$Pos <- (df_QTL_info_plot$End + df_QTL_info_plot$Start)/2 
    df_QTL_info_plot$Type <- factor(df_QTL_info_plot$Type)
    
    
    df_YR <- dbGetQuery(
        db,"SELECT * FROM YrKnownGene"
    ) %>% left_join(df_QTL_info,"QTL")
    
    sample_QTL_plot <- ggplot()+
        # 基础框架
        geom_ideogram(data = chr_size,aes(x = Chrom, ymin = Start, ymax = End,
                                           chrom = Chrom),
                      radius = unit(0, 'pt'), width = 0.3, linewidth = 0.4,
                      colour = 'black', show.legend = FALSE)+
        # 431QTL
        geom_ideogram(data = df_QTL_info_plot,aes(x=Chr,ymin = Start,ymax = End,chrom = Chr,fill = Type),
                      radius = unit(4, 'pt'),width=0.3,linewidth = 10,show.legend = T)+
        # 添加文字标注信息
        # geom_text_repel(data = df_QTL_info_plot, aes(x = Chr, y = Pos,colour=Type,
        #                                    label = QTL),
        #                 size = 4, hjust = 0, nudge_x = 0.3,
        #                 arrow = arrow(length = unit(0.015, "npc")),
        #                 direction    = "y",
        #                 force_pull   = 0,
        #                 segment.size      = 0.2,
        #                 segment.curvature = -0.1,
        #                 segment.color=NA,
        #                 segment.ncp = 1,
        #                 segment.angle = 100) +
        # 标记图-Yr
        # geom_point(data = df_YR,
        #            aes(x = Chr, y = Pos),size=3,colour="#f79f1f",
        #            position = position_nudge(x = 0)) +
        # 着丝粒
        geom_ideogram(data = chr_size,aes(x=Chrom,ymin = mid,ymax = mid+10,chrom = Chrom),fill="#2b2b2b",
                      radius = unit(3, 'pt'),width=0.3,linewidth = 10,show.legend = F)+
        scale_y_continuous(
            limits = c(0, 800),  # 设置Y轴范围从0到800
            breaks = seq(0, 800, by = 100),  # 设置Y轴刻度间隔为100
            labels = function(x) paste0(x, " Mb")  # 在每个刻度后面加上"Mb"
        )+
        # scale_y_reverse()+
        ggplot2::theme(
            axis.title = element_blank(),
            # axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            panel.background = element_blank()
        )
    
    
    colnames(df_QTL_info)[c(8,9)] <- c("Start(Mb)","End(Mb)")
    
    return(list(
        RunID = df$RunID[1],
        NameCN = df$NameCN[1],
        Pedigree = df$Pedigree[1],
        Year = df$Year[1],
        GrowthHabit=df$GrowthHabit[1],
        SubRegion=df$SubRegion[1],
        BreedingGroup=df$BreedingGroup[1],
        df_trait=df_trait,
        df_QTL_info=df_QTL_info,
        plot_IT=plot_IT,
        plot_DS=plot_DS,
        plot_CYR=plot_CYR,
        sample_QTL_plot=sample_QTL_plot
    ))
}