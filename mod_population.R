mod_population_UI <- function(id) {
  ns <- NS(id)
  tagList(
      
      tags$div(class = "alert alert-success", role = "alert",
               strong("About："), "Here we provide various information about the groups, such as grouped in time and geographic level, and you can get data for each subgroup."),
      # word map ----
      h3("Population Map"),
      card(
          tags$img(src="fig/population_wordmap.png", style = "width: 100%;"),
          p("Annotation:The samples come from all over the world and have a wide range of regional and genetic diversity.")
      ),
      # breedgroup ----
      h3("Breed Group Infomation"),
      radioGroupButtons(
          inputId = ns("select_which_BG"),
          label = NULL,
          choices = c("BG1", "BG2", "BG3", "BG4"),
          size = "sm",
          justified = T
      ),
      card(
          # table_BG ----
          # card_header("Query Breed Group"),
          withSpinner(reactableOutput(ns("table_BG"))),
          br(),
          layout_column_wrap(
              1/3,
              # BG_Year_info ----
              echarts4rOutput(ns("BG_Year_info")),
              
              # BG_K ----
              echarts4rOutput(ns("BG_K_info")),
              
              # BG_country ----
              echarts4rOutput(ns("BG_country"))
          ),
          tags$div(class = "alert alert-danger", role = "alert",
                   strong("tip："), "We collected diverse wheat materials from different geographical origins across different eras and divided them into four breeding groups based on information such as population structure, PCA, origin, and era. The different breeding groups exhibit diversity in the utilization of wheat disease resistance genes and breeding selection, which aims to study the characteristics of wheat disease resistance breeding in different regions and eras."),
      ),
      
      
      h3("Signals of selective domestication and population variation diversity"),
      # radioGroupButtons(
      #     inputId = ns("select_which_PiFst_chr"),
      #     label = "Select a chromosome and obtain nucleic acid diversity data for all samples on that chromosome:",
      #     choices = chr_convert$new,
      #     selected = "1A",
      #     size = "sm",
      #     justified = T,
      #     individual = F
      # ),
      # Pop value get ----
      fluidRow(
          column(
              4,
              selectInput(
                  inputId = ns("select_which_PiFst_chr"),
                  label = "Select Chrome",
                  choices = chr_convert$new,
                  selected = "1A",width = "100%"
              ),
              numericInput(
                  inputId = ns("start_popvalue"),label = "Start (Mb)",value = 200,width = "100%",min = 1,max = 800
              ),
              numericInput(
                  inputId = ns("end_popvalue"),label = "End (Mb)",value = 250,width = "100%",min = 1,max = 800
              )
          ),
          column(
              8,
              p("Tips:"),
              tags$div(class = "alert alert-success", role = "alert","Please check that the range size cannot exceed 100Mb. Otherwise, the system may crash."),
              p("1. Pi was calculated using materials from four different breeding groups"),
              p("2. Fst was calculated using the resistant samples in each breeding group compared with the landrace"),
              p("3. The sliding window step was 0.1Mb and the window size was 100kb ( vcftools )")
          )
      ),
      card(
          full_screen = T,
          layout_column_wrap(
              1/2,
              list(
                  # Pi ----
                  card(
                      full_screen = T,
                      echarts4rOutput(ns("pop_pi_plot"),width = "100%",height = "400px"),
                      br("This data is based on the results of Structure analysis, and interactive visualization is performed on the data of each group. You can click on the area below the X-axis, select the interval of interest, and obtain corresponding detailed information.")
                  )
              ),
              list(
                  # Fst----
                  card(
                      full_screen = T,
                      echarts4rOutput(ns("pop_fst_plot"),height = "500px"),
                      br(),
                      p("We conducted Fst analysis based on genotype information of two subgroups, Landrace and Cultivar, using a sliding window of 1MB and a step size of 100kb. You can interactively view Fst data at a specified position on a chromosome in the above figure.")
                  )
              )
          ),
          layout_column_wrap(
              1/2,
              list(
                  # TajimD----
                  card(
                      full_screen = T,
                      echarts4rOutput(ns("pop_tajm_plot"),height = "500px"),
                      br(),
                      p("We conducted Fst analysis based on genotype information of two subgroups, Landrace and Cultivar, using a sliding window of 1MB and a step size of 100kb. You can interactively view Fst data at a specified position on a chromosome in the above figure.")
                  )
              ),
              list(
                  # TajimD----
                  card(
                      full_screen = T,
                      echarts4rOutput(ns("pop_snpnum_plot"),height = "500px"),
                      br(),
                      p("We conducted Fst analysis based on genotype information of two subgroups, Landrace and Cultivar, using a sliding window of 1MB and a step size of 100kb. You can interactively view Fst data at a specified position on a chromosome in the above figure.")
                  )
              )
              
          )
      ),
      
      
      
      
      # PCA ----
      h3("Population PCA"),
      tags$div(class = "alert alert-success", role = "alert",
               strong("tip："), "We provide the PCA analysis results of 2191 materials at the population level. The left image below represents the PCA results of 4 BGs and landrace, while the right image represents the population composition coloring results calculated based on structure. You can drag and drop with the mouse to view, or click on the legend to interactively view the distribution of a specific subgroup."),
      layout_column_wrap(
          1/2,
          card(
              card_header("PCA 3D Plot by Breed Group"),
              withSpinner(plotlyOutput(ns("PCA_3D_BG"))),full_screen = T
          ),
          card(
              card_header("PCA 3D Plot by 9 Admixture Group"),
              withSpinner(plotlyOutput(ns("PCA_3D_K9"))),full_screen = T
          )
      ),

      
      
      # Structure----
      h3("Structure of Population"),
      radioGroupButtons(
          inputId = ns("select_which_k"),
          label = NULL,
          choices = paste0("K=",2:9),
          selected = "K=3",
          size = "sm",
          # direction = "vertical",
          justified = T
      ),
      card(
          full_screen = T,
          withSpinner(echarts4rOutput(ns("pop_structure_k9"),width = "100%",height = "400px")),
          p("We used Admixture in group structure analysis to calculate the group composition for K=2 to K=9, and presented the data of 2191 materials in each component uniformly. You can click on any material to obtain the corresponding calculation result, and the local selection function is provided below the X-axis, making it convenient for you to view a specific location.")
      )
      
      
  )
}

