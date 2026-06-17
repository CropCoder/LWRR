##########################################################
## Copyright (c) NWAFU Wheat Bioincloud.lab 2022-2025
##      Project: LWDR
##  Description: 关于页面-展示小麦条锈病
##         Date: 
##       Author: Jewin ( zaojewin@icloud.com )
##      Version: 1.0.0
##########################################################

mod_about_UI <- function(id) {
  ns <- NS(id)
  tagList(
      tags$div(class = "alert alert-success", role = "alert",
               strong("Tip: "), "During the development of LWRR. The front-end page was developed based on R-Shiny and Bootstrap. Dynamic interactive charts were implemented using echarts4r, plotly, and JavaScript. The table part was realized with reactable and DT. The tidyverse package was used for file reading and standardized processing. The vcfR package was employed in the genotype file processing and parsing process. The parallel package was used for parallel computing and high-concurrency optimization. The chromoMap package was used for the interactive components of the chromosome panorama. The DBI package was used for database connection and query. Candidate gene association analysis was performed using rMVP package.The ggideogram package was used for the visualization of the genome-wide distribution map of QTL. In the tool part, software such as bcftools and LDBlockShow was used for background processing. Population genetics analysis was performed using vcftools in Linux. LWRR was created based on Ubuntu using Docker container technology. To facilitate user access, we deployed website on an Elastic Cloud Server. "),
      tags$img(src = "fig/about-1.png", style = "width: 100%;"),
      # includeMarkdown(
      #           "www/md/about.md"
      #       ),
      # tags$img(src = "fig/about-2.png", style = "width: 100%;"),
      # tags$img(src = "fig/about-3.png", style = "width: 100%;"),
      # tags$img(src = "fig/about-4.png", style = "width: 100%;"),
      br(),
      h3("Thanks for the main dependent programs of this project"),
      br(),
      tags$img(src = "fig/about-5.png", style = "width: 100%;"),
      # tags$img(src = "fig/about-6.png", style = "width: 100%;")
      br(),
      h3("The R packages utilized during the development process"),
      br(),
      card( 
        title = "Loaded open source programs",
        reactableOutput(ns("table_pkgs"))
      )
  )
  
}

mod_about_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      output$table_pkgs <- renderReactable({
      
        reactable(used_pkgs[,-4],
                              defaultColDef = colDef(
                                  align = "center",
                                  minWidth = 70,
                                  headerStyle = list(background = "#f6ffed")
                              ),
                              defaultPageSize = 15,
                              # pagination = FALSE,
                              # height = 700,
                              searchable = F,
                              showPageSizeOptions = F,
                              striped = T,
                              bordered = T
                    )
      })
    }
  )
}

