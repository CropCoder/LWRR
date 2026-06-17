# get QTL Gene table
get_QTL_include_gene_table <- function(genename="Yr68"){
    
    home_QTL_search_out <- S2_QTL_freq %>% 
        filter(str_detect(Gene_name_index, regex(genename, ignore_case = TRUE)))
    
    if (nrow(home_QTL_search_out) == 0){
        home_QTL_search_out <- S2_QTL_freq %>% 
            filter(str_detect(QTL_ID, regex(genename, ignore_case = TRUE)))
    }
    
    if (nrow(home_QTL_search_out) == 0){
        return("Error")
    }else{
        if (nrow(home_QTL_search_out) == 1)
        home_QTL_search_out <- home_QTL_search_out[1,]
        else{
            shinyalert(
                "Tips",
                str_c("The QTL you queried contains more than one location, here choose [",home_QTL_search_out[1,2],
                      "] for display, if you want to query other locations, please input [",str_c(home_QTL_search_out[,2],collapse = "、"),"]")
            )
            home_QTL_search_out <- home_QTL_search_out[1,]
        }
    }
    
    
    QYRID <- home_QTL_search_out$QTL_ID[1]
    
    out_gene_table <- S4_GeneTPM[which(S4_GeneTPM$QTL_ID == QYRID),c(2,5,6,3,4,7)]
    colnames(out_gene_table) <- c("GeneID","Chromosome","Length","Start","End","Annotation")
    
    return(out_gene_table)
}
