library(shiny)
library(ggvis)



shinyServer(function(input, output, session) {
  
  
  
  #mtc <- reactive({ mtcars[1:input$n, ] })
  wm<- read.csv("testWSJ.csv")
  wmt <- reactive({ wm[input$n[1]:input$n[2],] })
  
  
  wmt %>%
    ggvis(~Value, ~Date, size := left_right(1, 365, step = 5), opacity := 0.5) %>%
    layer_points(fill = ~factor(Sentiment)) %>%
    add_tooltip(function(df) df$Value) %>%
    bind_shiny("plot", "plot_ui")
  
  
    
    
    
  
})