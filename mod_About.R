##########################################################
## Copyright (c) NWAFU Wheat Bioincloud.lab 2022-2025
##      Project: LWDR
##  Description: About
##         Date: 
##       Author: Jewin ( zaojewin@icloud.com )
##      Version: 1.0.0
##########################################################

mod_about_UI <- function(id) {
  ns <- NS(id)
  
  
  
  tagList(
      tags$img(src = "fig/about-1.png", style = "width: 100%;"),
      # tags$img(src = "fig/about-2.png", style = "width: 100%;"),
      # tags$img(src = "fig/about-3.png", style = "width: 100%;"),
      # tags$img(src = "fig/about-4.png", style = "width: 100%;"),
      br(),br(),
      tags$img(src = "fig/about-5.png", style = "width: 100%;")
      # tags$img(src = "fig/about-6.png", style = "width: 100%;")
  )
  
}

mod_about_Server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      
    }
  )
}
