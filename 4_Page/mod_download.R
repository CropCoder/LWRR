mod_download_UI <- function(id) {
  ns <- NS(id)
  tagList(

    tags$div(
            class = "alert alert-success", role = "alert",
            strong("Tip: "), "This website provides online download function, the data resources are open source and free to share, you can select the data you want to obtain below. Please note: if you use the data to carry out research work, please refer to the relevant articles according to the regulations."
            ),
    br(),
    navset_pill(
      nav_panel(
        title = "Sample data",
        br(),
        card(
          csvDownloadButton(ns("S1_sample"), filename = "LWRR_SampleInfo_Data.csv"),
          reactableOutput(ns("S1_sample"))
        )
      ),
      nav_panel(
        title = "QTL basic information",
        br(),
        card(
          csvDownloadButton(ns("S2_QTL"), filename = "LWRR_QTL_Data.csv"),
          reactableOutput(ns("S2_QTL"))
        )
      ),
      nav_panel(
        title = "Candidate gene",
        br(),
        card(
          csvDownloadButton(ns("S4_Gene"), filename = "LWRR_Gene_Data.csv"),
          reactableOutput(ns("S4_Gene"))
        )
      ),
      # nav_panel(
      #   title = "MetaQTL data",
      #   br(),
      #   card(
      #     csvDownloadButton(ns("MetaQTL"), filename = "LWRR_MetaQTL_Data.csv"),
      #     reactableOutput(ns("MetaQTL"))
      #   )
      # ),
      nav_panel(
        title = "LDblock region",
        br(),
        card(
          csvDownloadButton(ns("LDblock"), filename = "LWRR_LDblock_Data.csv"),
          reactableOutput(ns("LDblock"))
        )
      )


    )
  )
}

mod_download_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {



      output$S1_sample <- renderReactable({

        data <- S1_sample[, c(1, 2, 3, 10, 12, 16)]

        reactable(
          data,
          defaultColDef = colDef(
            align = "center",
            minWidth = 70,
            headerStyle = list(background = "#f6ffed")
          ),
          defaultPageSize = 10,
          searchable = F,
          showPageSizeOptions = F,
          filterable = T,
          striped = T,
          bordered = T
        )
      })


      output$S2_QTL <- renderReactable({

        data <- S2_QTL_freq[,c(2,3,7,8,14,15,16,17)]

        reactable(
          data,
          defaultColDef = colDef(
            align = "center",
            minWidth = 70,
            headerStyle = list(background = "#f6ffed")
          ),
          defaultPageSize = 10,
          searchable = F,
          showPageSizeOptions = F,
          filterable = T,
          striped = T,
          bordered = T
        )

      })

      output$S4_Gene <- renderReactable({

        data <- S4_GeneTPM[,c(1,2,5,3,4,6)]

        reactable(
          data,
          defaultColDef = colDef(
            align = "center",
            minWidth = 70,
            headerStyle = list(background = "#f6ffed")
          ),
          defaultPageSize = 10,
          searchable = F,
          showPageSizeOptions = F,
          filterable = T,
          striped = T,
          bordered = T
        )

      })

      output$MetaQTL <- renderReactable({

        data <- dbGetQuery(db, "SELECT * FROM QTLDB1125")

        data <- data[,c(1,2,3,11,19,20,24)]

        reactable(
          data,
          defaultColDef = colDef(
            align = "center",
            minWidth = 70,
            headerStyle = list(background = "#f6ffed")
          ),
          defaultPageSize = 10,
          searchable = F,
          showPageSizeOptions = F,
          filterable = T,
          striped = T,
          bordered = T
        )
      })

       output$LDblock <- renderReactable({

        data <- dbGetQuery(db, "SELECT * FROM QTLblockLD")

        data <- data[,c(1,2,3,4,6,7)]

        reactable(
          data,
          defaultColDef = colDef(
            align = "center",
            minWidth = 70,
            headerStyle = list(background = "#f6ffed")
          ),
          defaultPageSize = 10,
          searchable = F,
          showPageSizeOptions = F,
          filterable = T,
          striped = T,
          bordered = T
        )

      })




    }
  )
}
