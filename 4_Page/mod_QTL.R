mod_QTL_UI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(class = "alert alert-success", role = "alert",
               strong("Tip: "), "You can search for a particular QTL of interest on this page and get the corresponding information,the landscape contains a total of 431 QTLs."),
    h3("Overall Quick View (Explore QTL information of wheat rust resistance)"),
    card(
        full_screen = T,
        withSpinner(chromoMapOutput(ns("QTL_map"),height = 500)),
        tags$div(class = "alert alert-success", role = "alert",
                 strong("📌 "), "The above is the distribution of different QTLs on chromosomes. Green indicates the location of QTLs. You can click on a QTL with the mouse and jump to the corresponding QTL detailed page in the prompt box. The following figure shows the distribution of QTLS on 21 chromosomes. The green site is the QTL for rust resistance. You can click the green area with the mouse for detailed information"),
        withSpinner(reactableOutput(ns("home_table_QTL"),width = "100%"))
    ),
    shinyjs::useShinyjs(),
    div(id = "check_QTL",  # 这是锚点位置
        h3("Search QTL information online")
    ),
    
    layout_column_wrap(
        1/2,
        card(
            textInputIcon(
                ns("input_QTL_ID"),"Find the QTL ( Example : Yr30、QYr.nw008、QYr.wgp11)",value = "Yr30",placeholder = "Yr30",icon = icon("magnifying-glass"),width = "100%"
            ),
            actionButton(ns("run_search_QTL"),"Search QTL in Ladnscape", icon("magnifying-glass"), class = "btn-success m-2")
        ),
        card(
            card_header("Tip"),
            card_body("Wheat is one of the most important grain crops. Currently, the global wheat production is threatened by the potential of wheat stripe rust. The best measure to control wheat stripe rust is to cultivate disease-resistant varieties with excellent resistance to wheat stripe rust.")
        )
    ),
    card(
        h4(textOutput(ns("home_box_ID"))),
        markdown(textOutput(ns("home_box_index"))),
        textOutput(ns("home_box_pos")),
        textOutput(ns("home_box_know_gene")),
        textOutput(ns("home_box_QTL_size")),
        reactableOutput(ns("search_line_table"),width = "100%")
    ),
    
    h3("The genotype frequency variation of this QTL"),
    reactableOutput(ns("search_QTL_genetype_table"),width = "100%"),
    br(),
    layout_column_wrap(
        1/3,
        card(
            card_header("The number of samples of different alleles"),
            echarts4rOutput(ns("home_search_pie_GT"),height = "300")
        ),
        card(
            card_header("Diversity between breeding times"),
            echarts4rOutput(ns("home_search_line_plot"),height = "300")
        ),
        card(
            card_header("Diversity between breeding region"),
            echarts4rOutput(ns("home_search_bar_plot"),height = "300")
        )
    ),
    
    h3("Samples containing Resistance alleles in this QTL"),
    card(
        tags$div(class = "alert alert-success", role = "alert",
                   strong("❓ "), "According to the genotype information of variation loci at population level and phenotypic data of different samples, the material information of alleles of disease resistance types was comprehensively analyzed and calculated to provide reference for breeding researchers."),
        reactableOutput(ns("home_search_out_reactable"),width = "100%")
    ),
    h3("Phenotypic box-and-line plot showing different genotypes"),
    tags$div(class = "alert alert-success", role = "alert",
             strong("❓ "), "In order for you to quickly understand the impact of this QTL on the phenotype, the following provides a phenotype analysis statistical function, you can select a phenotype, and then see the difference between the different types of this QTL"),
    card(
        checkboxGroupInput(
                inputId = ns("box_select_phe"), 
                inline = T, 
                label = "Please select a phenotype:", 
                choices = colnames(S1_sample)[17:42],
                selected = colnames(S1_sample)[c(17,18,20,25,35,42)]
        ),
        full_screen = T,
        plotOutput(ns("home_search_phe_boxplot")),
        card_footer("Tip: if you need to know more information about the phenotypes, please click on the Trait function for detailed analysis.")
    )

    # 隐藏信息
    # h3("The gene information corresponding to this QTL"),
    # card(
    #     full_screen = T,
    #     DTOutput(ns("QTL_include_gene")),
    #     height = 590
    # )
    

  )
}

