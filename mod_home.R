home_css_style <- "
  .sample-number-link {
    text-decoration: none;
    color: #099268; /* 设置初始颜色 */
    transition: all 0.3s ease; /* 添加过渡效果，包括颜色和变换 */
    transform-origin: center;
  }
  .sample-number-link:hover {
    color: #c55b11; /* 设置悬停时的颜色 */
    transform: scale(0.9); /* 设置悬停时的放大比例 */
  }
"

mod_home_ui <- function(id,label = "home"){
  ns <- NS(id)
  tagList(
    tags$head(tags$style(HTML(home_css_style))),
    card(
          max_height = 100,
          full_screen = T,
          card_header("News:"),
          card_body(includeMarkdown("www/md/home_news.Rmd"))
        ),
    # card----
    layout_column_wrap(
      width=1/4,
      value_box(
        title = "Sample Number",
        value = tags$a(class = "sample-number-link", href = "./?page=Sample", "2191"),
        showcase = bs_icon("patch-check"),
        p("Abundant", bs_icon("Database-fill-check"))
      ),
      value_box(
        title = "QTL Number",
        value = tags$a(class = "sample-number-link", href = "./?page=QTL", "431"),
        showcase = bs_icon("list-check"),
        p("Association", bs_icon("Database-fill-check"))
      ),
      value_box(
        title = "Gene Number",
        value = tags$a(class = "sample-number-link", href = "./?page=Gene", "9276"),
        showcase = bs_icon("database-fill-check"),
        p("Candidate", bs_icon("Database-fill-check"))
      ),
      value_box(
        title = "Trait Number",
        value = tags$a(class = "sample-number-link", href = "/?page=Trait", "28"),
        showcase = bs_icon("dropbox"),
        p("Diversiform", bs_icon("Database-fill-check"))
      )
    ),
    # 全局搜索----
    tags$div(
        style = "margin: 40px auto; max-width: 100%; text-align: center;",
        
        # 搜索框容器
        tags$div(
            style = "
            background: linear-gradient(145deg, #f6f8fa, #ffffff);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(31, 38, 135, 0.15);
            padding: 30px;
            margin-bottom: 30px;
            transition: all 0.3s ease;
            &:hover {
              transform: translateY(-5px);
              box-shadow: 0 12px 40px rgba(31, 38, 135, 0.25);
            }
          ",
            br(),
            tags$h4(style="color: #2d3436; margin-bottom: 20px;", "🎖️ Welcome to LWRR , You can try to search for information of interest here"),
            
            # 搜索输入框
            tags$div(
                style = "display: flex; justify-content: center; gap: 10px;",
                textInputIcon(
                    ns("home_query"),
                    label = NULL,
                    # value = "TraesCS2A03G1353200", 
                    placeholder = "eg. Yr30、Nongda183、Ta002053、QYr.nw008、TraesCS2A03G1353200",
                    icon = icon("dna"),
                    width = "800px"
                ),
                # global search ----
                actionButton(
                    ns("run_global_search"),
                    "Search",
                    icon = icon("magnifying-glass"),
                    class = "btn-primary",
                    style = "
                height: 38px;
                transition: all 0.3s ease;
                &:hover {
                  transform: scale(1.05);
                }
              "
                )
            ),
            br()
        ),
        
        # 提示信息卡片
        tags$div(
            style = "
            background: linear-gradient(145deg, #e3f2fd, #bbdefb);
            border-radius: 15px;
            padding: 20px;
            color: #1565c0;
            font-size: 15px;
            line-height: 1.6;
          ",
            icon("info-circle"), 
            "If use LWRR in pulication, please cite >>>>>> LWRR: A database of Landscape of Wheat Rust Resistance promoting design breeding of disease resistance"
        )
    ),
    # 介绍----
    br(),
    layout_column_wrap(
       1/2,
       tags$a(href="./?page=Population", target="_blank",tags$img(src="fig/home_card/population.png", class="home-card",style="width:100%")),
       tags$a(href="./?page=Sample", target="_blank",tags$img(src="fig/home_card/sample.png", class="home-card",style="width:100%"))
    ),
    layout_column_wrap(
        1/2,
        tags$a(href="./?page=QTL", target="_blank",tags$img(src="fig/home_card/QTL.png", class="home-card",style="width:100%")),
        tags$a(href="./?page=Gene", target="_blank",tags$img(src="fig/home_card/Gene.png", class="home-card",style="width:100%"))
    ),
    
    fluidRow(
        column(
            4,
            shinycssloaders::withSpinner(
                slickROutput(ns("top_fig"),height = "300px",width = "103%"),type = 8,color = "#a4b0be"
            )
        ),
        column(
            8,
            card(
                includeMarkdown("www/md/home_intro.Rmd"),
                tags$img(src="fig/home_tech.png", style = "width: 100%;")
            )
        )
    ),
    # # QTL----
    # h3("QTL overview "),
    # tags$img(src="fig/home_QTL_chrome.png", style = "width: 100%;"),
    # br(),br(),
    # # card(
    # #   full_screen = T,
    # #   reactableOutput(ns("home_table_QTL"),width = "100%")
    # # ),
    # tags$div(class = "alert alert-success", role = "alert",
    #          strong("Tip："), "Through extensive and long-term global collection efforts, we obtained 2,191 wheat germplasm resources with rich genetic diversity. Using resequencing and other techniques, we detected variant loci and constructed a high-quality variant map comprising over 80 million loci. Through multi-year, multi-location phenotypic surveys of stripe rust in the field, and seedling-stage identification using five different physiological races of the stripe rust fungus, we assessed the resistance of the materials. Through GWAS association analysis, we successfully identified 431 QTL loci. "),
    # br(),
    # #population----
    # h3("Population Overview"),
    # layout_column_wrap(
    #   1/2,
    #   card(
    #     full_screen = T,
    #     card_header("Sample Number in different countries"),
    #     echarts4rOutput(ns("plot_wordmap"),height = 300)
    #   ),
    #   card(
    #     full_screen = T,
    #     card_header("Sample PCA analysis results"),
    #     plotlyOutput(ns("plot_pcA_point"),height = 300)
    #   )
    # ),
    # card(
    #   full_screen = T,
    #   reactableOutput(ns("pop_smaple_table"))
    # ),
    tags$div(class = "alert alert-success", role = "alert",
             strong("Tip："), "To represent the widest genetic diversity in common wheat we have collected more than 14,000 common wheat accessions from worldwide resources, including modern cultivars, advanced breeding lines, core germplasm collections, founder parents, and landraces (Han et al., 2012; Mu et al., 2019; Wu et al., 2020; Wu et al., 2021; Yu et al., 2020; Zeng et al., 2014). From these, 1,629 accessions were carefully selected for GWAS covering most of the diversity worldwide, including 666 with accessible genome sequence information (29 from Cheng et al. (2019), 83 from Hao et al. (2020), 105 from Zhou et al. (2020), 92 from Guo et al. (2020), 9 from Walkowiak et al. (2020), and 355 from Niu et al. (2023)), 349 newly sequenced accessions using WGS, and 614 accessions genotyped using 660 K SNP array in the present study."),
    br()
    # trait----
    # h3("Trait Overview"),
    # card(
    #   full_screen = T,
    #   card_header("Phenotypic Data statistical result"),
    #   tags$img(src="fig/home_trait_boxplot.png", style = "width: 100%;"),
    #   h4("Trait table:"),
    #   reactableOutput(ns("smaple_trait_table"))
    # ),
    # tags$div(class = "alert alert-success", role = "alert",
    #          strong("Tip："), "LDWR is not merely a simple database but a comprehensive wheat breeding platform. We have developed candidate gene analysis modules commonly used in the field of genetic breeding, allowing users to focus on research ideas rather than cumbersome analytical processes. LWDR offers practical table download features, data export functionalities, and chart magnification capabilities."),
    # br(),
    
  
  )
}

mod_home_server <- function(id){
  moduleServer(id,
               function(input, output, session){
                 
                   output$top_fig <- renderSlickR({
                       slickR(
                           c("fig/wheat-1.jpg",
                             "fig/wheat-2.jpg",
                             "fig/wheat-3.jpg",
                             "fig/wheat-4.jpg")
                       )+settings(dots = T, autoplay = TRUE, autoplaySpeed = 3000,arrows=F)
                   })
                   
                   # global search ----
                   observeEvent(input$run_global_search,{
                       
                       req(input$home_query)
                       
                       myinput <- input$home_query %>% as.character()
                       
                       if (myinput %in% search_index_Sample){
                           shinyjs::runjs(paste0("window.location.href = '","./?page=Sample&Sample_ID=",myinput, "';"))
                       }else{
                           if (myinput %in% search_index_CN_name){
                               shinyjs::runjs(paste0("window.location.href = '","./?page=Sample&Sample_ID=",myinput, "';"))
                           }else{
                               if (myinput %in% search_index_EN_name){
                                   shinyjs::runjs(paste0("window.location.href = '","./?page=Sample&Sample_ID=",myinput, "';"))
                               }else{
                                   if (myinput %in% search_index_QYr){
                                       shinyjs::runjs(paste0("window.location.href = '","./?page=QTL&QTL_search=",myinput, "';"))
                                   }else{
                                       if (myinput %in% search_index_GeneName){
                                           shinyjs::runjs(paste0("window.location.href = '","./?page=QTL&QTL_search=",myinput, "';"))
                                       }else{
                                            shinyalert("Sorry","The information you entered is not found in the database, please modify it and try again.\n (Currently support Sample, QTL, Gene quick search)","error")
                                       }
                                   }
                               }
                           }
                       }
                       

                       
                       # shinyalert("Sorry","The information you entered is not found in the database, please modify it and try again.\n (Currently support Sample, QTL, Gene quick search)","error")
                       
                       # QTL
                       # if (myinput %in% search_index_Sample)
                       
                       # shinyalert("Success","The specified information has been queried in the database. Later, you will be transferred to the specified page for view.","success")
                       
                   })
                 
                 # 地图----
                 # output$plot_wordmap <- renderEcharts4r({
                 #   
                 #   data_wordmap <- countrycode::codelist$country.name.en
                 #   data_wordmap <- data.frame(
                 #     country = data_wordmap,
                 #     SampleNumber = runif(length(data_wordmap), 1, 100)
                 #   )
                 #   # 每个国家采集的样本个数统计
                 #   data_wordmap <- data_wordmap[1:150,]
                 #   
                 #   plot_wordmap <- data_wordmap |>
                 #     e_charts(country) |> # 国家
                 #     e_map(SampleNumber) |>
                 #     e_visual_map(SampleNumber) |>
                 #     e_tooltip()
                 #   
                 # })
                 
                 # PCA----
                 # df_pca <- S8_PCA_df[,c(1,2,3,9,6)] %>% as.data.frame()
                 # colnames(df_pca) <- c("ID","PC1","PC2","Group","Region")
                 #   
                 # output$plot_pcA_point <- renderPlotly({
                 #   colors <- c("LC" = "#00b894", 
                 #               "Asian pool" = "#f36e43",
                 #               "Europe pool"="#2e59a7",
                 #               "other"="#e0e0e0")
                 #   ggplotly(ggplot(df_pca, aes(x = PC1, y = PC2, color = Group)) + 
                 #     geom_point(size=1,alpha=1) +
                 #     scale_color_manual(values = colors)+
                 #     labs(x=paste0("PC1(10.89%)"),
                 #          y=paste0("PC2(4.00)")) +
                 #     theme_classic() 
                 #     # theme(legend.position = c(0.80,0.15))
                 #   )
                 # })
                 
                 
                 # pop----
                 # df_sample_table <- S1_sample[,c(2,3,7,8,13,16,6)]
                 # colnames(df_sample_table) <- c("ID","Name","Type","Habit","Region","BreedGroup","Source")
                 # 
                 # output$pop_smaple_table <- renderReactable(
                 #   reactable(df_sample_table,
                 #             defaultColDef = colDef(
                 #               header = function(value) gsub(".", " ", value, fixed = TRUE),
                 #               cell = function(value) format(value, nsmall = 1),
                 #               align = "center",
                 #               # minWidth = 70,
                 #               headerStyle = list(background = "#ddf5eb")
                 #             ),
                 #             defaultPageSize = 10,
                 #             # pagination = FALSE,
                 #             # height = 700,
                 #             searchable = F,
                 #             showPageSizeOptions = T,
                 #             striped = F,
                 #             bordered = T,
                 #             highlight = T,
                 #             filterable = TRUE
                 #             # defaultSortOrder = "desc",
                 #             # defaultSorted = c("Chinese Name")
                 #   )
                 # )
                 
                 # trait_table----
                 # df_trait_table <- S1_sample[,c(2,17:25)] %>% drop_na()
                 # 
                 # output$smaple_trait_table <- renderReactable(
                 #   reactable(df_trait_table,
                 #             defaultColDef = colDef(
                 #               header = function(value) gsub(".", " ", value, fixed = TRUE),
                 #               cell = function(value) format(value, nsmall = 1),
                 #               align = "center",
                 #               # minWidth = 70,
                 #               headerStyle = list(background = "#ddf5eb")
                 #             ),
                 #             defaultPageSize = 10,
                 #             # pagination = FALSE,
                 #             # height = 700,
                 #             searchable = F,
                 #             showPageSizeOptions = T,
                 #             striped = F,
                 #             bordered = T,
                 #             highlight = T,
                 #             filterable = F
                 #             # defaultSortOrder = "desc",
                 #             # defaultSorted = c("Chinese Name")
                 #   )
                 # )
                 
                 
              })
}