mod_population_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
        # PCA_3D ----
        output$PCA_3D_BG <- renderPlotly({
            data <- dbGetQuery(db,"SELECT ID,PC1,PC2,PC3 FROM PopPCA")
            
            group <- S1_sample[,c(2,16)]
            colnames(group) <- c("ID","Group")
            data <- left_join(data,group,by = "ID")
            
            plot_ly(data, x = ~PC1, y = ~PC2, z = ~PC3, 
                    color = ~Group, 
                    text = ~paste("Sample ID:", ID),
                    hoverinfo = 'text',
                    type = 'scatter3d', mode = 'markers',
                    marker = list(size = 4, opacity = 0.8)) %>% 
                layout(scene = list(
                    xaxis = list(title = "PC1"),
                    yaxis = list(title = "PC2"),
                    zaxis = list(title = "PC3")
                ))
            
        })
        
        output$PCA_3D_K9 <- renderPlotly({
            data <- dbGetQuery(db,"SELECT ID,PC1,PC2,PC3,AdmixtureK FROM PopPCA")
            
            
            plot_ly(data, x = ~PC1, y = ~PC2, z = ~PC3, 
                    color = ~AdmixtureK,
                    text = ~paste("Sample ID:", ID),
                    hoverinfo = 'text',
                    type = 'scatter3d', mode = 'markers',
                    marker = list(size = 4, opacity = 0.8)) %>% 
                layout(scene = list(
                    xaxis = list(title = "PC1"),
                    yaxis = list(title = "PC2"),
                    zaxis = list(title = "PC3")
                ))
            
        })
        

        # pop_structure_k9----
        output$pop_structure_k9 <- renderEcharts4r({  
            
            select_k <- input$select_which_k %>% str_replace("K=","") %>% as.numeric()
            
            data <- dbGetQuery(db,str_c("SELECT ID,",paste0("`K",select_k,"-",1:select_k,"`",collapse = ",")," FROM PopAdmixture"))
            
            data[,1] <- factor(data[,1],levels = data$ID) %>% as.data.frame()
            
            data_long <- data %>%
                pivot_longer(cols = -ID, names_to = "Type", values_to = "Percentage")
            
            data_long %>%
                group_by(Type) %>%
                e_charts(ID) %>%
                e_bar(Percentage, stack = "grp",barGap = "0%", barCategoryGap = "0%") %>%
                e_tooltip(trigger = "axis") %>%
                e_y_axis(axisLabel = list(formatter = "{value}%"),min=0,max=1) %>%
                e_x_axis(type = "category", axisLabel = list(show = FALSE)) %>%  # 隐藏X轴刻度标签
                e_datazoom(type = "slider") %>%  # 添加动态缩放功能
                e_legend(show = TRUE)
            
        })
        
        
        # obser pop----
        # select_which_pi_chr ----
        output$pop_pi_plot <- renderEcharts4r({
            
            
            
            which_chr <- str_c("Chr",input$select_which_PiFst_chr)
            mystart <- as.numeric(input$start_popvalue)
            myend <- as.numeric(input$end_popvalue)
            
            if (myend - mystart > 100){
                shinyalert("Error","Please check that the range size cannot exceed 100Mb. Otherwise, the system may crash","error")
            }
            
            data <- dbGetQuery(db,str_c(
                "SELECT * FROM PopBGPi WHERE Chr == '",which_chr,"' AND Pos > ",mystart," AND Pos < ",myend
            ))
            
            data %>%
                e_charts(Pos) %>%  # 指定横轴
                e_line(BG1, name = "BG1",symbol="none") %>%  # 绘制BG1折线
                e_line(BG2, name = "BG2",symbol="none") %>%  # 绘制BG2折线
                e_line(BG3, name = "BG3",symbol="none") %>%  # 绘制BG3折线
                e_line(BG4, name = "BG4",symbol="none") %>%  # 绘制BG4折线
                e_line(LC, name = "LC",symbol="none") %>%  # 绘制BG4折线
                e_line(NLC, name = "NLC",symbol="none") %>%  # 绘制BG4折线
                e_legend(orient = "", left = "right",y="center") %>% 
                e_y_axis(min=0) %>%
                e_title("Pi of Breeding Group",x="center") %>% 
                e_x_axis(
                    name = "Mb",  # 设置横轴名称
                    boundaryGap = FALSE,  # 数据点直接位于坐标轴上
                    min = "dataMin"  # 将横轴最小值设置为数据的最小值
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
  "))})
        
        # Fst ----
        output$pop_fst_plot <- renderEcharts4r({
            
            which_chr <- str_c("Chr",input$select_which_PiFst_chr)
            mystart <- as.numeric(input$start_popvalue)
            myend <- as.numeric(input$end_popvalue)
            
            data <- dbGetQuery(db,str_c(
                "SELECT * FROM PopBGFst WHERE Chr == '",which_chr,"' AND Pos > ",mystart," AND Pos < ",myend
            ))
            
            data %>%
                e_charts(Pos) %>%  # 指定横轴
                e_line(BG1RvsLC, name = "BG1R",symbol="none") %>%  # 绘制BG1折线
                e_line(BG2RvsLC, name = "BG2R",symbol="none") %>%  # 绘制BG2折线
                e_line(BG3RvsLC, name = "BG3R",symbol="none") %>%  # 绘制BG3折线
                e_line(BG4RvsLC, name = "BG4R",symbol="none") %>%  # 绘制BG4折线
                e_line(NLCRvsLC, name = "NLCR",symbol="none") %>%  # 绘制BG4折线
                e_legend(orient = "", left = "right",y="center") %>% 
                e_y_axis(min=0) %>%
                e_title("Fst between resistant samples and landrace",x="center") %>% 
                e_x_axis(
                    name = "Mb",  # 设置横轴名称
                    boundaryGap = FALSE,  # 数据点直接位于坐标轴上
                    min = "dataMin"  # 将横轴最小值设置为数据的最小值
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
        # pop_tajm_plot ----
        output$pop_tajm_plot <- renderEcharts4r({
            which_chr <- str_c("Chr",input$select_which_PiFst_chr)
            mystart <- as.numeric(input$start_popvalue)
            myend <- as.numeric(input$end_popvalue)
            
            data <- dbGetQuery(db,str_c(
                "SELECT * FROM PopBGtajimD WHERE Chr == '",which_chr,"' AND Pos > ",mystart," AND Pos < ",myend
            ))
            
            # 计算每个BG变量的线性回归模型并生成拟合值
            myspan <- 0.01
            
            fit_BG1 <- loess(BG1 ~ Pos, data = data,span = myspan)
            fit_BG2 <- loess(BG2 ~ Pos, data = data,span = myspan)
            fit_BG3 <- loess(BG3 ~ Pos, data = data,span = myspan)
            fit_BG4 <- loess(BG4 ~ Pos, data = data,span = myspan)
            
            data$fit_BG1 <- predict(fit_BG1, newdata = data)
            data$fit_BG2 <- predict(fit_BG2, newdata = data)
            data$fit_BG3 <- predict(fit_BG3, newdata = data)
            data$fit_BG4 <- predict(fit_BG4, newdata = data)
            
            data %>%
                e_charts(Pos) %>%  # 指定横轴
                e_line(fit_BG1, name = "BG1", symbol = "none") %>%  # 绘制BG1拟合曲线
                e_line(fit_BG2, name = "BG2", symbol = "none") %>%  # 绘制BG2拟合曲线
                e_line(fit_BG3, name = "BG3", symbol = "none") %>%  # 绘制BG3拟合曲线
                e_line(fit_BG4, name = "BG4", symbol = "none") %>%  # 绘制BG4拟合曲线
                e_legend(orient = "", left = "right",y="center") %>% 
                e_y_axis(min=0) %>%
                e_title("TajimD between resistant samples and landrace",x="center") %>% 
                e_x_axis(
                    name = "Mb",  # 设置横轴名称
                    boundaryGap = FALSE,  # 数据点直接位于坐标轴上
                    min = "dataMin"  # 将横轴最小值设置为数据的最小值
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
        
        # pop_snpnum_plot ----
        output$pop_snpnum_plot <- renderEcharts4r({
            which_chr <- str_c("Chr",input$select_which_PiFst_chr)
            mystart <- as.numeric(input$start_popvalue)
            myend <- as.numeric(input$end_popvalue)
            
            data <- dbGetQuery(db,str_c(
                "SELECT * FROM PopBGtajimD WHERE Chr == '",which_chr,"' AND Pos > ",mystart," AND Pos < ",myend
            )) %>% select(Pos,NumSNP)
            
            fit_NumSNP <- loess(NumSNP ~ Pos, data = data,span = 0.1)
            
            data$fit_NumSNP <- predict(fit_NumSNP, newdata = data)
            
            data %>%
                e_charts(Pos) %>%  # 指定横轴
                e_line(NumSNP, name = "Number",symbol="none") %>%
                # e_line(fit_NumSNP,symbol = "none",color="#e58e26") %>%
                e_legend(show = F) %>% 
                e_y_axis(min=0) %>%
                e_title("Number of variant sites",x="center") %>% 
                e_x_axis(
                    name = "Mb",  # 设置横轴名称
                    boundaryGap = FALSE,  # 数据点直接位于坐标轴上
                    min = "dataMin"  # 将横轴最小值设置为数据的最小值
                ) %>% 
                e_datazoom(type = "slider") %>%
                e_tooltip(trigger = "axis")
            
            })
        
        
        # table_BG----
        output$table_BG <- renderReactable({
            select_BG <- input$select_which_BG
            data <- S1_sample[which(S1_sample$BreedingGroup == select_BG),
                              c("RunID","Name","Status","Year","SubRegion")]
            reactable(data,
                      defaultPageSize = 5,
                      searchable = F,
                      showPageSizeOptions = F,
                      striped = T,
                      bordered = T)
        })
        
        # BG year info----
        output$BG_Year_info <- renderEcharts4r({
            BG_set_year <- dbGetQuery(db,str_c(
                "SELECT Year_Group FROM S1SampleInfo WHERE BreedingGroup = '",input$select_which_BG,"'"
            )) %>% as.vector()
            
            data_summary <- as.data.frame(table(BG_set_year))
            colnames(data_summary) <- c("Year", "Count")
            
            # 绘制饼状图
            data_summary %>%
                e_charts(Year) %>%
                e_pie(Count, 
                      label = list(show = T),
                      name = "Year",
                      radius = c("10%", "30%")) %>%
                e_tooltip(formatter = htmlwidgets::JS("
    function(params) {
      var percent = (params.percent).toFixed(2) + '%';
      return 'Group:' + params.name + '<br>Number: ' + params.value + '<br>proportion: ' + percent;
    }
  ")) %>%
                e_title(str_c("Sample Year of ",input$select_which_BG),x="center") %>% 
                e_legend(show = F)
            
        })
        
        # BG_K_info----
        output$BG_K_info <- renderEcharts4r({
            BG_set_year <- dbGetQuery(db,str_c(
                "SELECT K9 FROM S1SampleInfo WHERE BreedingGroup = '",input$select_which_BG,"'"
            )) %>% as.vector()
            
            data_summary <- as.data.frame(table(BG_set_year))
            colnames(data_summary) <- c("K9", "Count")
            
            # 绘制饼状图
            data_summary %>%
                e_charts(K9) %>%
                e_pie(Count, 
                      label = list(show = T),
                      name = "K",
                      radius = c("10%", "30%")) %>%
                e_tooltip(formatter = htmlwidgets::JS("
    function(params) {
      var percent = (params.percent).toFixed(2) + '%';
      return 'Structure ' + params.name + '<br>Number: ' + params.value + '<br>proportion: ' + percent;
    }
  ")) %>%
                e_title(str_c("Sample Structure of ",input$select_which_BG),x="center") %>% 
                e_legend(show = F)
            
            
        })
        
        # BG_country-----
        output$BG_country <- renderEcharts4r({
            BG_set_year <- dbGetQuery(db,str_c(
                "SELECT SubRegion FROM S1SampleInfo WHERE BreedingGroup = '",input$select_which_BG,"'"
            )) %>% as.vector()
            
            data_summary <- as.data.frame(table(BG_set_year))
            colnames(data_summary) <- c("Continent", "Count")
            
            # 绘制饼状图
            data_summary %>%
                e_charts(Continent) %>%
                e_pie(Count, 
                      label = list(show = T),
                      name = "Continent",
                      radius = c("10%", "30%")) %>%
                e_tooltip(formatter = htmlwidgets::JS("
    function(params) {
      var percent = (params.percent).toFixed(2) + '%';
      return 'Continent:' + params.name + '<br>Number: ' + params.value + '<br>proportion: ' + percent;
    }
  ")) %>%
                e_title(str_c("Continent of ",input$select_which_BG),x="center") %>% 
                e_legend(show = F)
            
            
        })
        
        
        
        # # pop_3_table ----
        # output$pop_cultivar <- renderReactable(
        #     reactable(dbGetQuery(db,"SELECT ID,Continent,Type,Location,GroupCN FROM PopPCA WHERE Habit == 'Cultivar'"),
        #               defaultPageSize = 10,
        #               searchable = F,
        #               showPageSizeOptions = T,
        #               striped = T,
        #               outlined = F,
        #               bordered = T,
        #               highlight = F,
        #               filterable = F
        #     )
        # )
        # 
        # output$pop_landrace <- renderReactable(
        #     reactable(dbGetQuery(db,"SELECT ID,Continent,Type,Location,GroupCN FROM PopPCA WHERE Habit == 'Landrace'"),
        #               defaultPageSize = 10,
        #               searchable = F,
        #               showPageSizeOptions = T,
        #               striped = T,
        #               outlined = F,
        #               bordered = T,
        #               highlight = F,
        #               filterable = F
        #     )
        # )
        # 
        # output$pop_breed <- renderReactable(
        #     reactable(dbGetQuery(db,"SELECT ID,Continent,Type,Location,GroupCN FROM PopPCA WHERE Habit == 'Breeding line'"),
        #               defaultPageSize = 10,
        #               searchable = F,
        #               showPageSizeOptions = T,
        #               striped = T,
        #               outlined = F,
        #               bordered = T,
        #               highlight = F,
        #               filterable = F
        #     )
        # )

        
    }
  )
}