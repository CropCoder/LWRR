mod_Gene_UI <- function(id) {
    ns <- NS(id)
    tagList(
        tags$style(
            HTML("
        .progress-bar-inner {
            height: 100%;
            border-radius: 5px;
            transition: width 0.6s ease;  /* 添加过渡效果，让进度条变化更平滑 */
          }
         ")
        ),
        tags$div(
            class = "alert alert-success", role = "alert",
            strong("Tip: "), "The Candidate Gene Information Query page can help you quickly learn basic information about candidate genes and provide access links to other frequently used resources. Features such as nucleic acid diversity in the region surrounding the gene are automatically obtained."
        ),
        h3("Search Gene (Chinese Spring 2.1)"),
        layout_column_wrap(
            1 / 2,
            # Search Gene ----
            card(
                textInputIcon(
                    ns("input_Gene_ID"), "Input Gene ID",
                    value = "TraesCS3B03G0029000",
                    placeholder = "TraesCS3B03G0029000",
                    icon = icon("magnifying-glass"), width = "100%"
                ),
                actionButton(ns("run_Gene"), "Search Gene in Landscape", icon("magnifying-glass"), class = "btn-success m-2")
            ),
            card(
                card_header("Tip"),
                card_body("Wheat is one of the most important grain crops. Currently, the global wheat production is threatened by the potential of wheat stripe rust. The best measure to control wheat stripe rust is to cultivate disease-resistant varieties with excellent resistance to wheat stripe rust.")
            )
        ),

        # gene infomation ----
        h3("Gene Infomation"),
        card(
            reactableOutput(ns("Gene_table"), width = "100%"),
            h5(textOutput(ns("gene_desc"))),
            uiOutput(ns("quicklink"))
        ),

        # JBrowseROutput(ns("Gene_jb"),width = "100%",height = "400px"),

        # which QTL----
        # h3("Changes in gene expression levels before and after inoculation with pathogen"),
        # card(
        #     full_screen = T,
        #     layout_column_wrap(
        #         1/3,
        #         card(
        #             echarts4rOutput(ns("Gene_TPM_Max"), width = "100%", height = "400px")
        #         ),
        #         card(
        #             echarts4rOutput(ns("Gene_TPM_Mean"), width = "100%", height = "400px")
        #         ),
        #         card(
        #             echarts4rOutput(ns("Gene_TPM_Min"), width = "100%", height = "400px")
        #         )
        #     ),
        #     p("Tip: The table above contains the expression of the gene you queried and other genes in the QTL where it is located TPM_CK_Mean indicates the material expression level of uninoculated stripe rust, and TPM_DO_Mean indicates the expression level after inoculated stripe rust.")  
        # ),

        # pi - fst ----
        h3("Selective domestication analysis of 10MB around the gene region"),
        card(
            full_screen = T,
            layout_column_wrap(
                1 / 2,
                list(
                    # Pi ----
                    card(
                        full_screen = T,
                        echarts4rOutput(ns("pop_pi_plot"), width = "100%", height = "400px")
                        # p("This data is based on the results of Structure analysis, and interactive visualization is performed on the data of each group. You can click on the area below the X-axis, select the interval of interest, and obtain corresponding detailed information.")
                    )
                ),
                list(
                    # Fst----
                    card(
                        full_screen = T,
                        echarts4rOutput(ns("pop_fst_plot"), width = "100%", height = "400px")
                        # p("We conducted Fst analysis based on genotype information of two subgroups, Landrace and Cultivar, using a sliding window of 1MB and a step size of 100kb. You can interactively view Fst data at a specified position on a chromosome in the above figure.")
                    )
                )
            ),
            p("The above shows the Pi and Fst of the gene you submitted your query within the surrounding 10Mb region")
        ),
        tags$div(
            class = "alert alert-success", role = "alert",
            strong("Note: "), "The Candidate Gene Information Query page can help you quickly learn basic information about candidate genes and provide access links to other frequently used resources. Features such as nucleic acid diversity in the region surrounding the gene are automatically obtained. Note that this page can only query 9276 genes that belong to QTL candidate regions."
        ),
        h3("The variation sites of the gene region and LDblock plot"),
        card(
            full_screen = T,
            height = "600px",
            layout_column_wrap(
                1 / 2,
                dataTableOutput(ns("gene_vcf")),
                uiOutput(ns("LD_plot"))
            )
        ),
        h3("Variation sites plot"),
        uiOutput(ns("pheat_plot_genesnp")),
        br(),
        actionButton(ns("get_gene_vcf"), "Click here to download the VCF file of the variant sites in 2191 samples"),
        br(),
        br(),
        tags$div(
            class = "alert alert-success", role = "alert",
            strong("Note："), "The above image extracts variation sites according to the genes you select, and then shows the distribution of variation sites at the population level through heat maps, with green and blue representing the two allelic types respectively. The heat map is clustered according to the sample, each row is a sample, each column is a mutation site."
        )
        # h3(""),
        # card(
        #     full_screen = T,
        #     radioButtons(
        #         inputId = ns("select_Phe"),
        #         inline = T,
        #         label = "Please select a phenotype to view:",
        #         choices = colnames(S1_sample)[17:42],
        #         selected = colnames(S1_sample)[35]
        #     ),
        #     layout_column_wrap(
        #         1 / 2,
        #         card(
        #             DTOutput(ns("out_DT"))
        #         ),
        #         card(
        #             uiOutput(ns("plotly_phe_hap_box"))
        #         )
        #     )
        # )
    )
}

mod_Gene_Server <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            # 创建响应值- 默认
            react_vals <- reactiveValues(Gene = "TraesCS3B03G0029000")

            # 点击后更新响应值
            observeEvent(input$run_Gene, {
                react_vals$Gene <- input$input_Gene_ID
            })

            # 观察URL参数变化
            observe({
                # 获取URL中的查询参数
                query <- parseQueryString(session$clientData$url_search)

                # 如果URL包含名为'Gene'的参数，则更新文本输入框的内容
                if (!is.null(query$Gene)) {
                    react_vals$Gene <- query$Gene
                    input_gene <- query$Gene
                    updateTextInputIcon(session = session, "input_Gene_ID", value = input_gene)
                }
            })

            observe({
                # 单个基因查询结果
                Gene_Search_out <- get_Search_Gene(react_vals$Gene)

                # Gene_table-----
                output$Gene_table <- renderReactable({
                    data <- Gene_Search_out$gene_data
                    data <- data[1, c(-2, -7)]
                    colnames(data) <- c("GeneID", "Start", "End", "Chrome", "GeneLength")
                    reactable(data)
                })

                output$gene_desc <- renderText(
                    paste0("👀 Gene Annotation  Description: ", Gene_Search_out$gene_data[1, 7])
                )


                # TPM----
                # output$QTL_genes_TPM <- renderReactable({
                #     myQTL <- dbGetQuery(db, str_c(
                #         "SELECT `QTL_ID` FROM S4GeneTPM WHERE `Gene_ID` = '", react_vals$Gene, "'"
                #     ))

                #     data <- dbGetQuery(db, str_c(
                #         "SELECT * FROM S4GeneTPM WHERE `QTL_ID` = '", myQTL, "'"
                #     ))

                #     data$TPM_CK_Mean <- as.numeric(data$TPM_CK_Mean) %>% round(3)
                #     data$TPM_DO_Mean <- as.numeric(data$TPM_DO_Mean) %>% round(3)

                #     # CK
                #     create_progress_bar_CK <- function(value) {
                #         max_value <- max(c(data$TPM_CK_Mean, data$TPM_DO_Mean), na.rm = TRUE) # 获取该列的最大值（忽略NA值），用于计算比例，你可以根据实际情况修改数据源获取最大值的方式
                #         width_percentage <- value / max_value * 100
                #         bar_style <- paste0("width: ", width_percentage, "%; background-color: #add8e6;") # 使用浅蓝色#add8e6作为进度条颜色，设置宽度占比
                #         tagList(
                #             tags$div(
                #                 style = "display: flex; align-items: center;", # 使用flex布局，让数值和进度条垂直居中对齐
                #                 tags$div(
                #                     style = "width: 100%; height: 15px; border-radius: 5px; background-color: #f0f0f0; overflow: hidden;", # 外层灰色背景条，设置圆角和溢出隐藏，使其更美观
                #                     tags$div(
                #                         style = bar_style, class = "progress-bar-inner", # 浅蓝色进度条部分，添加类名方便后续进一步样式调整（可选）
                #                         role = "progressbar",
                #                         `aria-valuenow` = value,
                #                         `aria-valuemin` = 0,
                #                         `aria-valuemax` = max_value
                #                     )
                #                 ),
                #                 tags$span(
                #                     style = "margin-right: 0px;", # 给数值与进度条之间添加一点间距
                #                     value # 直接显示数值
                #                 )
                #             )
                #         )
                #     }

                #     # DO
                #     create_progress_bar_DO <- function(value) {
                #         max_value <- max(c(data$TPM_CK_Mean, data$TPM_DO_Mean), na.rm = TRUE) # 获取该列的最大值（忽略NA值），用于计算比例，你可以根据实际情况修改数据源获取最大值的方式
                #         width_percentage <- value / max_value * 100
                #         bar_style <- paste0("width: ", width_percentage, "%; background-color: #eccc68;") # 使用浅蓝色#add8e6作为进度条颜色，设置宽度占比
                #         tagList(
                #             tags$div(
                #                 style = "display: flex; align-items: center;", # 使用flex布局，让数值和进度条垂直居中对齐
                #                 tags$div(
                #                     style = "width: 100%; height: 15px; border-radius: 5px; background-color: #f0f0f0; overflow: hidden;", # 外层灰色背景条，设置圆角和溢出隐藏，使其更美观
                #                     tags$div(
                #                         style = bar_style, class = "progress-bar-inner", # 浅蓝色进度条部分，添加类名方便后续进一步样式调整（可选）
                #                         role = "progressbar",
                #                         `aria-valuenow` = value,
                #                         `aria-valuemin` = 0,
                #                         `aria-valuemax` = max_value
                #                     )
                #                 ),
                #                 tags$span(
                #                     style = "margin-right: 0px;", # 给数值与进度条之间添加一点间距
                #                     value # 直接显示数值
                #                 )
                #             )
                #         )
                #     }

                #     reactable(
                #         data[, c(2, 13, 16)] %>% arrange(-TPM_DO_Mean),
                #         columns = list(
                #             TPM_CK_Mean = colDef(
                #                 cell = function(value) {
                #                     create_progress_bar_CK(value)
                #                 }
                #             ),
                #             TPM_DO_Mean = colDef(
                #                 cell = function(value) {
                #                     create_progress_bar_DO(value)
                #                 }
                #             )
                #         )
                #     )
                # })

                # quick link ----
                # TGT共线性链接
                # http://wheat.cau.edu.cn/TGT/m26/?navbar=Homologues&orth_query=IWGSCv2p1&orth_geneID_list=TraesCS2A03G1353200&orth_group=1&orth_subject_one=IWGSCv1p1
                # wGRN
                # http://wheat.cau.edu.cn/wGRN/?navbar=Search&geneID=TraesCS2A03G1353200
                # wheatomics
                # https://wheatomics.sdau.edu.cn/cgi-bin/geneDetail.py?search=TraesCS2A03G1353200
                # esmbl
                # https://plants.ensembl.org/Triticum_aestivum/Gene/Summary?g=TraesCS3D02G273600;r=3D:379535906-379539827;t=TraesCS3D02G273600.1;db=core

                output$quicklink <- renderUI({
                    div(
                        h5(str_c("🔗 Quick links of ", react_vals$Gene, " : ")),
                        tags$a(href = str_c(
                            "http://wheat.cau.edu.cn/TGT/m26/?navbar=Homologues&orth_query=IWGSCv2p1&orth_geneID_list=", react_vals$Gene, "&orth_group=1&orth_subject_one=IWGSCv1p1"
                        ), target = "_blank", tags$img(src = "fig/quicklink/TGT.svg", class = "home-card", style = "height: 50px; width: auto;")),
                        tags$a(href = str_c(
                            "http://wheat.cau.edu.cn/wGRN/?navbar=Search&geneID=", react_vals$Gene
                        ), target = "_blank", tags$img(src = "fig/quicklink/wGRN.svg", class = "home-card", style = "height: 50px; width: auto;")),
                        tags$a(href = str_c(
                            "http://202.194.139.32/cgi-bin/geneDetail.py?search=", react_vals$Gene
                        ), target = "_blank", tags$img(src = "fig/quicklink/wheatomics.svg", class = "home-card", style = "height: 50px; width: auto;")),
                        tags$a(href = str_c(
                            "https://ensembl.gramene.org/Triticum_aestivum/Location/View?db=core;r=", Gene_Search_out$chr, ":", Gene_Search_out$start - 100, "-", Gene_Search_out$end + 100
                        ), target = "_blank", tags$img(src = "fig/quicklink/ensembl.svg", class = "home-card", style = "height: 50px; width: auto;")),
                    )
                })

                # # Gene Expression ----
                # output$Gene_TPM_Max <- renderEcharts4r({
                #     data <- dbGetQuery(db, str_c(
                #         "SELECT * FROM S4GeneTPM WHERE `Gene_ID` = '", react_vals$Gene, "'"
                #     ))

                #     df_TPM <- data[1,c(14,17)]
                #     colnames(df_TPM) <- c("CK","YR")
                #     df_TPM <- pivot_longer(df_TPM,cols = 1:2,names_to = "Type",values_to = "TPM")
                #     df_TPM %>%
                #         e_charts(Type) %>%
                #         e_bar(TPM, itemStyle = list(color = list(
                #             type = 'linear',
                #             x = 0, y = 0, x2 = 0, y2 = 1,
                #             colorStops = list(
                #                 list(offset = 0, color = '#16a085'),   # 颜色在 0% 处
                #                 list(offset = 1, color = 'white')   # 颜色在 100% 处
                #             )
                #         ))) %>% 
                #         e_y_axis(min = 0) %>%
                #         e_legend(show = FALSE)

                # })

                # output$Gene_TPM_Mean <- renderEcharts4r({
                #     data <- dbGetQuery(db, str_c(
                #         "SELECT * FROM S4GeneTPM WHERE `Gene_ID` = '", react_vals$Gene, "'"
                #     ))

                #     df_TPM <- data[1,c(13,16)]
                #     colnames(df_TPM) <- c("CK","YR")
                #     df_TPM <- pivot_longer(df_TPM,cols = 1:2,names_to = "Type",values_to = "TPM")
                #     df_TPM %>%
                #         e_charts(Type) %>%
                #         e_bar(TPM, itemStyle = list(color = list(
                #             type = 'linear',
                #             x = 0, y = 0, x2 = 0, y2 = 1,
                #             colorStops = list(
                #                 list(offset = 0, color = '#27ae60'),   # 颜色在 0% 处
                #                 list(offset = 1, color = 'white')   # 颜色在 100% 处
                #             )
                #         ))) %>% 
                #         e_y_axis(min = 0) %>%
                #         e_legend(show = FALSE)

                # })

                # output$Gene_TPM_Min <- renderEcharts4r({
                #     data <- dbGetQuery(db, str_c(
                #         "SELECT * FROM S4GeneTPM WHERE `Gene_ID` = '", react_vals$Gene, "'"
                #     ))

                #     df_TPM <- data[1,c(12,15)]
                #     colnames(df_TPM) <- c("CK","YR")
                #     df_TPM <- pivot_longer(df_TPM,cols = 1:2,names_to = "Type",values_to = "TPM")
                #     df_TPM %>%
                #         e_charts(Type) %>%
                #         e_bar(TPM, itemStyle = list(color = list(
                #             type = 'linear',
                #             x = 0, y = 0, x2 = 0, y2 = 1,
                #             colorStops = list(
                #                 list(offset = 0, color = '#2980b9'),   # 颜色在 0% 处
                #                 list(offset = 1, color = 'white')   # 颜色在 100% 处
                #             )
                #         ))) %>% 
                #         e_y_axis(min = 0) %>%
                #         e_legend(show = FALSE)

                # })

                # "http://wheat.cau.edu.cn/wGRN/JBrowse/?
                # loc=chr2A%3A782486941..782495717&
                # amp;tracks=wGRN_v1%2CCS_seedling_Dnase-seq_SRR13308319%2CH3K27me3_tissue_CS-Flag%2CH3K4me3_tissue_CS-Flag%2Cleaf_15_DPA_flag_leaf_SRR3068477&
                # amp;tracklist=0&
                # amp;nav=0&
                # amp;overview=0"></iframe>

                mychr <- Gene_Search_out$chr
                mystart <- (Gene_Search_out$start) / 1000000 - 5
                myend <- (Gene_Search_out$end) / 1000000 + 5

                output$pop_pi_plot <- renderEcharts4r({
                    which_chr <- str_c("Chr", mychr)
                    mystart <- as.numeric(mystart)
                    myend <- as.numeric(myend)

                    data <- dbGetQuery(db, str_c(
                        "SELECT * FROM PopBGPi WHERE Chr == '", which_chr, "' AND Pos > ", mystart, " AND Pos < ", myend
                    ))

                    data %>%
                        e_charts(Pos) %>% # 指定横轴
                        e_line(BG1, name = "BG1", symbol = "none") %>% # 绘制BG1折线
                        e_line(BG2, name = "BG2", symbol = "none") %>% # 绘制BG2折线
                        e_line(BG3, name = "BG3", symbol = "none") %>% # 绘制BG3折线
                        e_line(BG4, name = "BG4", symbol = "none") %>% # 绘制BG4折线
                        e_line(LC, name = "LC", symbol = "none") %>% # 绘制BG4折线
                        e_line(NLC, name = "NLC", symbol = "none") %>% # 绘制BG4折线
                        e_legend(orient = "", left = "right", y = "center") %>%
                        e_mark_line(data = list(xAxis = round((Gene_Search_out$start) / 1000000, 0)), title = react_vals$Gene) %>%
                        e_y_axis(min = 0) %>%
                        e_title(str_c("Pi :", react_vals$Gene), x = "center") %>%
                        e_x_axis(
                            name = "Mb", # 设置横轴名称
                            boundaryGap = FALSE, # 数据点直接位于坐标轴上
                            min = "dataMin" # 将横轴最小值设置为数据的最小值
                        ) %>%
                        e_datazoom(type = "slider") %>%
                        e_tooltip(trigger = "axis", formatter = htmlwidgets::JS("
    function(params) {
      var xValue = params[0].name;  // 获取 x 轴的值
      var tooltipText = 'Detail : (Pos,Value)' + '<br/>';  // 显示当前位置

      // 遍历每个分组的值
      params.forEach(function(item) {
        tooltipText += item.seriesName + ': ' + item.value + '<br/>';
      });

      return tooltipText;
    }
  "))   
                })

                # Fst ----
                output$pop_fst_plot <- renderEcharts4r({
                    which_chr <- str_c("Chr", mychr)
                    mystart <- as.numeric(mystart)
                    myend <- as.numeric(myend)

                    data <- dbGetQuery(db,  str_c(
                        "SELECT * FROM PopBGFst WHERE Chr == '", which_chr, "' AND Pos > ", mystart, " AND Pos < ", myend
                    ))

                    data %>%
                        e_charts(Pos) %>% # 指定横轴
                        e_line(BG1RvsLC, name = "BG1R", symbol = "none") %>% # 绘制BG1折线
                        e_line(BG2RvsLC, name = "BG2R", symbol = "none") %>% # 绘制BG2折线
                        e_line(BG3RvsLC, name = "BG3R", symbol = "none") %>% # 绘制BG3折线
                        e_line(BG4RvsLC, name = "BG4R", symbol = "none") %>% # 绘制BG4折线
                        e_line(NLCRvsLC, name = "NLCR", symbol = "none") %>% # 绘制BG4折线
                        e_legend(orient = "", left = "right", y = "center") %>%
                        e_mark_line(data = list(xAxis = round((Gene_Search_out$start) / 1000000, 0)), title = react_vals$Gene) %>%
                        e_y_axis(min = 0) %>%
                        e_title(str_c("Fst :", react_vals$Gene), x = "center") %>%
                        e_x_axis(
                            name = "Mb", # 设置横轴名称
                            boundaryGap = FALSE, # 数据点直接位于坐标轴上
                            min = "dataMin" # 将横轴最小值设置为数据的最小值
                        ) %>%
                        e_datazoom(type = "slider") %>%
                        e_tooltip(trigger = "axis", formatter = htmlwidgets::JS("
    function(params) {
      var xValue = params[0].name;  // 获取 x 轴的值
      var tooltipText = 'Fst Detail : (Pos,Value)' + '<br/>';  // 显示当前位置

      // 遍历每个分组的值
      params.forEach(function(item) {
        tooltipText += item.seriesName + ': ' + item.value + '<br/>';
      });

      return tooltipText;
    }
  "))
                })

                # gene_vcf ----

                out_gene_vcf <- get_gene_vcf(react_vals$Gene, input$select_Phe)

                output$gene_vcf <- renderDataTable({
                    out_gene_vcf$out_vcf %>% as.data.frame()
                })

                output$LD_plot <- renderUI({
                    tags$img(src = as.character(out_gene_vcf$LD_plot), width = "100%")
                })

                output$pheat_plot_genesnp <- renderUI({
                    tags$img(src = as.character(out_gene_vcf$pheat_plot), width = "100%")
                })
                
                observeEvent(input$get_gene_vcf,{
                    shinyalert(
                        title = "Download link",
                        text = str_c("https://wheat.dftianyi.com/TMP/", react_vals$Gene, ".vcf"),
                        type = "success",
                    )
                })

                # output$out_DT <- renderDataTable({
                #     out_gene_vcf$out_DT
                # })

                # output$plotly_phe_hap_box <- renderUI({
                #     tags$img(src = as.character(out_gene_vcf$plotly_phe_hap_box), width = "100%")
                # })


                # wheatOmics----
                # output$wheatomics_vcf <- renderUI({
                #     list(
                #         HTML(str_c(
                #             "<iframe src='http://202.194.139.32/jbrowse-1.12.3-release/?",
                #             "data=Chinese_Spring2.1&loc=chr", Gene_Search_out$chr, "%3A", Gene_Search_out$start - 500, "..", Gene_Search_out$end + 500, "&",
                #             "tracklist=0&nav=0&overview=0&",
                #             "tracks=DNA%2CIWGSCv2.1_annotation%2Cwgs2191&highlight=", Gene_Search_out$chr, "%3A", Gene_Search_out$start - 500, "..", Gene_Search_out$end + 500, "'",
                #             " width='100%' height='500px'></iframe>"
                #         ))
                #     )
                # })
            })
        }
    )
}
