mod_download_UI <- function(id) {
  ns <- NS(id)
  tagList(
      layout_column_wrap(
          1/3,
          tags$a(href="./?page=QTL", target="_blank",tags$img(src="fig/download/windows.png", class="home-card",style="width:100%")),
          tags$a(href="./?page=Gene", target="_blank",tags$img(src="fig/download/macos.png", class="home-card",style="width:100%")),
          tags$a(href="./?page=Gene", target="_blank",tags$img(src="fig/download/linux.png", class="home-card",style="width:100%"))
      ),
      br(),
      tags$div(class = "alert alert-success", role = "alert",
               "⏬ Application was developed based on Node.js, Electron, nativefier and other technologies to cache data and improve speed" ),
      br()
  )
}

mod_download_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      
    }
  )
}