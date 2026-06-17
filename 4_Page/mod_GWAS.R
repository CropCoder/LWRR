mod_GWAS_UI <- function(id) {
    ns <- NS(id)
    tagList(
        tags$div(
            class = "alert alert-success", role = "alert",
            strong("Tip: "), "This page provides GWAS results database search function, you can select the phenotype, analysis model, chromosome, physical location, significance threshold and other parameters to obtain GWAS results."
        ),
        # plotGWAS----
        h3("Query the results of GWAS by different phenotypes"),
        card(
            full_screen = T,
            radioButtons(
                inputId = ns("GWAS_Phe"),
                inline = T,
                label = "Please select a phenotype:",
                choices = GWAS_Trait_list,
                selected = "DS.21YL"
            ),
            selectInput(
                inputId = ns("which_model"),
                label = "Analysis model:",
                choices = c("MLM", "FarmCPU"),
                selected = "MLM"
            ),
            card(
                card_header("Results of whole-chromosome horizontal association analysis"),
                full_screen = F,
                uiOutput(ns("plot_gwas_png"))
            )
        ),
        h3("View the result information for a specific interval"),
        card(
            p("✨ Please select a region to view detail, the page will show the corresponding region of significant variation sites, and provide a table of results. "),
            p("Note: Please do not enter a large range of interval, ensure that the distance from Start to End is less than 20MB"),
            layout_column_wrap(
                1 / 4,
                selectInput(
                    inputId = ns("which_chr"),
                    label = "Select Chromosome",
                    choices = c(
                        "1 <-> chr1A" = "1A",
                        "2 <-> chr1B" = "1B",
                        "3 <-> chr1D" = "1D",
                        "4 <-> chr2A" = "2A",
                        "5 <-> chr2B" = "2B",
                        "6 <-> chr2D" = "2D",
                        "7 <-> chr3A" = "3A",
                        "8 <-> chr3B" = "3B",
                        "9 <-> chr3D" = "3D",
                        "10 <-> chr4A" = "4A",
                        "11 <-> chr4B" = "4B",
                        "12 <-> chr4D" = "4D",
                        "13 <-> chr5A" = "5A",
                        "14 <-> chr5B" = "5B",
                        "15 <-> chr5D" = "5D",
                        "16 <-> chr6A" = "6A",
                        "17 <-> chr6B" = "6B",
                        "18 <-> chr6D" = "6D",
                        "19 <-> chr7A" = "7A",
                        "20 <-> chr7B" = "7B",
                        "21 <-> chr7D" = "7D"
                    ),
                    selected = "1A"
                ),
                numericInput(ns("GWAS_start"), "Start(MB) (IWGSC 2.1)", value = 290),
                numericInput(ns("GWAS_end"), "End(MB) (IWGSC 2.1)", value = 300),
                numericInput(ns("GWAS_p"), "Significance threshold", value = 3)
            ),
            actionButton(ns("get_GWAS_detail"), "Click here to get GWAS result information for the interval",
                icon("magnifying-glass"),
                class = "btn-success m-2"
            ),
            p("⚠️ The content of the following page is empty by default, please modify the parameters according to the need to click on the green button to get the results of the information."),
            card(
                card_header("Narrow the GWAS association analysis results for the specified interval"),
                full_screen = T,
                plotlyOutput(ns("plot_GWAS"), height = "300px")
            ),
            tags$div(
                class = "alert alert-success", role = "alert",
                strong("tip："), "You can click on the dots in the image above to get location information."
            ),
            h5("The variation information corresponding to the significant peak : "),
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
                        tags$img(src = str_c("./GWAS_Plot/", input$GWAS_Phe, ".", input$which_model, ".1e-2.result.png"), style = "width:98%")
                    ),
                    column(
                        4,
                        tags$img(src = str_c("./GWAS_Plot/", input$GWAS_Phe, ".", input$which_model, ".1e-2.result.subgenome.png"), style = "width:100%")
                    )
                )
            })

            # 创建一个reactive值，用于判断是否是首次打开页面
            first_visit <- reactiveVal(TRUE)

            observe({
                if (first_visit()) {
                    # 模拟按钮点击
                    shinyjs::click("get_GWAS_detail")
                    first_visit(FALSE) # 标记为非首次访问
                }
            })


            observeEvent(input$get_GWAS_detail, {
                which_chr <- input$which_chr
                which_model <- input$which_model
                which_phe <- input$GWAS_Phe
                which_min <- input$GWAS_p
                which_start <- input$GWAS_start
                which_end <- input$GWAS_end

                output$plot_GWAS <- renderPlotly({
                    if (which_start > which_end) {
                        showModal(modalDialog(
                            title = "Error",
                            "The start position cannot be greater than the end position, please check the start and end positions."
                        ))
                    } else {
                        if (which_end - which_start > 20) {
                            showModal(modalDialog(
                                title = "Error",
                                "The distance from Start to End is greater than 20MB, please check the start and end positions."
                            ))
                        } else {
                            data <- dbGetQuery(db, str_c(
                                "SELECT * FROM `GWAS.", which_model, ".", which_phe,
                                "` WHERE Postion > ", which_start, " AND Postion < ",
                                which_end, " AND logP > ", which_min, " AND chr = '", which_chr, "'"
                            ))


                            p <- ggplot(data, aes(Postion, logP, text = SNP)) +
                                geom_point(aes(color = eff), size = 3, alpha = 0.8) +
                                scale_color_gradient(low = "#c3fae8", high = "#087f5b") +
                                ylab("-log10(GWAS.Pvalue)") +
                                xlab(str_c("Physical Postion (IWGSC 2.1)")) +
                                theme_bw()
                            ggplotly(p)
                        }
                    }
                })

                output$GWAS_sign_table <- renderDT({
                    if (which_start > which_end) {
                        pass
                    } else {
                        if (which_end - which_start > 20) {
                            pass
                        } else {
                            data <- dbGetQuery(db, str_c(
                                "SELECT * FROM `GWAS.", which_model, ".", which_phe,
                                "` WHERE Postion > ", which_start, " AND Postion < ",
                                which_end, " AND logP > ", which_min, " AND chr = '", which_chr, "'"
                            ))

                            datatable(
                                data,
                                extensions = c("Buttons"),
                                options = list(
                                    lengthChange = FALSE, # 禁止改变每页显示的行数
                                    pageLength = 6, # 设置每页显示6行
                                    dom = "Blfrtip", # 启用Buttons插件
                                    buttons = c("copy", "csv", "excel") # 添加复制、CSV和Excel导出按钮
                                )
                            )
                        }
                    }
                })
            })
        }
    )
}
