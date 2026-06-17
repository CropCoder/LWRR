mod_trait_UI <- function(id) {
    ns <- NS(id)
    tagList(
        tags$div(class = "alert alert-success", role = "alert",
                 strong("Tip: "), "You can query the phenotype data on this page, which mainly includes two parts, wheat seedling phenotype using different physiological species identification. The adult phenotype was identified after inoculation of stripe rust in the field based on different environments."),
        h3("The phenotype of wheat yellow rust during the seedling stage."),
        card(
            p("Please select a Pst race to view the phenotype :"),
            radioGroupButtons(
                inputId = ns("Select_phe_miaoqi"),
                label = NULL,
                choices = c(index_trait[1:12]),
                selected = index_trait[1],
                size = "sm",
                justified = T
            ),
            layout_column_wrap(
                1/4,
                withSpinner(plotlyOutput(ns("MQ_Box_plot"))),
                withSpinner(plotlyOutput(ns("trait_violin"))),
                withSpinner(plotlyOutput(ns("trait_hist_plot"))),
                withSpinner(plotlyOutput(ns("trait_density_plot")))
            ),
            tags$div(class = "alert alert-danger", role = "alert",
                     strong("Note:"), "The above shows the differences in the disease resistance of wheat to different pathogen physiological races. According to the box plot, violin plot, histogram and density plot, the differences in disease resistance of wheat among different breeding populations can be intuitively understood. "),
            # BGheatmap----
            # h3("Please select a breeding group to view the heat map ")
            radioGroupButtons(
                inputId = ns("Select_phe_CYR_BG"),
                label = NULL,
                choices = c("BG1","BG2","BG3","BG4","LC"),
                selected = "BG1",
                size = "sm",
                # direction = "vertical",
                justified = T
            ),
            plotlyOutput(ns("phe_heatmap_CYR"),height = "200px")
        ),
        
        # IT ----
        h3("Adult-Plant Resistance of wheat yellow rust phenotypes"),

        layout_column_wrap(
            1/2,
            card(
                card_header("Best linear unbiased estimate(BLUE) of IT (Infection Type) "),
                radioGroupButtons(
                    inputId = ns("Select_phe_IT"),
                    label = NULL,
                    choiceValues = c(index_trait[13:19]),
                    choiceNames = c(index_trait[13:19] %>% str_replace("IT_","") ),
                    size = "sm",
                    justified = T
                ),
                withSpinner(plotlyOutput(ns("IT_Box_plot"))),
                radioGroupButtons(
                inputId = ns("Select_phe_IT_BG"),
                label = NULL,
                choices = c("BG1","BG2","BG3","BG4","LC"),
                selected = "BG1",
                size = "sm",
                justified = T
                ),
                plotlyOutput(ns("phe_heatmap_IT"),height = "200px")
            ),
            card(
                card_header("Best linear unbiased estimate(BLUE) of DS (Disease Severity)"),
                radioGroupButtons(
                    inputId = ns("Select_phe_DS"),
                    label = NULL,
                    choiceValues = c(index_trait[20:26]),
                    choiceNames = c(index_trait[20:26] %>% str_replace("DS_","") ),
                    size = "sm",
                    justified = T
                ),
                withSpinner(plotlyOutput(ns("DS_Box_plot"))),
                radioGroupButtons(
                inputId = ns("Select_phe_DS_BG"),
                label = NULL,
                choices = c("BG1","BG2","BG3","BG4","LC"),
                selected = "BG1",
                size = "sm",
                justified = T
                ),
                plotlyOutput(ns("phe_heatmap_DS"),height = "200px")
            )
        ),
        tags$div(class = "alert alert-success", role = "alert",
                     strong("Tips："), "Wheat yellow rust is a disease that poses a significant threat to wheat production. Typically, symptoms appear on the leaves. Commonly used phenotypic identification methods are divided into two types: the first method classifies infection severity into ten different levels based on Infection Type (IT), while the second method evaluates the Disease Severity (DS) by assessing the overall disease severity as a percentage."),
        h3("Phenotypic identification methods and standards for wheat yellow rust"),  
        card(
            tags$img(src="fig/trait_plot.png", width = "100%")
        )
       

    )
}

