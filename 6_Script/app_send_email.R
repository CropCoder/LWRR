# 发送通知邮件功能脚本
library(keyring)
library(blastula)
library(rmarkdown)

# 创建密钥-只用执行一次即可
# create_smtp_creds_file(file = '~/email_id_Bionote',
#                        user = 'bionote@163.com',
#                        host = 'smtp.163.com',
#                        port = 25,use_ssl = T)
opt <- commandArgs(T)

# 参数说明：
# 收件人
# 姓名
# 作业ID
# 开始时间
# 结束时间
# 作业类型
# 作业数量
# 附件文件名


subject = "【系统提示】重测序数据提取完成" #邮件主题
attachment = "list_gene.txt"  # 附件文档

# 读取模板Rmarkdown文件
template <- readLines("function/report.Rmd")

# 替换模板中的{text}标记

template <- gsub("\\{name\\}", "赵记稳", template)
template <- gsub("\\{job_ID\\}", "adfibadxbciuf165w44e63rf1da", template)
template <- gsub("\\{time_start\\}", Sys.time(), template)
template <- gsub("\\{time_end\\}", Sys.time(), template)
template <- gsub("\\{job_type\\}", "Gene", template)
template <- gsub("\\{job_num\\}", "19", template)


# # 创建新的Rmarkdown文件
output_file <- paste0("function/templete", ".Rmd")
writeLines(template, con = output_file)

body = output_file # 这个Rmd文件渲染后就是邮件的正文

# 定义用户（发件人邮箱）
from = "bionote@163.com"

to = "zhaojiwen@nwafu.edu.cn"

# 添加附件信息
if (attachment == "") {
  render_email(body) -> email
} else {
  render_email(body) %>%
    add_attachment(file = attachment) -> email
}

# 发送邮件
smtp_send(
  from = from,
  to = to,
  subject = enc2utf8(subject),  # 处理中文主题乱码问题
  email = email,
  credentials = creds_file("~/email_id_Bionote")
)




