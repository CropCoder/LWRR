##########################################################
## Copyright (c) NWAFU Wheat Bioincloud.lab 2022-2025
##      Project: Landscape
##  Description: boxplot
##         Date: 2024.6.28
##       Author: Jewel ( zaojewin@icloud.com )
##      Version: 1.0.0
##          web: https://www.Filll.cn
##       Github: https://Github.com/BioJewel
##########################################################

plot_boxplot_phe_home <- function(df){
    
    df_plot <- as.data.frame(df)
    
    p <- ggplot(df_plot,aes(x=type,y=value))+
        geom_jitter(alpha = 0.8,position = position_jitter(0.2), 
                    aes(color = type)) +
        geom_boxplot(aes(fill = type),alpha = 0.1,position=position_dodge(1.2))+
        scale_fill_manual(values = c("#51cf66",
                                     "#ffd43b"))+
        scale_color_manual(values = c("#51cf66",
                                      "#ffd43b"))+
        geom_signif(comparisons = list(c("0/0","1/1")),
                    map_signif_level = function(p) sprintf("P = %.2g", p),
                    test = t.test,
                    tip_length = 0.05,
                    textsize = 5 ,
                    vjust = -0.5,
                    y_position = 10,
                    step_increase=0.2)+
        ylab("Trait value")+
        xlab("")+
        ylim(0,11)+
        facet_wrap(~Trait,nrow = 1)+
        theme_bw()
    return(p)
}


