mod_GWAS_UI <- function(id) {
  ns <- NS(id)
  tagList(
      tags$div(class = "alert alert-success", role = "alert",
               strong("Introduction："), "This page provides GWAS results database search function, you can select the phenotype, analysis model, chromosome, physical location, significance threshold and other parameters to obtain GWAS results in real time."),
      # plotGWAS----
      card(
          card_header("Gene GWAS Result Detail "),full_screen = T,
          radioButtons(
              inputId = ns("GWAS_Phe"),inline = T,label = NULL,choices = GWAS_Trait_list,selected = "DS.21YL"
          ),
          layout_column_wrap(
              1/5,
              selectInput(
                  inputId = ns("which_model"),
                  label = "Model",
                  choices = c("MLM","FarmCPU"),
                  selected = "MLM"
              ),
              selectInput(
                  inputId = ns("which_chr"),
                  label = "Pvalue >",
                  choices = chr_convert$new,
                  selected = "1A"
              ),
              numericInput(ns("GWAS_start"),"Start(MB)",value = 290),
              numericInput(ns("GWAS_end"),"End(MB)",value = 300),
              numericInput(ns("GWAS_p"),"Min -log10(P)",value = 3)
          ),
          div(
              # actionButton(ns("run_get_GWAS"),"Get Result of GWAS", 
              #              icon("magnifying-glass"), class = "btn-success m-2"),
              # br(),
              p(" ✨ Select a specified trait to view the GWAS result. The larger the range, the longer the wait time")
          ),
          card(
              card_header("Results of whole-chromosome horizontal association analysis"),
              full_screen = T,
              uiOutput(ns("plot_gwas_png"))
          ),
          card(
              card_header("Narrow the GWAS association analysis results for the specified interval"),
              full_screen = T,
              plotlyOutput(ns("plot_GWAS"),height = "300px")
          ),
          tags$div(class = "alert alert-success", role = "alert",
                   strong("tip："), "You can click on the dots in the image above to get location information."),
          h5("The variation information corresponding to the significant peak"),
          DTOutput(ns("GWAS_sign_table"))
      )
  )
}

mod_GWAS_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
        
        output$plot_gwas_png <- renderUI({
            # CYR23L.FarmCPU.1e-2.result.subgenome.png
            fluidRow(
                column(
                    8,
                    tags$img(src=str_c("./GWAS_Plot/",input$GWAS_Phe,".",input$which_model,".1e-2.result.png"),style="width:98%")
                ),
                column(
                    4,
                    tags$img(src=str_c("./GWAS_Plot/",input$GWAS_Phe,".",input$which_model,".1e-2.result.subgenome.png"),style="width:100%")
                )
            )
        })
        
        
      
        output$plot_GWAS <- renderPlotly({
            
            which_chr <- input$which_chr
            which_model <- input$which_model
            which_phe <- input$GWAS_Phe
            which_min <- input$GWAS_p
            which_start <- input$GWAS_start
            which_end <- input$GWAS_end
            
            
            data <- dbGetQuery(db,str_c(
                "SELECT * FROM `GWAS.",which_model,".",which_phe,
                "` WHERE Postion > ",which_start," AND Postion < ",
                which_end," AND logP > ",which_min," AND chr = '",which_chr,"'"
            ))
            
            
            p <- ggplot(data,aes(Postion,logP,text = SNP))+
                geom_point(aes(color= eff),size=3,alpha=0.8)+
                scale_color_gradient(low = "#c3fae8",high = "#087f5b")+
                ylab("-log10(GWAS.Pvalue)")+
                xlab(str_c("Physical Postion (IWGSC 2.1)"))+
                theme_bw()
            ggplotly(p)

        })
        
        output$GWAS_sign_table <- renderDT({
            which_chr <- input$which_chr
            which_model <- input$which_model
            which_phe <- input$GWAS_Phe
            which_min <- input$GWAS_p
            which_start <- input$GWAS_start
            which_end <- input$GWAS_end
            
            data <- dbGetQuery(db,str_c(
                "SELECT * FROM `GWAS.",which_model,".",which_phe,
                "` WHERE Postion > ",which_start," AND Postion < ",
                which_end," AND logP > ",which_min," AND chr = '",which_chr,"'"
            ))
            
            datatable(
                data,
                extensions = c('Buttons'),
                options = list(
                    lengthChange = FALSE,  # 禁止改变每页显示的行数
                    pageLength = 6,         # 设置每页显示6行
                    dom = 'Blfrtip',        # 启用Buttons插件
                    buttons = c('copy', 'csv', 'excel')  # 添加复制、CSV和Excel导出按钮
                )
            )
        })
        
        # output$GWAS_sign_table <- renderDT({
        #     
        #     
        #     
        #     
        #     
        #     
        #     data
        #     
        # },options = list(
        #     lengthChange = FALSE,  # 禁止改变每页显示的行数
        #     pageLength = 6         # 设置每页显示6行
        # ))
        
    }
  )
}