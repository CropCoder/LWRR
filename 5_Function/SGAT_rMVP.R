
SGAT_rMVP <- function(which_trait="CYR23L",
                      which_model="MLM",
                      userUID="dev_test",
                      mythrehold=0.05,
                      mygeneid="TraesCS1A03G0949800"
                      ){
    
    
    
    genotype <- attach.big.matrix(paste0("www/OUT/",userUID,"/SGAT_OUT/","MVP_Data.geno.desc"))
    phenotype <- read.table(paste0("www/OUT/",userUID,"/SGAT_OUT/","MVP_Data.phe"),head=TRUE)
    map <- read.table(paste0("www/OUT/",userUID,"/SGAT_OUT/","MVP_Data.geno.map") , head = TRUE)
    Kinship <- attach.big.matrix(paste0("www/OUT/",userUID,"/SGAT_OUT/","MVP_Data.kin.desc"))
    
    for(i in which(colnames(phenotype) ==  which_trait)){
        imMVP <- MVP(
            phe=phenotype[, c(1, i)],
            geno=genotype,
            map=map,
            #K=Kinship,
            #CV.GLM=Covariates,
            #CV.MLM=Covariates,
            #CV.FarmCPU=Covariates,
            nPC.GLM=5,
            nPC.MLM=3,
            nPC.FarmCPU=3,
            priority="speed",
            ncpus=1,
            vc.method="BRENT",
            maxLoop=1,
            method.bin="static",
            #permutation.threshold=TRUE,
            #permutation.rep=100,
            threshold=mythrehold,
            method=which_model,
            verbose=F,
            outpath = paste0("www/OUT/",userUID,"/SGAT_OUT"),
            file.output=c("pmap", "pmap.signal", "plot", "log")
        )
        gc()
    }
    
    zip::zip(zipfile = paste0("www/OUT/",userUID,"/SGAT_OUT/",userUID,"_",
                               format(Sys.time(), "%Y-%m-%d_"), # time
                               mygeneid, # str random
                               "_LWDR_SGAT_Result.zip"),
        files = paste0("www/OUT/",userUID,"/SGAT_OUT/",
                c(list.files(paste0("www/OUT/",userUID,"/SGAT_OUT/"),pattern = ".csv"),
                  list.files(paste0("www/OUT/",userUID,"/SGAT_OUT/"),pattern = ".jpg"))
                )
        )
    
    # 绘制曼哈顿图的数据
    data <- vroom(paste0("www/OUT/",userUID,"/SGAT_OUT/",which_trait,".",which_model,".csv"))
    colnames(data) <- c("SNP" ,"CHROM" ,"POS", "REF", "ALT" ,
                        "Effect" ,"SE" ,"P")
    data$P <- -log10(data$P)
    data$POS <- data$POS / 1000000
    
    out_zip_file <- paste0("www/OUT/",userUID,"/SGAT_OUT/",userUID,"_",
           format(Sys.time(), "%Y-%m-%d_"), # time
           mygeneid, # str random
           "_LWDR_SGAT_Result.zip")
    
    return(list(
        out_zip_file=out_zip_file,
        p_mdh_plotly_data=data
        
    ))

}
