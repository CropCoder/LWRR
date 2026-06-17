# VCF input fix function
get_vcf_df <- function(myfile = "www/download/Example_GeneType.filter.vcf"){
    df_vcf <- read.vcfR(myfile)
    df_out <- cbind(df_vcf@fix,df_vcf@gt) %>% as_tibble()
    sample_list <- colnames(df_out)[-c(1:10)]
    SNP_list <- df_out$ID
    
    df_table=df_out[c(1:30),c(1:8)]
    
    return(list(
        df_out=df_out,
        df_table=df_table,
        sample_list=sample_list,
        SNP_list=SNP_list,
        info=paste0("Sample Number:",length(sample_list)," Marker Number:",length(SNP_list))
    ))
}
