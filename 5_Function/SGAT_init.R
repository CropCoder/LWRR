SGAT_init <- function(
        file_vcf="www/download/Example_GeneType.filter.vcf",
        file_phe="www/download/user_upload_trait.tsv",
        userUID="dev_test"){
    dir.create(paste0("www/OUT/",userUID,"/SGAT_OUT"))
    
    
    MVP.Data(fileVCF=file_vcf,
             filePhe=file_phe,
             sep.phe = "\t",
             fileKin=TRUE,
             filePC=TRUE,
             out=paste0("www/OUT/",userUID,"/SGAT_OUT/MVP_Data"),
    )

    
    
    
}


