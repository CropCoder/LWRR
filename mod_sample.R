mod_sample_UI <- function(id) {
  ns <- NS(id)
  tagList(
      tags$div(class = "alert alert-success", role = "alert",
               strong("Introduction："), "This page provides single sample level queries and information retrieval, where you can search for information on 2191 samples."),
      h3("sample information table display"),
      # Search panel ----
      layout_column_wrap(
          1/2,
          card(
              textInputIcon(
                  ns("input_sample_ID"),"Search Sample （eg：S0073、Xinong979、西农979）",
                  value = "S0073",placeholder = "S0073",icon = icon("magnifying-glass"),width = "100%"
              ),
              actionButton(ns("run_search_Sample"),"Search Sample in Ladnscape", 
                           icon("magnifying-glass"), class = "btn-success m-2")
          ),
          card(
              card_header("Tip"),
              card_body("Wheat is one of the most important grain crops. Currently, the global wheat production is threatened by the potential of wheat stripe rust. The best measure to control wheat stripe rust is to cultivate disease-resistant varieties with excellent resistance to wheat stripe rust.")
          )
      ),
      # 这个样本有哪些信息
      # infomation----
      withSpinner(uiOutput(ns("Sample_out_info"))),
      
      # 样本表型信息
      card(
          card_header("Phe"),
          layout_column_wrap(
              1/3,
              withSpinner(echarts4rOutput(ns("plot_IT"))),
              withSpinner(echarts4rOutput(ns("plot_DS"))),
              withSpinner(echarts4rOutput(ns("plot_CYR")))
          )
      ),
      
      
      # Sample QTL----
      # 这个样本中含有哪些QTL
      h3("What QTLs are present in this sample"),
      card(
          # sample_info_table----
          reactableOutput(ns("sample_info_table")),
          tags$div(class = "alert alert-success", role = "alert",
                   strong("About："), "The above table lists the presence of each QTL for the samples you are querying, and clicking on the QTL names on the left can quickly jump to the fingerprints.")
      ),
      h3("Map of whole chromosome disease resistance sites"),
      card(
          full_screen = T,
          withSpinner(plotOutput(ns("sample_QTL_plot"),height = "750px")),height = "900px",
          tags$div(class = "alert alert-success", role = "alert",
                   strong("Tips："), "Based on the genotypes of resequencing and field phenotypic identification data, we predicted and analyzed the types of 431 QTL resistance loci in this sample at the whole genome level. The above results are only for the reference of breeders and can be further verified by molecular genetic biology experiments.")
      )
      
  )
}

mod_sample_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
        
        # 创建响应值- 默认
        react_vals <- reactiveValues(sample_ID = "S0073")
        
        # 点击后更新响应值
        observeEvent(input$run_search_Sample, {
            react_vals$sample_ID = input$input_sample_ID
            shinyalert("Running","Please wait for the result","success")
        })
        
        # 观察URL参数变化
        observe({
            # 获取URL中的查询参数
            query <- parseQueryString(session$clientData$url_search)
            
            # 如果URL包含名为'Sample_ID'的参数，则更新文本输入框的内容
            if (!is.null(query$Sample_ID)) {
                react_vals$sample_ID = query$Sample_ID
                Sample_ID <- query$Sample_ID
                updateTextInputIcon(session = session,"input_sample_ID",value = Sample_ID)
            }
        })
        
        observe({
            
            # 单个基因查询结果
            OUT <- get_Search_Sample(react_vals$sample_ID)
            
            # infomation----
            output$Sample_out_info <- renderUI(
                list(
                    layout_column_wrap(
                        1/4,
                        value_box(
                            value = OUT$RunID,
                            p("Sample Run ID", bs_icon("Database-fill-check"))
                        ),
                        value_box(
                            value = OUT$NameCN,
                            p("Chinene Name", bs_icon("Database-fill-check"))
                        ),
                        value_box(
                            value = OUT$Year,
                            p("Year", bs_icon("Database-fill-check"))
                        ),
                        value_box(
                            value = OUT$GrowthHabit,
                            p("GrowthHabit", bs_icon("Database-fill-check"))
                        )
                    )
                )
            )
            
            # Phe plot ----
            output$plot_IT <- renderEcharts4r(
                OUT$plot_IT
            )
            
            output$plot_DS <- renderEcharts4r(
                OUT$plot_DS
            )
            
            output$plot_CYR <- renderEcharts4r(
                OUT$plot_CYR
            )
            
            # sample_info_table----
            output$sample_info_table <- renderReactable({
                df_QTL_info <- OUT$df_QTL_info
                df_QTL_info$Click <- df_QTL_info$QTL
                df_QTL_info$GeneNumber <- NULL
                reactable(df_QTL_info, columns = list(
                    Click = colDef(cell = function(value, index) {
                        # Render as a link
                        url <- str_c("./?page=QTL&QTL_search=",value)
                        htmltools::tags$a(href = url, target = "_blank", style = "text-decoration: none;",str_c("🔍 View "))
                    }),
                    Type = colDef(cell = function(value) {
                        # Render as an X mark or check mark
                        if (value == "Miss") "\u274c Miss" else "\u2714\ufe0f Exist"
                    })
                ))
            })
            
            # Sample - 染色体图 ----
            output$sample_QTL_plot <- renderPlot({
                OUT$sample_QTL_plot
            })
            
        })
    }
  )
}