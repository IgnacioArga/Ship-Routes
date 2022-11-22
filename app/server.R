#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  data <- reactive({
    
    lat1 = c(24.948836, 25.366837)
    lon1 = c(-80.570474, -80.307664)
    
    lat2 = 25.687600
    lon2 =-80.155474
    
    lat3 = 26.009788
    lon3 =-80.114443
    
    ship1 <- rbind(data.frame(Longitude=lon1,Latitude=lat1,Group=1),
                   data.frame(Longitude=lon2,Latitude=lat2,Group=2),
                   data.frame(Longitude=lon3,Latitude=lat3,Group=3)) %>% 
      mutate(Ship = "Ship 1")
    
    lat1 = c(25.188196, 25.909041)
    lon1 = c(-81.154586, -81.735730)
    
    lat2 = 26.316346
    lon2 =-81.843681
    
    lat3 = 26.474654
    lon3 =-82.184524
    
    ship2 <- rbind(data.frame(Longitude=lon1,Latitude=lat1,Group=1),
                data.frame(Longitude=lon2,Latitude=lat2,Group=2),
                data.frame(Longitude=lon3,Latitude=lat3,Group=3)) %>% 
      mutate(Ship = "Ship 2")
    
    data
    data_all <- rbind(ship1, ship2) %>%
      mutate(
        tag = case_when(
          Group == 1 ~ "Historic",
          Group == 2 ~ "Latest",
          Group == 3 ~ "Predicted"
        ),
        Date_time = lubridate::now()-lubridate::days(3)+lubridate::days(Group)
      )
    
    data_all <- data_all %>% 
      mutate(
        html_popup = glue::glue('<!DOCTYPE html>
      <html>
      <head>
      <meta charset="utf-8">
      <title>Descendant Selector</title>
      <style>
      
      h1 {
        font-size: 25px;
      }
      .grey {
        color:rgba(105, 105, 105, 0.76);
      }
      #long {
        margin-left: 12px;
      }
      #tag {
        margin-left: 40px;
      }
      #date {
        margin-left: 5px;
      }
      .green{
        color:hsl(134, 80%, 31%);
      }
      .blue{
        color:hsl(216, 62%, 40%);
      }
      </style>
      </head>
      <body>
      <h1>Position</h1>
      <div><b>Latitude:</b> <span id="long" class="grey" >[Latitude]</span></div>
      <div><b>Longitude:</b> <span class="grey">[Longitude]</span></div>
      [date]
      <div><b>Tag: </b> <span id="tag" class="[color]"><b>[tag]</b></span></div>
      </body>
      </html>',
      color = case_when(
        Group == 1 ~ "",
        Group == 2 ~ "green",
        Group == 3 ~ "blue"
      ),
      date = case_when(
        Group == 3 ~ "",
        TRUE ~ glue::glue(
          '<div><b>Date-time:</b> <span id="date" class="grey">{Date_time}</span></div>',
          Date_time = format(Date_time, "%d/%m/%Y - %H:%M")
        ) %>%  as.character()
      ),
      .open = "[",
      .close = "]"
        )
      )
    return(data_all)
  })
  
  data_filtrada <- eventReactive(input$ship, {
    
    data() %>% 
      filter(Ship == input$ship)
  })
  
  output$mapa <- renderLeaflet({
    my_icons2 <- iconList(
      past <- makeIcon(
        iconUrl = "https://www.freeiconspng.com/uploads/green-circle-icon-14.png",
        iconWidth = 20, 
        iconHeight = 20
      ),
      ship <- makeIcon(
        iconUrl = "https://www.freeiconspng.com/uploads/ship-icon--spanish-travel-iconset--unclebob-2.png",
        iconWidth = 40,
        iconHeight = 40
      ),
      future <- makeIcon(
        iconUrl = "https://www.freeiconspng.com/uploads/blue-circle-icon-18.png",
        iconWidth = 20,
        iconHeight = 20
      )
    )
    
    html_legend <- "
  <img src='https://www.freeiconspng.com/uploads/green-circle-icon-14.png' width='20' height='20'> Historic position<br/>
  <img src='https://www.freeiconspng.com/uploads/ship-icon--spanish-travel-iconset--unclebob-2.png' width='20' height='20'> Latest position<br/>
  <img src='https://www.freeiconspng.com/uploads/blue-circle-icon-18.png' width='20' height='20'> Predicted position<br/>
  "
    
    data_filtrada() %>% 
      leaflet() %>% 
      addTiles() %>% 
      addMarkers(
        lng = ~ Longitude,
        lat = ~ Latitude,
        icon = ~ my_icons2[Group],
        popup = ~html_popup,
        popupOptions = 
      ) %>%
      addControl(
        html = html_legend,
        position = "bottomright"
      ) %>% 
      addPolylines(
        lng = ~Longitude,
        lat = ~Latitude, 
        group = ~Group,
        weight = 2
      ) 
  })

})
