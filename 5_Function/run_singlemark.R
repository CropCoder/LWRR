run_singlemark <- function(file_vcf,file_phe,userUID,select_phe){

file_vcf <- file_vcf
file_phe <- file_phe
userUID <- userUID


dir.create(paste0("www/OUT/",userUID,"/Single_Marker_Result/"))

df_phe <- read.xlsx(file_phe)
df_phe <- df_phe[,c(1,which(colnames(df_phe) == select_phe))]
tran_df <- t(df_phe) %>% as.data.frame()
tran_df <- cbind(rownames(tran_df),tran_df)

write_tsv(tran_df,paste0("www/OUT/",userUID,"/Single_Marker_Result/","single_mark_translate_trait.tsv"),col_names = F)


system(str_c(sep=" ",
  "python3 6_Script/single.marker.analysis.py",
  "--phe",paste0("www/OUT/",userUID,"/Single_Marker_Result/","single_mark_translate_trait.tsv"),
  "--vcf",file_vcf,
  "--out",paste0("www/OUT/",userUID,"/Single_Marker_Result/single_mark_result_",select_phe,".txt")
))

df_out <- read_tsv(paste0("www/OUT/",userUID,"/Single_Marker_Result/single_mark_result_",select_phe,".txt"))
df_out <- df_out[,c(2:5)]
write.xlsx(df_out,paste0("www/OUT/",userUID,"/Single_Marker_Result/single_mark_result_",select_phe,".xlsx"))

df_out$log10Pvalue <- -log10(df_out$Pvalue)

bar_plot <- echarts4r::e_charts(df_out,x = Vatiant_ID) %>% 
  e_bar(log10Pvalue) %>% 
  e_tooltip(trigger = "axis") %>% 
  e_title("Single Marker Analysis Result",x="center") %>% 
  e_legend(FALSE) %>% 
  e_datazoom(type = "slider") %>%
  e_x_axis(name = "Variant (SNP)",
           dataZoom = list(show = TRUE)) %>%
  e_y_axis(name = "-log10(Pvalue)")


return(
  list(
    df_out = df_out,
    bar_plot = bar_plot,
    file_excel = paste0("www/OUT/",userUID,"/Single_Marker_Result/single_mark_result_",select_phe,".xlsx")
  )
)
}
