# 基因搜索模块，输入基因ID，相应输出对应信息
get_Search_Gene <- function(GeneID){
    GeneID <- GeneID %>% substr(1,19)
    gene_data <- dbGetQuery(db, str_c(
        "SELECT * FROM RefCSGenePostion WHERE gene = '", GeneID, "';"
    ))
    
    # 未找到提示信息
    if (nrow(gene_data) == 0){
        shinyalert("Error","Pleace check GeneID ,should be CS2.1 Version","error")
        return()
    }else{
        
        
        # 获取全部注释信息
        data_ANN <- dbGetQuery(db,str_c(
            "SELECT * FROM RefCSGeneAnnotation WHERE GeneID = '",GeneID,"';"
        ))
        
        
        # 注释信息
        if (nrow(data_ANN) != 0){

            # showModal(
            #     modalDialog(
            #         title = "Latest annotation information (Chinese Spring2.1)",
            #         size = "xl",
            #         easyClose = T,
            #         tagList(
            #             renderDT(data_ANN,options = list(lengthChange = FALSE))
            #         )
            #     )
            # )
            
        }


        
        return(list(
            chr=gene_data$chr[1],
            start=gene_data$start[1],
            end=gene_data$end[1],
            info=gene_data$description[1],
            gene_data=gene_data,
            df_Annotation=data_ANN
        ))
    }
}
