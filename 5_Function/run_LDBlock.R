run_LDBlock <- function(file_vcf,userUID){

        dir.create(paste0("www/OUT/",userUID,"/LDBlock_Result/"))

        df_vcf_map <- read.table(str_c("www/OUT/",userUID,"/SGAT_OUT/MVP_Data.geno.map"),head=TRUE)

        mychr <- unique(df_vcf_map$CHROM)
        mystat <- min(df_vcf_map$POS)
        myend <- max(df_vcf_map$POS)

        system(str_c(sep=" ",
        "/app/build/LDBlockShow-1.40/bin/LDBlockShow",
        "-InVCF",file_vcf,
        "-Region",paste0(mychr,":",mystat,"-",myend),
        "-SeleVar 4 -TopSite",
        "-NoShowLDist 5000000",
        "-OutPut",paste0("www/OUT/",userUID,"/LDBlock_Result/ld_block_result")
        ))

        system(str_c(sep = " ",
                 "/app/build/LDBlockShow-1.40/bin/ShowLDSVG",
                 "-InPreFix",paste0("www/OUT/",userUID,"/LDBlock_Result/ld_block_result"),
                 "-OutPut",paste0("www/OUT/",userUID,"/LDBlock_Result/ld_block_result_fix"),
                 "-crBegin 75,176,116 -crMiddle 33,138,140  -crEnd 53,71,108",
                 # "-OutPdf",
                 "-TopSite",
                 "-Cutline", 7,
                 "-NoShowLDist",700681000
        ))

        system(paste0("gunzip -c www/OUT/",userUID,"/LDBlock_Result/ld_block_result.blocks.gz > www/OUT/",userUID,"/LDBlock_Result/ld_block_result.blocks"))

}