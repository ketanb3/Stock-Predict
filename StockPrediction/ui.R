library("ggvis")

shinyUI(pageWithSidebar(
  div(),
  sidebarPanel(
    sliderInput("n", "Number of Samples", min = 1, max = 52,
                value = c(1,50), step = 1),
    helpText("Note:",div()," To Increse/Decrease the Number of Samples use Slider."),
    uiOutput("plot_ui")
  ),
  mainPanel(
    ggvisOutput("plot")
  )
))
