renv::restore()

paquetes <- list(
  "Reproduccion" = list("renv"), 
  "Shiny Core"   = list("shiny", "shinydashboard"),
  "Tidyverse"    = list("dplyr", "lubridate", "httr"),
  "Mapa"         = list("leaflet")
)

lapply(as.list(c(paquetes, recursive = TRUE, use.names = FALSE)),
       function(x) {
         library(x, character.only = TRUE, verbose = FALSE)
       })

rm(list = c("paquetes"))