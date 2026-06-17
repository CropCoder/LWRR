# 需要载入的软件包
library(shiny)
library(shinyalert)
library(shinythemes)
library(shinyWidgets)
library(bslib)
library(bsicons)
library(DT)
library(echarts4r)
library(reactable)
library(plotly)
library(shinyjs)
library(slickR)
library(shinycssloaders)
library(waiter)
library(later)


# 分析类R包
library(tidyverse)
library(data.table)
library(purrrlyr)
library(vroom)
library(openxlsx)
library(vcfR)
library(parallel)
library(scales)
library(ggsignif)
library(markdown)
library(rMVP)
library(zip)
library(R.utils)
library(formattable)
# library(JBrowseR)
library(chromoMap)
library(httr)
library(DBI)
library(RSQLite)
library(jsonlite)
library(ggideogram)
library(ggrepel)
library(pheatmap)
library(ggpubr)

# 不显示警告信息
options (warn = -1)

cli::cli_alert_success(str_c(Sys.time(),"\t依赖程序加载完成"))

# System Set
options(shiny.maxRequestSize = 5 * 1024^2) # 10MB Max upload , Single Gene VCF File

# Load Functiong
folder_path <- "./5_Function"
script_files <- list.files(path = folder_path, pattern = "\\.R$", full.names = TRUE)
for (scr in script_files){source(scr)}

# Load Data

S1_sample <- read_rds("3_Data/RDataBase/S1_sample_info.rds")
S2_QTL_freq <- read_rds("3_Data/RDataBase/S2_QTL_freq.rds")
S3_QTL_GT <- read_rds("3_Data/RDataBase/S3_QTL_GT.rds")
S4_GeneTPM <- read_rds("3_Data/RDataBase/S4_GeneTPM.rds")
S6_QTL_Find_envs <- read_rds("3_Data/RDataBase/S6_QTL_Find_envs.rds")
S8_PCA_df <- vroom("3_Data/S8_Data_PCA.csv",show_col_types = FALSE)
used_pkgs <- read_rds("3_Data/RDataBase/used_pkgs.rds")
chr_size <- read.table("3_Data/CS21_Ref/chrsize.txt",header = T)


cli::cli_alert_success(str_c(Sys.time(),"\t样本信息数据加载完成"))

# Connect SQL db
db <- dbConnect(drv = SQLite(),dbname="SQL_DataBase.db")

cli::cli_alert_success(str_c(Sys.time(),"\t数据库已连接"))

# build search index and vars
search_index_GeneName <- S2_QTL_freq$Gene_name_index %>% 
    str_split(";") %>% unlist() %>% na.omit() %>% as.character()

search_index_QYr <- S2_QTL_freq$QTL_ID
search_index_GeneID <- S4_GeneTPM$Gene_ID
search_index_Sample <- S1_sample$RunID
search_index_CN_name <- S1_sample$NameCN
search_index_EN_name <- S1_sample$Name

index_trait <- colnames(S1_sample)[17:45]
index_trait_selected <- index_trait[1:12]

home_trait_selected <- c("1579B","1561B","1764B","1871B","1866B","1844B","1807B","DXZ284A",
                         "S0120","1622B","S0037","S0096","S0038","S0086","S0032","1744B","S0062")
chr_convert <- read.table("3_Data/chr_num2str.txt",header = T)
chr_convert$new <- paste0(chr_convert$atom7,chr_convert$atom3)
GWAS_Trait_list <- read.table("3_Data/Trait_list_24_HaveGWAS.txt",header = F) %>% pull(V1)

cli::cli_alert_success(str_c(Sys.time(),"\t环境变量加载完成"))


# global value

APP <- "LWRR"
Version <- "4.0"
Developer <- "Jiwen Zhao"
host_url <- "127.0.0.1:3838"
myvcf_file <-  "/app/3_Data/LWRR_2191Sample_9277Gene_Genetype.vcf.gz"



# Load Functiong
mod_path <- "./4_Page/"
mod_files <- list.files(path = mod_path, pattern = "\\.R$", full.names = TRUE)
for (scr in mod_files){source(scr)}

csvDownloadButton <- function(id, filename = "data.csv", label = "Click here to download the data sheet (CSV format, can use Excel to open and edit)") {
  tags$button(
    tagList(icon("download"), label),
    onclick = sprintf("Reactable.downloadDataCSV('%s', '%s')", id, filename),
    style = "
      background: linear-gradient(45deg, #1289a7, #71afe5);
      border: none;
      border-radius: 25px;
      padding: 10px 20px;
      color: white;
      font-weight: bold;
      box-shadow: 0 4px 15px rgba(0,0,0,0.2);
      transition: all 0.3s ease;
    "
  )
}


cli::cli_alert_success(str_c(Sys.time(),"\t函数加载完成加载完成"))

cli::cli_alert_success(str_c(Sys.time(),"\tLWRR启动成功！"))

