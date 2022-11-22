library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Ship Routes"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
      shinydashboard::box(
        shiny::selectInput(
          inputId = "ship",
          label = "Select ship ID:",
          choices = c("Ship 1", "Ship 2"),
          multiple = FALSE 
        )
        ),

        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput("mapa",height = 800)
        )
    )
    
))
