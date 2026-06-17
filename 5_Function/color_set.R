# 函数生成颜色渐变
generate_colors <- function(values) {
    rescale_values <- rescale(values, to = c(0, 1))
    colors <- col_numeric("Blues", domain = NULL)(rescale_values)
    return(colors)
}


generate_random_colors <- function(n) {
    colors <- grDevices::rainbow(n)
    return(colors)
}
