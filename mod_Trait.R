mod_trait_UI <- function(id) {
    ns <- NS(id)
    tagList(
        tags$div(class = "alert alert-success", role = "alert",
                 strong("Note："), "This page provides phenotype data and statistical analysis functions, allowing users to choose between seedling and adult stages for analysis."),
        h3("Query phenotype of seedling stage (CYR)"),
        card(
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
                     strong("Tips:"), "This page provides phenotype data and statistical analysis functions, allowing users to choose between seedling and adult stages for analysis."),
            # BGheatmap----
            radioGroupButtons(
                inputId = ns("Select_phe_CYR_BG"),
                label = NULL,
                choices = c("BG1","BG2","BG3","BG4","LC"),
                selected = "BG1",
                size = "sm",
                # direction = "vertical",
                justified = T
            ),
            plotlyOutput(ns("phe_heatmap_CYR"))
        )
        
        # radioGroupButtons(
        #     inputId = ns("Select_phe_IT"),
        #     label = "Select IT Trait :",
        #     choices = c(index_trait[13:19]),
        #     size = "sm",
        #     justified = T
        # ),

        
        # radioGroupButtons(
        #     inputId = ns("Select_phe_DS"),
        #     label = "Select DS Trait :",
        #     choices = c(index_trait[20:26]),
        #     size = "sm",
        #     justified = T
        # )
       

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
                
                # 使用ggplot2绘制热图
                p <- ggplot(long_data, aes(x = RunID, y = Year, fill = Value)) +
                    geom_tile(color = "white") + # 添加边框
                    scale_fill_gradient(low = "#27ae60", high = "#f39c12") +
                    theme_bw() +
                    labs(title = "",
                         x = "Sample ID",
                         y = "Stripe rust type",
                         fill = "Value")+
                    ggplot2::theme(axis.text.x = element_blank())
                
                ggplotly(p)
            })
            
            
        }
    )
}