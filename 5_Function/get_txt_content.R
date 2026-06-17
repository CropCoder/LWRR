# 获取GWAS rMVP 日志
getFileContent <- function(file_path) {
    if (file.exists(file_path)) {
        content <- readLines(file_path, warn = FALSE)
        paste(content, collapse = "\n")
    } else {
        "File not found."
    }
}