mod_tools_UI <- function(id) {
  ns <- NS(id)
  tagList(
      useShinyjs(),
      tags$div(class = "alert alert-success", role = "alert",
               strong("Tip: "), "You can perform online analysis on this page. Please download the sample file first, and then upload the data according to the data format of the sample. After uploading, click the green button for analysis, and then perform candidate gene analysis on the following sub-function page."),
      h3("Analysis of wheat resistance candidate genes"),
      card(
          layout_column_wrap(
              1/2,
              # input file----
              card(
                  fileInput(
                      inputId = ns("up_file_vcf"),width = "100%",placeholder = "Please upload a VCF file for a gene in wheat",
                      label = "Upload your Gene Type file(vcf)",multiple = F,accept = c(".vcf")
                  ),
                  tags$a(href = "./download/Example_GeneType.filter.vcf", 
                        "🔗 Click here to download the example GenoType File (vcf)", 
                        target = "_blank",
                        style = "color: #2980b9; text-decoration: none; font-size: 16px;"),
                  fileInput(
                      inputId = ns("up_file_phe"),width = "100%",placeholder = "Please upload the matching phenotype file",
                      label = "Upload your Trait file(xlsx)",multiple = F,accept = ".xlsx"
                  ),
                  tags$a(href = "./download/Example_trait_file.xlsx", 
                        "🔗 Click here to download the example Trait File (xlsx)", 
                        target = "_blank",
                        style = "color: #2980b9; text-decoration: none; font-size: 16px;")
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
          h3("Output Result : (Please upload data for analysis first)"),
          card(
              tabsetPanel(
                  # summary ----
                  tabPanel("Data Summary",icon = icon("circle-info"),br(),
                           uiOutput(ns("sumary_stat")),br(),
                           card(
                               card_header("VCF file table"),
                               DTOutput(ns("vcf_table")),height = 650
                               )
                           ),
                  # SGAT UI----
                  tabPanel("Association Analysis",icon = icon("redo"),br(),
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
                               textInput(ns("mygeneid"),label = "Gene ID",value = "TraesCS1A03G0949800")
                           ),
                           actionButton(ns("run_SGAT"),label = "Run SGAT",icon = icon("arrow-right"),width = "280px"),
                           p("Note :After each parameter change, please click the button to analyze it.(Association analysis was performed based on candidate genes)"),
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
                  tabPanel("Single Marker Significance",icon = icon("star"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "The use of single marker analysis tools enables multiple testing of variant site phenotypes. You can select a mutation site and see how it relates to the phenotype."),
                           br(),
                           selectInput(ns("singlemark_select_phe"),label = "Choice Trait",choices = NULL,width = "300px"),
                           br(),
                           actionButton(ns("run_singlemark"),label = "Run Single Mark Tool",icon = icon("arrow-right"),width = "300px"),
                           br(),
                           echarts4rOutput(ns("singlemark_plot")),
                           br(),
                           card(
                            DTOutput(ns("DT_singlemark")),
                            high_screen = T,
                            height = "600px"
                           )
                           ),
                  tabPanel("LDBlock Analysis", icon = icon("magnet"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "The use of single marker analysis tools enables multiple testing of variant site phenotypes.This tool is based on LDBlockshow (https://github.com/BGI-shenzhen/LDBlockShow)"),
                           br(),
                           actionButton(ns("run_LD"),label = "Run LD Block Tool",icon = icon("arrow-right"),width = "300px"),
                           br(),
                           uiOutput(ns("LD_plot")),
                           br(),
                           ),
                  tabPanel("Gene Haplotype",icon = icon("compass"),br(),
                           tags$div(class = "alert alert-success", role = "alert",
                                    strong("Abstract ："), "The use of single marker analysis tools enables multiple testing of variant site phenotypes."),
                           br(),
                          fluidRow(
                            column(4,
                                   list(
                                    selectInput(ns("hap_select_phe"),label = "Choice Trait",choices = NULL,width = "100%"),
                                    numericInput(ns("hap_num"),label = "HAP Number",value = 4,min = 2,max = 10,width = "100%"),
                                    actionButton(ns("run_haplotype"),label = "Run",icon = icon("arrow-right"),width = "100%"),
                                    br(),
                                    p("📢 Select a phenotype to determine the difference between haplotypes. The HAP Number parameter specifies the expected number of haplotypes. The results are divided into different haplotypes according to the clustering algorithm")
                                   )
                            ),
                            column(8,
                                   uiOutput(ns("GeneHAP_plot_cluster"))
                            )
                          ),br(),
                           layout_column_wrap(
                               1/2,
                               card(
                                   DTOutput(ns("GeneHAP_DT"))
                               ),
                               card(
                                   uiOutput(ns("GeneHAP_plot_test"))
                               )
                           )
                           ),
                  tabPanel("Download Result",icon = icon("compass"),
                           br(),
                           actionButton(ns("run_download"),label = "Click here to download all results",icon = icon("download"),width = "400px")
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
        output$userid <- renderText({paste0("Your visite ID :",userUID," , Server Time:",Sys.time() %>% str_sub(1,10))})
        
        
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
            shinyalert("Parsing data", "Please do not close the page...It will take about 1 minute. \nIf no response after the timeout, please refresh the page", 
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
            updateSelectInput(session, "singlemark_select_phe", choices = data_trait$phe_list)
            updateSelectInput(session, "hap_select_phe", choices = data_trait$phe_list)
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
                                 getFileContent(paste0("www/OUT/",userUID,"/SGAT_OUT/",log_file))),
                        p("This analysis tool based on rMVP (https://github.com/xiaolei-lab/rMVP)")
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
            req(input$singlemark_select_phe)
            
            shinyalert("Single Marker Significance", "Please do not close the page...", type = "info", closeOnEsc = FALSE, closeOnClickOutside = FALSE, showConfirmButton = FALSE)
           
            # Run single marker analysis
            singlemark_out <- run_singlemark(
                input$up_file_vcf$datapath,
                input$up_file_phe$datapath,
                userUID,
                input$singlemark_select_phe)

            output$DT_singlemark <- renderDT(
                singlemark_out$df_out
            )

            output$singlemark_plot <- renderEcharts4r(
                singlemark_out$bar_plot
            )
            
            shinyjs::runjs("swal.close();")
        })


        # LD Block ----
        observeEvent(input$run_LD,{
            req(input$up_file_vcf)
            req(input$up_file_phe) 

            shinyalert("Running LD Block", "Please do not close the page...", type = "info", closeOnEsc = FALSE, closeOnClickOutside = FALSE, showConfirmButton = FALSE)

            LD_out <- run_LDBlock(file_vcf = input$up_file_vcf$datapath,userUID = userUID)

            output$LD_plot <- renderUI(
                layout_column_wrap(
                    1/2,
                    card(
                        img(src = paste0("OUT/",userUID,"/LDBlock_Result/ld_block_result_fix.svg"),width = "100%"),
                        full_screen = T
                    ),
                    card(
                        tags$pre(style = "font-family: monospace; width: 100%;", 
                                 getFileContent(paste0("www/OUT/",userUID,"/LDBlock_Result/ld_block_result.blocks"))),
                        full_screen = T
                    )
                )
            )

            shinyjs::runjs("swal.close();")
        })

        # Gene Haplotype ----
        observeEvent(input$run_haplotype,{
            req(input$up_file_vcf)
            req(input$up_file_phe)

            shinyalert("Running Gene Haplotype", "Please do not close the page...", type = "info", closeOnEsc = FALSE, closeOnClickOutside = FALSE, showConfirmButton = FALSE)

            GeneHAP_out <- run_GeneHAP(file_vcf = input$up_file_vcf$datapath,
                                       file_phe = input$up_file_phe$datapath,
                                       userUID = userUID,
                                       hap_num = input$hap_num,
                                       select_phe = input$hap_select_phe)

            output$GeneHAP_plot_cluster <- renderUI(
                tags$iframe(style = "height:350px;width:100%", frameborder="0",
                        src = paste0("OUT/",userUID,"/GeneHAP_Result/GeneHAP_heatmap.pdf"))
            )

            

            output$GeneHAP_plot_test <- renderUI(
                tags$img(src=paste0("OUT/",userUID,"/GeneHAP_Result/GeneHAP_HAP_Trait_plot.png"),style="width:100%")
            )

            output$GeneHAP_plot <- renderPlotly(
                GeneHAP_out$plotly_phe
            )

            output$GeneHAP_DT <- renderDT(
                GeneHAP_out$out_DT,
                options = list(
                    pageLength = 9,
                    lengthMenu = list(c(9), c('9'))
                )
            )

            shinyjs::runjs("swal.close();")

        })
        

        # Download Result ----
        observeEvent(input$run_download,{
            req(input$up_file_vcf)
            req(input$up_file_phe)

            system(paste0("zip -r www/OUT/",userUID,"/Result_",userUID,".zip www/OUT/",userUID))

            showModal(
                modalDialog(
                    title = "Download Result",
                    size = "l",
                    easyClose = T,
                    paste0("Result URL 👉 https://wheat.dftianyi.com/OUT/",userUID,"/Result_",userUID,".zip"),
                    type = "success"
                )
            )
        })
        
        
        
        # 当用户退出60秒后删除临时目录
        onSessionEnded(function() {
            later(function() {
                unlink(paste0("www/OUT/",userUID), recursive = TRUE)
            },delay = 10)  # 600秒后删除文件
        })
            
        })
}