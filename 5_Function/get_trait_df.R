# Trait file fix
get_trait_df <- function(myfile="www/download/Example_trait_file.xlsx"){
    df_phe <- read.xlsx(myfile) %>% as.data.frame()
    sample_list <- df_phe$ID
    phe_list <- colnames(df_phe)[-1]
    
    return(list(
        df_phe=df_phe,
        sample_list=sample_list,
        phe_list=phe_list
    ))
    
}
