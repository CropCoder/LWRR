plot_Gene_Structure <- function(gff,size=4,lcolor="black"){
    names(gff) = c("chr","source","type","start","end","score","strand","phase","attributes")
    chr = unique(gff$chr)
    strand = unique(gff$strand)
    a = filter(gff,type == "gene")$attributes
    desc = strsplit(a,split = ";")%>%unlist(.)
    tpm1 = filter(gff,type == "exon")
    tpm3 = filter(gff,type == "five_prime_UTR"| type == "three_prime_UTR")
    if (strand == "-"){
        tpm2 = data.frame(type = paste(tpm1$type,seq(1:nrow(tpm1)),sep = ""),
                          end = tpm1$start,
                          start = tpm1$end,
                          y = 1)
        xend = tpm2$end[1]-100
    } else {
        tpm2 = data.frame(type = paste(tpm1$type,seq(1:nrow(tpm1)),sep = ""),
                          start = tpm1$start,
                          end = tpm1$end,
                          y = 1)
        xend = tpm2$end[1]+100
    }
    p <-  ggplot(tpm2,aes(x = start,y = y))+
        geom_segment(aes(x = tpm2$start[1],y = 0, xend = tpm2$end[nrow(tpm2)], yend = 0),
                     color = lcolor)+
        geom_segment(data = tpm2,
                     mapping = aes(x = start,xend = end,y = 0, yend = 0,color = type),
                     size = size)+
        geom_segment(aes(x = tpm2$end[1],y = 0, xend = xend, yend = 0),
                     arrow = arrow(length = unit(0.2,"cm")),
                     color = "red")+
        xlab(chr)+
        ggplot2::theme(
            axis.ticks.y.left = element_blank(),
            axis.ticks.y = element_blank(),
            axis.line.y = element_blank(),
            axis.line.x.top = element_blank(),
            panel.grid = element_blank(),
            axis.text.y = element_blank(),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title.y = element_blank(),
            axis.line = element_line(colour = "black",size = 1),
            legend.position = "none"
        )
    
    if(nrow(tpm3) != 0){
        p = p +
            geom_segment(data = tpm3,
                         mapping = aes(x = start,xend = end,y = 0, yend = 0),
                         size = size,
                         color = "grey")
    } else {
        p = p
    }
    return(p)
}