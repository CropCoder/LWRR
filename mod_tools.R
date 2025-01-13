mod_tools_UI <- function(id) {
  ns <- NS(id)
  tagList(
      useShinyjs(),
      tags$div(class = "alert alert-success", role = "alert",
               strong("Message："), "Welcome to the Toolbox, our online analysis tool for candidate gene research. You can upload and analyze your own data online."),
      br(),
      card(
          layout_column_wrap(
              1/2,
              # input file----
              card(
                  fileInput(
                      inputId = ns("up_file_vcf"),width = "100%",placeholder = "Please upload a VCF file for a gene in wheat",
                      label = "Upload your Gene Type file(vcf)",multiple = F,accept = c(".vcf",".vcf.gz")
                  ),
                  downloadLink(ns("down_test_vcf"),label = "Click here to download the example VCF file"),
                  fileInput(
                      inputId = ns("up_file_phe"),width = "100%",placeholder = "Please upload the matching phenotype file",
                      label = "Upload your Trait file(xlsx)",multiple = F,accept = ".xlsx"
                  ),
                  downloadLink(ns("down_test_phe"),label = "Click here to download the example Trait file")
              ),
              card(
                  card_header("Tip"),
                  card_body("Wheat is one of the most important grain crops. Currently, the global wheat production is threatened by the potential of wheat stripe rust. The best measure to control wheat stripe rust is to cultivate disease-resistant varieties with excellent resistance to wheat stripe rust."),
                  p("Sample names and phenotype names must not contain special characters, use letters as the first character, and use NA to fill in missing values."),
                  p("You need to upload the file in standard format (please download to see example data) first and then analyze it.")
              )
          ),
          # run init----
          actionButton(ns("run_init"),"Please upload the file first and then click here to initialize the analysis",
                       icon("magnifying-glass"), class = "btn-success m-2",width = "100%"),
          
          card(
              tabsetPanel(
                  # summary ----
                  tabPanel("Summary",icon = icon("circle-info"),br(),
                           uiOutput(ns("sumary_stat")),br(),
                           card(
                               card_header("VCF file table"),
                               DTOutput(ns("vcf_table")),height = 650
                               )
                           ),
                  # SGAT UI----
                  tabPanel("SGAT",icon = icon("arrow-right"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "This tool is based on the R language rMVP package implementation,Provide correlation analysis of different models."),
                           br(),
                           layout_column_wrap(
                               1/4,
                               selectInput(ns("SGAT_Model"),"Choice model",
                                           selected = "MLM",
                                           choices = c("GLM","MLM","FarmCPU"),multiple = F),
                               selectInput(ns("SGAT_trait"),"Choice trait",
                                           choices = NULL,multiple = F),
                               numericInput(ns("SGAT_mythrehold"),label = "threshold",
                                                value = 0.05,min = 0,max = 1,step = 100),
                               textInput(ns("mygeneid"),label = "Gene ID",placeholder = "TraesCS1A03G0949800")
                               ),
                           actionButton(ns("run_SGAT"),label = "Run SGAT",icon = icon("arrow-right")),
                           p("Note :After each parameter change, please click the button to analyze it."),
                           br(),
                           uiOutput(ns("SGAT_plot")),
                           card(
                               card_header("Manhattan plot of candidate gene association analysis results"),
                               plotlyOutput(ns("SGAT_mdh_plotly"),width = "100%",height = 300),
                               full_screen = T
                           ),
                           card(
                               DTOutput(ns("SGAT_table")),height = 650,
                               full_screen = T
                           ),
                           downloadBttn(ns("downlaod_SGAT"),label = "Download SGAT Result",icon = icon("download"),color="success")
                           ),
                  # singlemark UI----
                  tabPanel("SingleMarker",icon = icon("star"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "The use of single marker analysis tools enables multiple testing of variant site phenotypes."),
                           br(),
                           # 调用python实现
                           actionButton(ns("run_singlemark"),label = "Run Single Mark Tool",icon = icon("arrow-right")),
                           br(),
                           card(
                               DTOutput(ns("DT_singlemark"),height = 650)
                                )
                           ),
                  tabPanel("LDBlock", icon = icon("magnet"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "The use of single marker analysis tools enables multiple testing of variant site phenotypes."),
                           br(),
                           # 调用linux实现
                           actionButton(ns("run_LD"),label = "Run LD Block Tool",icon = icon("arrow-right")),
                           br(),
                           ),
                  tabPanel("PheBoxPlot",icon = icon("palette"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "."),
                           br(),
                           
                           ),
                  tabPanel("GeneHAP",icon = icon("compass"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "The use of single marker analysis tools enables multiple testing of variant site phenotypes."),
                           br(),
                           ),
                  tabPanel("RNAseqTPM", icon = icon("magnet"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "The use of single marker analysis tools enables multiple testing of variant site phenotypes."),
                           br(),
                           )
              ),
              textOutput(ns("userid"))
          )
          
          
      )
      
    
  )
}

