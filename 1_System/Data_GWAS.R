# https://github.com/techouse/sqlite3-to-mysql


# 读取GWAS结果
df <- vroom("3_Data/GWAS/new_V5Lab.MLM.result.txt",
            col_names = c("SNP","chr","Postion","REF","ALT","eff","p"))

mylist <- read.table("3_Data/GWAS/list.txt") %>% pull(V1) %>% 
    str_replace("new_","") %>% 
    str_replace(".FarmCPU.result.txt","") %>% 
    str_replace(".MLM.result.txt","") %>% 
    unique()

chr_convert <- read.table("3_Data/chr_num2str.txt",header = T)
chr_convert$new <- paste0(chr_convert$atom7,chr_convert$atom3)

for (phe in mylist){
    for (model in c("MLM","FarmCPU")){
        df <- vroom(str_c("3_Data/GWAS/new_",phe,".",model,".result.txt"),
                    col_names = c("SNP","chr","Postion","REF","ALT","eff","p"))
        df$logP <- -log10(df$p)

        df$Postion <- df$Postion / 1000000
        
        for (i in 1:21){
            df$chr[which(df$chr == chr_convert$chr_num[i])] <- chr_convert$new[i]
        }
        
        dbRemoveTable(db,str_c("GWAS.",model,".",phe))
        dbWriteTable(db,str_c("GWAS.",model,".",phe),df)
    }
}


GWAS_MLM_plot <- function(df_GWAS){
    data <- read.table(MLM,header = F)
    colnames(data) <- c("INDEX", "SNP" ,"CHROM" ,"POS", "REF", "ALT" ,
                        "Effect" ,"SE" ,"P")
    
    data$P <- -log10(data$P)
    
    data <- data[which(data$P > min_point),]
    
    data$POS <- data$POS / 1000000
    p4 <- ggplot(data,aes(POS,P))+
        geom_point(aes(color= Effect))+
        scale_color_gradient(low = "#c3fae8",high = "#087f5b")+
        # scale_x_continuous(breaks = c(675:685))+
        ylab("MLM")+
        xlab(str_c("Physical Postion (IWGSC 2.1)"))+
        theme_bw()
    return(p4)
}

ggplot(df,aes(Postion,logP))+
    geom_point(aes(color= eff))+
    scale_color_gradient(low = "#c3fae8",high = "#087f5b")+
    # scale_x_continuous(breaks = c(675:685))+
    ylab("")+
    xlab(str_c("Physical Postion (IWGSC 2.1)"))+
    facet_wrap(~chr,ncol = 3)+
    theme_bw()
