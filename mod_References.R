mod_References_UI <- function(id) {
  ns <- NS(id)
  tagList(
    
      card(
          includeMarkdown("www/md/References.Rmd")
      )
      
  )
}

mod_References_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      
    }
  )
}