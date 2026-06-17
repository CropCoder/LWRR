#!/usr/local/bin/Rscript
# VCF Export Tools 基因型变异数据批量提取工具，快捷提取VCF文件
# 依赖软件：Python、bcftools、tidyverse、snpeff

suppressPackageStartupMessages(library("cli"))
suppressPackageStartupMessages(library("tidyverse"))
cli::cli_text("########## WelCome to VCF Export Tools ###########
 \n >>>>>>>>>>>>>>>> Design By Jewel <<<<<<<<<<<<<<<<<
 \n可选参数：
 \n\t[1]根据基因ID提取变异数据
 \n\t[2]根据物理位置提取变异数据
 \n\t[3]根据样品名称提取变异数据
 \n\t[4]根据SNP名称提取变异数据
 \n--------------------------------------------------
 \n[INFO]第一个参数填选项，第二个参数填项目备注名称
 \n[INFO]第三个参数选择是否过滤样本，Y为过滤指定样本
 \n[INFO]第四个参数为'Y'时将对vcf文件进行变异结构注释
 \n[INFO]例如 $ ./run.R 1 test Y Y
 \n
 \n>>>>>>>>>>>>>>>> 程序版本：V 2.0.2 <<<<<<<<<<<<<<<<
 \n ##################################################")

args <- commandArgs(T)
if(length(args)!=4){stop("参数输入有误，请检查输入格式，示例“./run_Mod_Job_Sample_Eff.R 1 jobname Y/N Y/N")}
# CONFIG SETTING:
db_file <- "2084.AABBDD.SnpSift.addID.maf0005.bialleles.eff.vcf.gz" # 设置数据库名称
db_name <- "WGS_2084"

# 程序初始化，删除上次输出结果文件----------
OPT <- args[1] # 程序子选项
JOB <- args[2] # 项目备注信息
SAM <- args[3] # 是否过滤样本
EFF <- args[4] # 是否结构注释

print(str_c("INFO   当前选择的数据库为：",db_file))
print(str_c("INFO   当前项目名称为： ",OPT," <-> ",JOB))
#print(str_c("INFO   是否对样品进行过滤（Y为过滤指定样本,否则不过滤）："),SAM)
#print(str_c("INFO   是否对vcf进行结构变异注释（Y为进行注释,否则不注释）："),EFF)
system("rm -rf ./01_out_byGeneID/*")
system("rm -rf ./02_out_byPostion/*")
system("rm -rf ./03_out_bySampleName/*")
system("rm -rf ./04_out_bySNP/*")
system("rm -rf ./05_out_bySnpEff/*")
cli::cli_text("INFO   系统输出文件夹初始化完成")


# 1.根据基因ID提取变异数据 ----
if (OPT == "1"){
  cli::cli_text("INFO   待提取的基因ID如下，将自动自取上下游3000bp内的变异数据")
  id <- read.table("./01_INPUT_GeneID.txt",header = F)
  print(id$V1)
  cli::cli_text("INFO   基因ID信息整理完毕，接下来开始检索物理区间")
  system("Rscript ./00_scripts/prefix_gene_filter.R ./01_INPUT_GeneID.txt")
  cli::cli_text("INFO   接下来执行Python脚本调用bcftools提取基因变异信息")
  system(str_c("~/data_HD/miniconda3/envs/work/bin/python ./00_scripts/bcftools_view_filiter_Chr.py --input ./00_scripts/id.txt --vcf ./",
               db_file))
  
  cli::cli_text("INFO   提取完成，对结果样品筛选")
  if (SAM == "Y"){
    for (i in 1:nrow(id)){
      system(str_c("bcftools view --force-samples -S ",
                   "./03_INPUT_SampleName.txt ",
                   id$V1[i],".vcf.gz > ",
                   id$V1[i],".vcf"))
    }
    system("mv ./Traes*vcf ./01_out_byGeneID/")
    system("rm -rf ./Traes*vcf.gz")
    # system(str_c("tar -czvf ",format(Sys.Date(), "%Y_%m_%d"),"_",JOB,"_ExportFrom_",db_name,
    #              "_LOTSample_Filter_ByGeneID",".tar.gz ./01_out_byGeneID/* ./Tips.pdf"))
  }else{
    system("mv ./Traes*vcf.gz ./01_out_byGeneID/")
    # system(str_c("tar -czvf ",format(Sys.Date(), "%Y_%m_%d"),"_",JOB,"_ExportFrom_",db_name,
    #              "_AllSample_Filter_ByGeneID",".tar.gz ./01_out_byGeneID/* ./Tips.pdf"))
  }
  
  cli::cli_text("INFO   提取完成，对变异信息进行注释")
  if (EFF == "Y"){
    for (i in 1:nrow(id)){
      system(str_c("java -Xmx50000M -jar ~/data_HD/software/snpEff/snpEff.jar wheat ",
                   "./01_out_byGeneID/",
                   id$V1[i],".vcf.gz > ",
                   "./05_out_bySnpEff/",
                   id$V1[i],".vcf"))
      cli::cli_text(str_c("INFO   当前正在注释的基因为：",i))
    }
    system(str_c("tar -czvf ",format(Sys.Date(), "%Y_%m_%d"),"_",JOB,"_ExportFrom_",db_name,
                 "_AllSample_Filter_ByGeneID_SNPeff",".tar.gz ./05_out_bySnpEff/* ./Tips.pdf"))
  }else{
    system(str_c("tar -czvf ",format(Sys.Date(), "%Y_%m_%d"),"_",JOB,"_ExportFrom_",db_name,
                 "_AllSample_Filter_ByGeneID",".tar.gz ./01_out_byGeneID/* ./Tips.pdf"))
  }
  
  
  
  cli::cli_text("INFO   任务运行结束，请及时下载结果文件,下次运行前将清空结果文件")
}

# 2.根据物理位置提取变异数据---------
if (OPT == "2"){
  cli::cli_text("INFO   待提取物理区间如下，正在提取中......")
  region <- read.table("./02_INPUT_Postion.txt",header = F)
  for (i in 1:nrow(region)){
    print(str_c("Index: ",i,"   Region: ",region$V1[i],"   Info: ",region$V2[i]))
    system(str_c("bcftools view --threads 24 "," -r ",region$V1[i]," -Oz -o ",region$V1[i],"_",region$V2[i],".vcf"," ",db_file))
    system("mv chr* ./02_out_byPostion/")
  }
  cli::cli_text("INFO   提取完成，对结果进行打包压缩")

  if (EFF == "Y"){
    for (i in 1:nrow(region)){
      system(str_c("java -Xmx50000M -jar ~/data_HD/software/snpEff/snpEff.jar wheat ",
                   "./02_out_byPostion/",
                   region$V1[i],"_",region$V2[i],".vcf > ",
                   "./02_out_byPostion/",
                   region$V1[i],"_",region$V2[i],"_eff.vcf"))
      cli::cli_text(str_c("INFO   当前正在注释的基因为：",region$V1[i]))
    }
  }else{
      cli::cli_text(str_c("INFO   即将输出结果文件"))
  }
  #system("rename : _ ./02_out_byPostion/*")
  #system("rename - _ ./02_out_byPostion/*")

  system(str_c("tar -czvf ",format(Sys.Date(), "%Y_%m_%d"),"_",JOB,"_ExportFrom_",db_name,
               "_AllSample_Filter_ByPositin",".tar.gz ./02_out_byPostion/* ./Tips.pdf"))
  cli::cli_text("INFO   任务运行结束，请及时下载结果文件,下次运行前将清空结果文件")
}

# 3.根据样品名称筛选vcf文件-----



# 4.根据变异位点的名称提取变异数据--------
if (OPT == "4"){
  cli::cli_text("INFO   待提取位点信息如下，正在提取中......")
  snp_ids <- read.table("./04_INPUT_SNP.txt",header = F)
  system(str_c(
    "vcftools","--gzvcf",db_file,
    "--snps","04_INPUT_SNP.txt",
    "--recode","--out",str_c(format(Sys.Date(), "%Y_%m_%d"),"_",JOB,"_ExportFrom_",db_name,
                             "_AllSample_By_SNP.vcf")
  ))
}