mod_QTL_Server <- function(id) {
    
  moduleServer(
    id,
    function(input, output, session) {
        
        #QTL-map----
        output$QTL_map <- renderChromoMap({
            chr_file_1 <- "3_Data/CS21_Ref/chromeMap_chr_data.txt"
            anno_file_1 <- "3_Data/chromap_QTL_anno.txt"
            chromoMap(chr_file_1,anno_file_1,
                      interactivity = T,
                      data_type = "categorical",
                      chr_length = 11,
                      chr_width = 10,
                      chr_color = "gray",
                      # labels=T,
                      # label_angle = -60,
                      # segment_annotation = T,
                      hlinks=T)
        })
        
        # 首页QTL表格----
        output$home_table_QTL <- renderReactable(
            reactable(S2_QTL_freq[,c(2,3,7,8,6,11,14,21)],
                      # defaultColDef = colDef(
                      #     header = function(value) gsub(".", " ", value, fixed = TRUE),
                      #     cell = function(value) format(value, nsmall = 1),
                      #     align = "center",
                      #     minWidth = 70,
                      #     headerStyle = list(background = "#ddf5eb")
                      # ), 
                      defaultPageSize = 10,
                      # pagination = FALSE,
                      # height = 700,
                      searchable = F,
                      showPageSizeOptions = T,
                      striped = T,
                      bordered = F,
                      highlight = F,
                      filterable = T,
                      columns = list(
                        R_Frequency = colDef(format = colFormat(percent = TRUE, digits = 1)),
                        QTL_ID = colDef(html = TRUE,cell = JS('
                                                            function(cellInfo) {
                                                            // Render as a link
                                                            const url = `./?page=QTL&anchor=check_QTL&QTL_search=${cellInfo.value}`
                                                            return `<a href="${url}" target="_blank">${cellInfo.value}</a>`
                                                            }
                                                        '))
                      )
                      # defaultSortOrder = "desc",
                      # defaultSorted = c("Chinese Name")
            )
        )
        
        
        # 创建响应值- 默认
        user_input_QTL_ID <- reactiveValues(QTL = "Yr30")
        
        # 点击后更新响应值
        observeEvent(input$run_search_QTL, {
            user_input_QTL_ID$QTL = input$input_QTL_ID
        })
        
        # 观察URL参数变化
        observe({
            # 获取URL中的查询参数
            query <- parseQueryString(session$clientData$url_search)
            
            # 如果URL包含名为'QTL'的参数，则更新文本输入框的内容
            if (!is.null(query$QTL_search)) {
                user_input_QTL_ID$QTL = query$QTL_search
                url_QTL <- query$QTL_search
                updateTextInputIcon(session = session,"input_QTL_ID",value = url_QTL)
            }

            if (!is.null(query$anchor)) {  # 检查URL中是否包含anchor参数
        # 发送JavaScript代码到客户端执行滚动
        js <- sprintf("document.getElementById('%s').scrollIntoView({behavior: 'smooth'});", 
                     query$anchor)
        shinyjs::runjs(js)
    }
        })
        
        # 根据响应值观察结果输出
        observe({
            
            # 获取搜索结果
            home_search_out_data <- get_search_gene_name(user_input_QTL_ID$QTL)
            
            if (!is.list(home_search_out_data)){
                shinyalert(
                    title = "Error",
                    type = "error",text = "Search failed, Please check the input text"
                )
            }else{
                # infomation
                output$home_box_index <- renderText(str_c("🔍 Landscape unique Index:",home_search_out_data$search_out_all$Index[1]))
                output$home_box_ID <- renderText(str_c("🎉 Success! Search Index:",home_search_out_data$search_out_all$QTL_ID[1]))
                output$home_box_pos <- renderText(str_c("🛰️ QTL position (IWGSC CS 2.1) : Chr",home_search_out_data$search_out_all$Chrome[1]," [ From ",
                                                        home_search_out_data$search_out_all$Start_CS21_MB[1]," MB to ",home_search_out_data$search_out_all$End_CS21_MB[1]," MB ]"))
                output$home_box_know_gene <- renderText(str_c("🎯 Information:",home_search_out_data$search_out_all$Known_Gene[1]))
                output$home_box_QTL_size <- renderText(str_c("✅ ",home_search_out_data$search_out_all$QTL_ID[1]," Linkage block size： ",home_search_out_data$search_out_all$Size_MB[1]," MB.",
                                                             " There are ",home_search_out_data$search_out_all$Gene_Number[1], " genes in this QTL region."))
                
                
                # search_line_table
                output$search_line_table <- renderReactable(
                    
                    reactable(home_search_out_data$search_line_table,
                              defaultColDef = colDef(
                                  align = "center",
                                  minWidth = 70,
                                  headerStyle = list(background = "#f6ffed")
                              ),
                              defaultPageSize = 15,
                              # pagination = FALSE,
                              # height = 700,
                              searchable = F,
                              showPageSizeOptions = F,
                              striped = T,
                              bordered = T
                    )
                )
                
                output$search_QTL_genetype_table <- renderReactable(
                    
                    reactable(home_search_out_data$search_out_all[,c(2,3,12,14:17)],
                              defaultColDef = colDef(
                                  align = "center",
                                  minWidth = 70,
                                  headerStyle = list(background = "#f6ffed")
                              ),
                              # defaultPageSize = 15,
                              # pagination = FALSE,
                              # height = 700,
                              searchable = F,
                              showPageSizeOptions = F,
                              striped = F,
                              bordered = T
                    )
                )
                
                # 不同年代折线图变化趋势
                output$home_search_line_plot <- renderEcharts4r(
                    home_search_out_data$freq_year %>%
                        e_charts(year) %>%
                        e_line(freq, areaStyle = list(color = list(
                            type = 'linear',
                            x = 0, y = 0, x2 = 0, y2 = 1,
                            colorStops = list(
                                list(offset = 0, color = '#3d8e86'),   # 颜色在 0% 处
                                list(offset = 1, color = 'white')   # 颜色在 100% 处
                            )
                        ))) %>%
                        e_tooltip(trigger = "axis", formatter = htmlwidgets::JS("
        function(params) {
          var year = params[0].name;
          var value = params[0].value;
          return 'Usage frequency: ' + value + '%';
        }
      ")) %>%
                        e_title("Frequency in Breeding Years",x="center") %>%
                        e_x_axis(type = "category", boundaryGap = FALSE) %>%
                        e_y_axis(
                            axisLabel = list(
                                formatter = "{value}%"
                            )
                        ) %>% 
                        e_legend(show = FALSE)
                )
                
                
                # 不同地区之间的频率图
                output$home_search_bar_plot <- renderEcharts4r(
                    
                    home_search_out_data$freq_BG %>%
                        e_charts(Group) %>%
                        e_bar(freq, itemStyle = list(color = list(
                            type = 'linear',
                            x = 0, y = 0, x2 = 0, y2 = 1,
                            colorStops = list(
                                list(offset = 0, color = '#509296'),   # 颜色在 0% 处
                                list(offset = 1, color = 'white')   # 颜色在 100% 处
                            )
                        ))) %>%
                        e_tooltip(trigger = "axis", formatter = htmlwidgets::JS("
        function(params) {
          var year = params[0].name;
          var value = params[0].value;
          return 'Usage frequency: '  + value + '%';
        }
      ")) %>%
                        e_title("Frequency in Breeding Group",x="center") %>%
                        e_x_axis(type = "category", boundaryGap = TRUE) %>%
                        e_y_axis(
                            axisLabel = list(
                                formatter = "{value}%"
                            )
                        ) %>%
                        e_legend(show = FALSE)
                )
                
                # 饼图-展示基因型占比
                output$home_search_pie_GT <- renderEcharts4r(
                    home_search_out_data$GT_pie %>%
                        e_charts(type) %>%
                        e_pie(value, label = list(
                            position = 'inside',
                            formatter = '{b}: {d}%'
                        )) %>%
                        e_title("Proportion of GenoType",x="center") %>%
                        e_tooltip(trigger = "item", formatter = htmlwidgets::JS("
        function(params) {
          return  'Sample Number: ' + params.value;
        }
      ")) %>%
                        e_legend(show = F)
                )

                # 含有抗病位点的材料信息表格
                output$home_search_out_reactable <- renderReactable(
                    reactable(home_search_out_data$R_sample_out,
                              # defaultColDef = colDef(
                              #     header = function(value) gsub(".", " ", value, fixed = TRUE),
                              #     cell = function(value) format(value, nsmall = 1),
                              #     align = "center",
                              #     minWidth = 70,
                              #     headerStyle = list(background = "#f6ffed")
                              # ),
                              filterable = T,
                              columns = list(
                                            Click = colDef(cell = function(value, index) {
                                                # Render as a link
                                                url <- str_c("./?page=Sample&Sample_ID=",value)
                                                htmltools::tags$a(href = url, target = "_blank", style = "text-decoration: none;",str_c("💡 View sample →"))
                                            }))
                    )
                )
                
                # 箱线图——展示表型信息
                output$home_search_phe_boxplot <- renderPlot({
                    
                    df_plot <- as.data.frame(home_search_out_data$phe_boxplot) %>% 
                      pivot_longer(cols = (2:(ncol(home_search_out_data$phe_boxplot)-1)),names_to = "Trait",values_to = "value") %>% 
                      drop_na() %>% as.data.frame() 

                    df_plot <- df_plot %>% filter(Trait  %in%  input$box_select_phe)

                 p <- ggplot(df_plot,aes(x=type,y=value))+
                    geom_jitter(alpha = 0.8,position = position_jitter(0.2), 
                                aes(color = type)) +
                    geom_boxplot(aes(fill = type),alpha = 0.1,position=position_dodge(1.2))+
                    scale_fill_manual(values = c("#51cf66",
                                                "#ffd43b"))+
                    scale_color_manual(values = c("#51cf66",
                                                "#ffd43b"))+
                    geom_signif(comparisons = list(c("0/0","1/1")),
                    map_signif_level = function(p) sprintf("P = %.2g", p),
                    test = t.test,
                    tip_length = 0.05,
                    # textsize = 5 ,
                    # vjust = -0.5,
                    # step_increase=0.2
                    )+
                    ylab("Trait value")+
                    xlab("")+
                    facet_wrap(~Trait,nrow = 1,
                    scales = "free_y",
                    strip.position = "bottom")+
                    scale_y_continuous(expand = expansion(mult = c(0.05, 0.2)))+  # 下限扩展5%，上限扩展20%
                    theme_bw()

                    p
                })
                
                
                # QTL 对应的基因
                output$QTL_include_gene <- renderDT({
                    df_out <- get_QTL_include_gene_table(user_input_QTL_ID$QTL)

                    df_out$Click <- paste0('<a href="',"./?page=Gene&Gene=",df_out$GeneID, '";target="_blank";style="text-decoration: none;">view</a>')

                    datatable(df_out,escape = FALSE)
                })
                
                
                
                
            }
        })
    }
  )
}