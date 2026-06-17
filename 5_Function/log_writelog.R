write_log <- function(logtxt){
    write.table(
        str_c(
            "[AutoLog System] ",Sys.time()," >>>> ",logtxt
        ),file = str_c("9_log/",Sys.Date(),"-log.txt"),quote = F,row.names = F,col.names = F,append = T
    )
    cat(
        str_c(
            "[AutoLog System] ",Sys.time()," >>>> ",logtxt,"\t"
        )
    )
}
