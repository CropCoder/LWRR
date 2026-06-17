mod_References_UI <- function(id) {
  ns <- NS(id)
  tagList(

      tags$div(class = "alert alert-success", role = "alert",
               strong("Tip: "),"Over the past decades, researchers have identified numerous disease resistance QTLs or genes in wheat  through bi-parental QTLs mapping and genome-wide association studies (GWAS). We collated 1125 QTLs/genes, and then combined them into 217 independent QTLs based on genome-wide linkage disequilibrium block characteristics."),

      card(
        reactableOutput(ns("MetaQTL"))
      ),
      card(
          includeMarkdown("www/md/References.Rmd")
      )
      
  )
}

mod_References_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      output$MetaQTL <- renderReactable({

        data <- dbGetQuery(db, str_c(
                        "SELECT QTLName,Type,iQTL,Chr,PosV2,Ref FROM QTLDB1125 "
                    ))

        colnames(data) <- c("QTL ID","Type","IndependentID","Chromosome","Position(CS2.1)","Reference")

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

