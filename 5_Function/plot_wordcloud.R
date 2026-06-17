# # 词云图
# # 输入df，第一列是标签，第二列是值
# data_home_wordcloud <- read_rds("3_Data/RDataBase/data_home_wordcloud.rds")
# data_home_wordcloud$color <- replicate(335, {
#     rgb(runif(1), runif(1), runif(1))
# })
# 
# plot_wordcloud_out <- data_home_wordcloud %>% 
#         e_charts() %>% 
#         e_cloud(word = Gene, freq = Freq,color=color,shape = '',sizeRange = c(4, 15)) %>%
#         e_tooltip(
#             formatter = htmlwidgets::JS("
#       function(params) {
#         return 'Gene：' + params.name + '<br>' +
#                'Usage：' + (params.value * 100).toFixed(2) + '%';
#       }
#     ")
#         ) %>% 
#   e_grid(left = "0%", right = "0%", top = "0%", bottom = "0%")
# 