mod_tools_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
        ns <- session$ns
        
        userUID <- str_sub(uuid::UUIDgenerate(),26,36)
        output$userid <- renderText({paste0("Your visite ID :",userUID," , Server Time:",Sys.time())})
        
        # example vcf ----
        output$down_test_vcf <- downloadHandler(
            filename = function(){
                "Example_GeneType.filter.vcf"
            },
            content = function(file){
                file.copy(from = "www/download/Example_GeneType.filter.vcf",to = file)
            }
        )
        
        # example trait----
        output$down_test_phe <- downloadHandler(
            filename = function(){
                "Example_trait_file.xlsx"
            },
            content = function(file){
                file.copy(from = "www/download/Example_trait_file.xlsx",to = file)
            }
        )
        
        # run init----
        observeEvent(input$run_init,{
            # dev test
            req(input$up_file_vcf)
            req(input$up_file_phe)
            
            dir.create(paste0("www/OUT/",userUID))
            
            
            # # if not vcf , use gunzip convert to vcf
            # if(substr(input$up_file_vcf$datapath, nchar(input$up_file_vcf$datapath), nchar(input$up_file_vcf$datapath)) == "z"){
            #     file.copy(input$up_file_vcf$datapath,paste0("www/OUT/",userUID,"/user_upload.vcf.gz"))
            #     gunzip(paste0("www/OUT/",userUID,"/user_upload.vcf.gz"),remove = FALSE)
            # }else{
            #     file.copy(input$up_file_vcf$datapath,paste0("www/OUT/",userUID,"/user_upload.vcf"))
            # }
            # 
            # user_upload_vcf_file_name <- paste0("www/OUT/",userUID,"/user_upload.vcf")
            # 
            shinyalert("Parsing data", "Please do not close the page...It will take about 1 minute. If there is no response after the timeout, please refresh the page", 
                       type = "info", closeOnEsc = FALSE, closeOnClickOutside = FALSE, showConfirmButton = FALSE)
            
            # get data ----
            # data_vcf <- get_vcf_df() # dev test
            # data_trait <- get_trait_df() # dev test
            
            data_vcf <- get_vcf_df(input$up_file_vcf$datapath)
            data_trait <- get_trait_df(input$up_file_phe$datapath)
            
            write_tsv(data_trait$df_phe,file = paste0("www/OUT/",userUID,"/user_upload_trait.tsv"),col_names = T,na = "NA")
            
            # summary stat ----
            output$sumary_stat <- renderUI(
                list(
                    tags$div(class = "alert alert-success", role = "alert",
                             strong("Tip："), "Hello, your uploaded file has been automatically parsed by the cloud platform, you can preview part of the VCF file and phenotype file below. Please make sure the data is correct and click the tab above to analyze."),
                    layout_column_wrap(
                        width=1/3,
                        value_box(
                            title = "Sample Number",
                            value = length(data_vcf$sample_list),
                            showcase = bs_icon("list-check")
                        ),
                        value_box(
                            title = "Marker Number",
                            value = length(data_vcf$SNP_list),
                            showcase = bs_icon("list-check")
                        ),
                        value_box(
                            title = "Trait Number",
                            value = length(data_trait$phe_list),
                            showcase = bs_icon("list-check")
                        )
                     ),
                    tags$div(class = "alert alert-info", role = "alert",
                             "Only the first 8 columns of the VCF file (genotype marker locus information) and the first 20 rows of the phenotype are shown below, for checking and confirming the data format only")
                )
            )
            
            # vcf table ----
            output$vcf_table <- renderDT(data_vcf$df_table)
            
            # phe table ----
            output$phe_table <- renderDT(data_trait$df_phe_view)
            
            updateSelectInput(session, "SGAT_trait", choices = data_trait$phe_list)
            
            
            
            # init SGAT data ----
            SGAT_init(file_vcf = input$up_file_vcf$datapath,
                      file_phe = paste0("www/OUT/",userUID,"/user_upload_trait.tsv"),
                      userUID = userUID)
            
            log_file <- list.files(paste0("www/OUT/",userUID,"/SGAT_OUT/"),pattern = "MVP.Data.*.log")
            
            shinyjs::runjs("swal.close();")
            
            showModal(
                modalDialog(
                    title = "Data reading log",
                    size = "l",
                    easyClose = T,
                    tagList(
                        tags$pre(style = "font-family: monospace; width: 100%;", 
                                 getFileContent(paste0("www/OUT/",userUID,"/SGAT_OUT/",log_file)))
                    )
                )
            )
        })
        
        
        
        ## SGAT ----
        observeEvent(input$run_SGAT,{
            req(input$SGAT_trait)
            shinyalert("SGAT Running", "Please do not close the page...", type = "info", closeOnEsc = FALSE, closeOnClickOutside = FALSE, showConfirmButton = FALSE)
            
            SGAT_OUT <- SGAT_rMVP(which_trait = input$SGAT_trait,which_model = input$SGAT_Model,
                                  userUID = userUID,mythrehold=input$SGAT_mythrehold,mygeneid = input$mygeneid)
            
            
            output$SGAT_plot <- renderUI(
                card(
                    layout_column_wrap(
                        1/3,
                        tags$img(src= paste0("OUT/",userUID,"/SGAT_OUT/",input$SGAT_trait,".",input$SGAT_Model,".QQplot.jpg") , style = "width: 100%;"),
                        tags$img(src= paste0("OUT/",userUID,"/SGAT_OUT/",input$SGAT_trait,".Phe_Dist.jpg") , style = "width: 100%;"),
                        tags$img(src= paste0("OUT/",userUID,"/SGAT_OUT/",input$SGAT_trait,".PCA_2D.jpg") , style = "width: 100%;")
                    )
                    
                )
            )
            
            
            # plotly mamhatun
            output$SGAT_mdh_plotly <- renderPlotly({
                p_mdh <- ggplot(SGAT_OUT$p_mdh_plotly_data,aes(POS,P,text = SNP))+
                    geom_point(aes(color= Effect),size=4,alpha=0.8)+
                    scale_color_gradient(low = "#c3fae8",high = "#087f5b")+
                    ylab("MLM")+
                    xlab(str_c("Physical Postion (IWGSC 2.1)"))+
                    theme_bw()
                plotly::ggplotly(p_mdh)
            })
            
            
            output$SGAT_table <- renderDT({
                vroom(paste0("www/OUT/",userUID,"/SGAT_OUT/",input$SGAT_trait,".",input$SGAT_Model,".csv"))
            })

            shinyjs::runjs("swal.close();")
            
            # log_file <- list.files(paste0("www/OUT/",userUID,"/SGAT_OUT/"),pattern = "MVP.*.log") %>% sort()
            # log_file_new <- log_file[length(log_file)-1]
            # 
            # showModal(
            #     modalDialog(
            #         title = "Data reading log",
            #         size = "l",
            #         easyClose = T,
            #         tagList(
            #             tags$pre(style = "font-family: monospace; white-space: pre-wrap; width: 100%;", 
            #                      getFileContent(paste0("www/OUT/",userUID,"/SGAT_OUT/",log_file)))
            #         )
            #     )
            # )

            down_file_SGAT <- SGAT_OUT$out_zip_file
            print(down_file_SGAT)
            output$downlaod_SGAT <- downloadHandler(
                filename = function(){
                    down_file_SGAT
                },
                content = function(file){
                    file.copy(down_file_SGAT,file)
                }
            )
        })
        
        #singlemark ----
        observeEvent(input$run_singlemark,{
            req(input$up_file_vcf)
            req(input$up_file_phe)
            
            shinyalert("SGAT Running", "Please do not close the page...", type = "info", closeOnEsc = FALSE, closeOnClickOutside = FALSE, showConfirmButton = FALSE)
            
            # 进度条
            withProgress(message = 'Running task', value = 0, {
                n <- 10  # 任务的步骤数
                
                for (i in 1:n) {
                    # 模拟长时间运行的任务
                    Sys.sleep(0.5)
                    
                    # 更新进度条
                    incProgress(1/n, detail = paste("Step", i, "of", n))
                }
            })
            
            
            output$DT_singlemark <- renderDT(
                phe
            )
            
            shinyjs::runjs("swal.close();")
        })
        
        
        
        # 当用户退出60秒后删除临时目录
        onSessionEnded(function() {
            later(function() {
                unlink("rm.txt", recursive = TRUE)
            },delay = 600)  # 600秒后删除文件
        })
        
        # # 指定要删除文件的目录
        # temp_directory <- paste0("www/OUT/",userUID)
        # 
        # # 在用户会话结束时删除目录下的所有文件
        # session$onSessionEnded(function() {
        #     files <- list.files(temp_directory, full.names = TRUE)
        #     file.remove(files)
        #     # 自定义删除
        # })
            
        })
}