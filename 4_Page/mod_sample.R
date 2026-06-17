mod_sample_UI <- function(id) {
  ns <- NS(id)
  tagList(
      tags$div(class = "alert alert-success", role = "alert",
               strong("Tip: "), "This page provides sample query and information retrieval, where you can search for information on 2191 samples, including disease resistance phenotypes of wheat rust in different environments. Please enter the ID of the sample you want to search below and click the button to get the results."),
      h3("Query the phenotype and basic information of sample"),
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
              card_header("Usage"),
              card_body("Enter the sample of interest, click the green button below, and wait for a while, the page will automatically obtain the specific information of the sample you submitted, including the resistance level under different phenotypes, the distribution difference of 431 QTLS, etc.")
          )
      ),
      # 这个样本有哪些信息
      # infomation----
      withSpinner(uiOutput(ns("Sample_out_info"))),
      
      # 样本表型信息
      card(
          card_header("The phenotypic data of wheat stripe rust resistance under different environments (the larger the value, the higher the degree of susceptibility)"),
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
                   strong("About："), "The above table lists the presence of each QTL for the samples you are querying, and clicking on the QTL names on the left can quickly jump to the fingerprints. The data of each QTL were calculated according to the lead SNP and phenotype at the population level, and were used to quickly judge the distribution of QTL in a certain sample")
      ),
      h3("Map of whole chromosome disease resistance sites"),
      card(
          full_screen = T,
          withSpinner(plotOutput(ns("sample_QTL_plot"),height = "750px")),height = "950px",
          tags$div(class = "alert alert-success", role = "alert",
                   strong("Tips："), "Based on the genotypes of resequencing and field phenotypic identification data, we predicted and analyzed the types of 431 QTL resistance loci in this sample at the whole genome level. The above results are only for the reference of breeders and can be further verified by molecular genetic biology experiments. In the chromosomal diagram, black indicates the vicinity of the centromere, and each colored rectangle represents a QTL, with different QTL types varying in color and size")
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
                        1/5,
                        value_box(
                            value = span(style = "font-size: 1.2em;", str_c(OUT$BreedingGroup," > ",OUT$SubRegion)),   
                            p("Breeding Group", bs_icon("Database-fill-check"))
                        ),
                        value_box(
                            value = span(style = "font-size: 1.2em;", OUT$RunID), 
                            p("Sample Run ID", bs_icon("Database-fill-check"))
                        ),
                        value_box(
                            value = span(style = "font-size: 1.2em;", OUT$NameCN),
                            p("Chinene Name", bs_icon("Database-fill-check"))
                        ),
                        value_box(
                            value = span(style = "font-size: 1.2em;", OUT$Year),
                            p("Year", bs_icon("Database-fill-check"))
                        ),
                        value_box(
                            value = span(style = "font-size: 1.2em;", OUT$GrowthHabit),
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
                reactable(df_QTL_info, searchable =T,columns = list(
                    Click = colDef(cell = function(value, index) {
                        # Render as a link
                        url <- str_c("./?page=QTL&QTL_search=",value)
                        htmltools::tags$a(href = url, target = "_blank", style = "text-decoration: none;",str_c("🔍 View "))
                    }),
                    Type = colDef(cell = function(value) {
                        # Render as an X mark or check mark
                        if (value == "Absence") "\u274c Absence" else "\u2714\ufe0f Presence"
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