mod_trait_Server <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            
            # miaoqi_heatmap----
            output$miaoqi_heatmap <- renderEcharts4r({
                data <- S1_sample[,c()]
            })
            
            
            output$trait_violin <- renderPlotly({
                data <- S1_sample[,c("RunID","BreedingGroup",input$Select_phe_miaoqi)]
                colnames(data) <- c("RunID","BG","Value")
                
                p <- ggplot(data) +
                    geom_violin(aes(x=BG,y=Value,fill=BG),trim = F) +
                    labs(
                        # title = "Identification grade of yellow rust (CYR)",
                         x = "Sample Group",
                         y = "Phenotypic value") +
                    theme_bw()+
                    ggplot2::theme(legend.position = "none")
                ggplotly(p)
            })
            
            
            # BG_trait_hist_CYR----
            output$trait_hist_plot <- renderPlotly({
                data <- S1_sample[,c("RunID","BreedingGroup",input$Select_phe_miaoqi)]
                colnames(data) <- c("RunID","BG","Value")
                
                p <- ggplot(data, aes(x = Value)) +
                    geom_histogram(aes(y = ..count.., fill = ..x..), bins = 10, color = "black") +
                    scale_fill_gradient(low = "#2b8a3e", high = "#fdbb2d") +
                    labs(
                        # title = "Identification grade of yellow rust (CYR)",
                         x = "Phenotypic value",
                         y = "Count") +
                    theme_bw()+
                    ggplot2::theme(legend.position = "none")
                
                
                # 添加渐变色
                p <- p + geom_histogram(aes(y = ..count.., fill = ..x..), bins = 10, color = "black") +
                    scale_fill_gradient(low = "#2b8a3e", high = "#fdbb2d",name = "Degree")
                
                ggplotly(p)
            })
            
            # MQ_Box_plot----
            output$MQ_Box_plot <- renderPlotly({
                data <- S1_sample[,c("RunID","BreedingGroup",input$Select_phe_miaoqi)] %>% 
                    drop_na()
                phe <- input$Select_phe_miaoqi
                
                colnames(data) <- c("ID","Group","Value")
                
                p <- ggplot(data,aes(x=Group,y=Value))+
                    geom_jitter(alpha = 0.1,position = position_jitter(0.2), 
                                aes(color = Group,text=ID)) +
                    geom_boxplot(aes(fill = Group),alpha = 0.7,position=position_dodge(1.2))+
                    labs(
                        # title = "Identification grade of yellow rust (CYR)",
                        x = "Sample Group",
                        y = "Phenotypic value") +
                    theme_bw()+
                    ggplot2::theme(legend.position = "none")
                
                ggplotly(p)
            })
            
            
            # trait_density_plot ----
            output$trait_density_plot <- renderPlotly({
                
                data <- S1_sample[,c("RunID","BreedingGroup",input$Select_phe_miaoqi)]
                colnames(data) <- c("RunID","BG","Value")
                
                p <- ggplot(data %>% filter(BG %in% c("BG1","BG2","BG3","BG4")), aes(x = Value,color=BG,fill=BG)) +
                    geom_density(alpha=0.5)+
                    # facet_wrap(~BG,ncol = 2,scales="free_y")+
                    labs(
                        # title = "Identification grade of yellow rust (CYR)",
                        x = "Phenotypic value",
                        y = "Count") +
                    theme_bw()+
                    ggplot2::theme(legend.position = "none")
                # p
                ggplotly(p)
                
            })
            
            # BGheatmap----
            output$phe_heatmap_CYR <- renderPlotly({
                data <- S1_sample[which(S1_sample$BreedingGroup == input$Select_phe_CYR_BG),c(2,17:20,23:25)] %>% 
                    drop_na()
                
                long_data <- pivot_longer(data, cols = starts_with("CYR"), names_to = "Year", values_to = "Value")
                
                # 使用ggplot2绘制热图----
                p <- ggplot(long_data, aes(x = RunID, y = Year, fill = Value)) +
                    geom_tile(color = "white") + # 添加边框
                    scale_fill_gradient(low = "#27ae60", high = "#f39c12") +
                    theme_bw() +
                    labs(title = "",
                         x = str_c("Samples of ",input$Select_phe_CYR_BG),
                         y = "Pst type",
                         fill = "Value") +
                    ggplot2::theme(legend.position = "none") +  # 隐藏图例
                    ggplot2::theme(axis.text.x = element_blank())
                
                ggplotly(p)
            })

            # IT_Box_plot----
            output$IT_Box_plot <- renderPlotly({
                data <- S1_sample[,c("RunID","BreedingGroup",input$Select_phe_IT)]
                colnames(data) <- c("RunID","BG","Value")

                p <- ggplot(data,aes(x=BG,y=Value))+
                    geom_boxplot(aes(fill = BG),alpha = 0.7,position=position_dodge(1.2))+
                    labs(
                        x = "Sample Group",
                        y = "Phenotypic value") +
                    theme_bw()+
                    ggplot2::theme(legend.position = "none")
                ggplotly(p)
                
            })
            
            # DS_Box_plot----
            output$DS_Box_plot <- renderPlotly({
                data <- S1_sample[,c("RunID","BreedingGroup",input$Select_phe_DS)]
                colnames(data) <- c("RunID","BG","Value")

                p <- ggplot(data,aes(x=BG,y=Value))+
                    geom_boxplot(aes(fill = BG),alpha = 0.7,position=position_dodge(1.2))+
                    labs(
                        x = "Sample Group",
                        y = "Phenotypic value") +
                    theme_bw()+
                    ggplot2::theme(legend.position = "none")
                ggplotly(p)
            })

            # phe_heatmap_IT----
            output$phe_heatmap_IT <- renderPlotly({
                data <- S1_sample[which(S1_sample$BreedingGroup == input$Select_phe_IT_BG),c(2,29:35)] %>% 
                    drop_na()
                
                long_data <- pivot_longer(data, cols = starts_with("IT") , names_to = "Type", values_to = "Value")

                # 使用ggplot2绘制热图----
                p <- ggplot(long_data, aes(x = RunID, y = Type, fill = Value)) +
                    geom_tile(color = "white") + # 添加边框
                    scale_fill_gradient(low = "#27ae60", high = "#f39c12") +
                    theme_bw() +
                    labs(title = "",
                         x = str_c("Samples of ",input$Select_phe_IT_BG),
                         y = "",
                         fill = "Value") +
                    ggplot2::theme(legend.position = "none") +  # 隐藏图例
                    ggplot2::theme(axis.text.x = element_blank())
                
                ggplotly(p)
            })

            # phe_heatmap_DS----
            output$phe_heatmap_DS <- renderPlotly({
                data <- S1_sample[which(S1_sample$BreedingGroup == input$Select_phe_DS_BG),c(2,36:42)] %>% 
                    drop_na()
                
                long_data <- pivot_longer(data, cols = starts_with("DS") , names_to = "Type", values_to = "Value")   

                # 使用ggplot2绘制热图----
                p <- ggplot(long_data, aes(x = RunID, y = Type, fill = Value)) +
                    geom_tile(color = "white") + # 添加边框
                    scale_fill_gradient(low = "#27ae60", high = "#f39c12") +
                    theme_bw() +
                    labs(title = "",
                         x = str_c("Samples of ",input$Select_phe_DS_BG),
                         y = "",
                         fill = "Value") +
                    ggplot2::theme(legend.position = "none") +  # 隐藏图例
                    ggplot2::theme(axis.text.x = element_blank())
                
                ggplotly(p)
            })
        }
    )
}