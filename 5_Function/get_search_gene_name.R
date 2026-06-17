##########################################################
## Copyright (c) NWAFU Wheat Bioincloud.lab 2022-2025
##      Project: Ladnscape
##  Description: search engine
##         Date: 2024.6.28
##       Author: Jewel ( zaojewin@icloud.com )
##      Version: 1.0.0
##          web: https://www.Filll.cn
##       Github: https://Github.com/zhao-jiwen
##########################################################



# 输入首页获得的搜索关键字
# 输出搜索结果（表格形式或图片形式）
# 基因名称(已知基因) 返回查询结果
get_search_gene_name <- function(genename){
    
    home_QTL_search_out <- S2_QTL_freq %>% 
        filter(str_detect(Gene_name_index, regex(genename, ignore_case = TRUE)))
    
    if (nrow(home_QTL_search_out) == 0){
        home_QTL_search_out <- S2_QTL_freq %>% 
            filter(str_detect(QTL_ID, regex(genename, ignore_case = TRUE)))
    }
    
    if (nrow(home_QTL_search_out) == 0){
        return("Error")
    }else{
        home_QTL_search_out <- home_QTL_search_out[1,]
    }
    
    search_line_table <- home_QTL_search_out[1,c(2,3,6,7,8,11)]
    
    QID <- home_QTL_search_out$Index[1]
    QYRID <- home_QTL_search_out$QTL_ID[1]
    
    # 搜索结果表格
    data_home_DT <- home_QTL_search_out[,c(2,3,6,7,8,11,12)]
    colnames(data_home_DT) <- c("QTL","Chrome","Block Size (MB)","Start (CS2.1 MB)","End (CS2.1MB)","Includ Gene Num")
    
    # 搜索结果位置图
    data_home_info <- home_QTL_search_out$Known_Gene[1]
    
    if (data_home_info == "Novel"){
        data_home_info <-  "Infomation: A Novel QTL has been discovered that may not have been found in the published data"
    }else{
        data_home_info <- str_c("Infomation:",data_home_info)
    }
    
    # 年代变化图折线
    data_year_line <- home_QTL_search_out[1,28:35] %>% pivot_longer(cols = 1:8,names_to = "year",values_to = "freq")
    data_year_line$year <- c("Pre1950","1950s","1960s","1970s","1980s","1990s","2000s","2010s")
    data_year_line$year <- factor(data_year_line$year,levels = c("Pre1950","1950s","1960s","1970s","1980s","1990s","2000s","2010s"))
    data_year_line$freq <- 100*data_year_line$freq
    
    # 不同地区柱形图
    data_BG_bar <- home_QTL_search_out[1,24:27] %>% pivot_longer(cols = 1:4,names_to = "Group",values_to = "freq")
    data_BG_bar$Group <- c("BG1","BG2","BG3","BG4")
    data_BG_bar$freq <- 100*data_BG_bar$freq

    # # 饼图基因型数据
    data_pie_GT <- home_QTL_search_out[1,19:20] %>% pivot_longer(cols = 1:2,names_to = "type",values_to = "value")
    data_pie_GT$type <- str_replace(data_pie_GT$type,"Number_11","1/1")
    data_pie_GT$type <- str_replace(data_pie_GT$type,"Number_00","0/0")


    which_R <- home_QTL_search_out$R_Allele[1]
    R_sample_ID <- S3_QTL_GT[which(S3_QTL_GT[,which(colnames(S3_QTL_GT) == QID)] == which_R),1]
    S_sample_ID <- S3_QTL_GT[which(S3_QTL_GT[,which(colnames(S3_QTL_GT) == QID)] != which_R),1]
    
    
    # # 获取含有抗病位点的名称
    R_sample_EN <- S1_sample$Name[which(S1_sample$RunID %in% R_sample_ID)]
    R_sample_CN <- S1_sample$NameCN[which(S1_sample$RunID %in% R_sample_ID)]

    
    # 箱线图数据
    phe_boxplot <- S1_sample[,c(2,17:42)]
    phe_boxplot$type <- NA
    phe_boxplot$type[which(phe_boxplot$RunID %in% R_sample_ID)] <- which_R
    phe_boxplot$type[which(is.na(phe_boxplot$type))] <- if(which_R=="1/1"){"0/0"}else{"1/1"}

    # 抗病类型的材料信息
    R_sample_out <- S1_sample[which(S1_sample$RunID %in% R_sample_ID),c(2,3,7,8,11)]
    R_sample_out$Click <- R_sample_out$RunID
    colnames(R_sample_out) <- c("Sample ID","English Name","Material Type","Growth Habit","Position","Click")
    
    
    # 以列表返回搜索结果
    home_search_out_data <- list(DT=data_home_DT,
                            info=data_home_info,
                            freq_year=data_year_line,
                            freq_BG=data_BG_bar,
                            search_out_all=home_QTL_search_out,
                            GT_pie=data_pie_GT,
                            R_sample_CN=R_sample_CN,
                            R_sample_EN=R_sample_EN,
                            phe_boxplot=phe_boxplot,
                            R_sample_out=R_sample_out,
                            search_line_table=search_line_table
                            )
    
    
    return(home_search_out_data)
}


