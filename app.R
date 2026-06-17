##########################################################
## Copyright (c) NWAFU Bioincloud lab 2022-2025
##      Project: LWRR 
##  Description: Landscape of Wheat Rust Resistance
##         Date: 2025.01.11
##       Author: Jiwen Zhao ( zhaojiwen@nwafu.edu.cn )
##      Website: https://www.filll.cn/LWRR
##       Github: Github.com/CropCoder
##      Version: 1.0.0
##########################################################

cat("-------------------- Welecome --------------------\n")
library(shiny)
source("global.R")

ui <- fluidPage(
    # 主页设置与浏览器徽标
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
        tags$link(rel = "shortcut icon", href = "fig/LWDR_logo_2.png"),
        tags$script(
            charset = "UTF-8", id = "LA_COLLECT", src = "//sdk.51.la/js-sdk-pro.min.js"
        ),
        tags$script(HTML('
      LA.init({
        id: "KkgRwrLlq1N1AAtL",
        ck: "KkgRwrLlq1N1AAtL"
      })
        '))
        
    ),
    # 页眉设置与网站Logo
    div(class = "footer",
        style = "bottom: 0; width: 100%; padding: 10px; text-align: center;",
        tags$img(src="fig/home_header.png", width = "1300px")
    ),
    useShinyjs(),
    # 主题页面框架设计
    page_fixed(
        theme = bs_theme(bootswatch = "minty",
                         fg = "#000000",
                         bg = "#ffffff",
                         secondary = "#71afe5",
                         primary = "#1289a7",
                         info = "#008272",
                         success = "#4b704b",
                         navbar_bg = "#ffffff"
        ),
        # 模块化布局
        navbarPage("",id = "page",
                   windowTitle = "LWRR - Landscape of Wheat Rust Resistance",
                   tabPanel("Home",mod_home_ui("home"),icon = icon("house")),
                   tabPanel("Population",mod_population_UI("population"),icon = icon("sitemap")),
                   tabPanel("Trait",mod_trait_UI("trait"),icon=icon("feather-pointed")),
                   tabPanel("Sample",mod_sample_UI("sample"),icon=icon("wheat-awn")),
                   tabPanel("GWAS",mod_GWAS_UI("GWAS"),icon=icon("crosshairs")),
                   tabPanel("QTL",mod_QTL_UI("QTL"),icon = icon("share-nodes")),
                   tabPanel("Gene",mod_Gene_UI("gene"),icon=icon("dna")),
                   tabPanel("Tool",mod_tools_UI("tools"),icon=icon("screwdriver-wrench")),
                   tabPanel("Download",mod_download_UI("download"),icon = icon("download")),
                   tabPanel("References",mod_References_UI("ref"),icon=icon("folder-open")),
                   tabPanel("About",mod_about_UI("about"),icon=icon("circle-question")),
                   tabPanel("Usage & Help",mod_use_UI("use"),icon=icon("arrow-right"))
                   # 如果需要菜单栏下拉复选项，可以采用下方框架
                   # navbarMenu(
                   #     "Tools",icon=icon("screwdriver-wrench"),
                   #     tabPanel("Single Marker Analysis",p("SGAT"),value = "xx"),
                   #     tabPanel("Online SGAT Analysis",p("A")),
                   # ),
                
                   
        ),
        # 全局返回顶部菜单栏按键
        tags$div(
            style = "text-align: center",
            tags$a(
                href = "#top",
                style = "color: #2980b9; text-decoration: none; font-size: 16px;",
                icon("arrow-alt-circle-up"),
                "Click here to quickly return to the page top"
            )
        ),
        br()
    ),
    
    # 页尾信息
    div(class = "footer",
        style = "bottom: 0; width: 100%; padding: 10px; text-align: center;",
        # tags$img(src="fig/LWDR_logo_2.png",style="width:80px"),
        tags$br(),
        div(style = "display: flex; justify-content: center; width: 100%;",
            tags$a(href="https://www.nwafu.edu.cn/", target="_blank",tags$img(src="fig/quicklink/nwafu.png", class="logo-img",style="height:60px;width:100%;")),
            tags$a(href="http://wheat.cau.edu.cn/TGT/", target="_blank",tags$img(src="fig/quicklink/TGT.png", class="logo-img",style="height:60px;width:100%;")),
            tags$a(href="http://wheat.cau.edu.cn/wGRN/", target="_blank",tags$img(src="fig/quicklink/wGRN.png", class="logo-img",style="height:60px;width:100%;")),
            tags$a(href="http://wheatomics.sdau.edu.cn/", target="_blank",tags$img(src="fig/quicklink/wheatomics.png", class="logo-img",style="height:60px;width:100%;"))
        ),
        tags$br(),
        h6("Northwest Agriculture & Forestry University . College of Agronomy . Copyright © All rights reserved "),
        #"State Key Laboratory of Crop Stress Resistance and High-Efficiency Production. Yangling, Shaanxi 712100, P. R. China",
        h6("Contact E-mail:  zhaojiwen@nwafu.edu.cn  [Technology]  、 wujh@nwafu.edu.cn  [Cooperate]"),
        h6("LWRR is developed based on cloud server, intended solely for academic exchange and scientific research purposes. This website is powered by https://cloud.dftianyi.com"),
        tags$a(href = "https://beian.miit.gov.cn/", "粤ICP备2022102133号", target = "_blank", style = "color: #2c3e50; text-decoration: none; font-size: 16px;"),
        #p("Copyright © 2023-2025 NWAFU. All rights reserved."),
        #p("修改与意见反馈请访问如下链接：http://u5a.cn/yI2R4")
    )
)

server <- function(input, output, session) {
    
    # 解析URL查询参数并更新navbar
    observe({
        query <- parseQueryString(session$clientData$url_search)

        # 如果URL中有'page'参数，则切换到相应的标签页
        if (!is.null(query$page)) {
            updateNavbarPage(session, "page", selected = query$page)
        }
        
        # 如果有key令牌信息，表示加密访问状态,能够获取更多权限
        # http://127.0.0.1:6590/?key=NWAFUZHAOJIWEN
        if (!is.null(query$key)){
            if (query$key == "NWAFUZHAOJIWEN"){
                shinyalert("超级权限提示",str_c("您目前正在以管理员模式访问，可以访问全部数据资源"),type = "info")
            }
        }
        
    })
    
    # 数据库操作
    mod_home_server("home")
    mod_population_Server("population")
    mod_QTL_Server("QTL")
    mod_sample_Server("sample")
    mod_trait_Server("trait")
    mod_GWAS_Server("GWAS")
    mod_QTL_Server("QTL")
    mod_Gene_Server("gene")
    mod_tools_Server("tools")
    mod_about_Server("about")
    mod_References_Server("ref")
    mod_download_Server("download")
    mod_use_Server("use")
}


shinyApp(ui, server)