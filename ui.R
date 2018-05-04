library(shiny)
library(ggplot2)
library(dplyr)
library(nnet)

# Define UI for application that draws a histogram
shinyUI(navbarPage("RPS Shiny", theme="main.css",
  
  tabPanel("The Game",
    # Sidebar with a slider input for number of bins 
    sidebarLayout(position="right",
      sidebarPanel(width=3,id = "sidebar",
         actionButton("newPlayer", "New Player"),
         sliderInput("timeBetween", "Time Between Rounds", 2, 10, 5, 1),
         tags$hr(),
         textOutput("scoreText"),
         plotOutput("scoreGraph", height=25),
         div(dataTableOutput("scoreTable"), style="font-size:80%")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(width = 9,
         fluidRow(
              column(6, id="divleft",height="100%",
                 tags$h2("Player 1"),
                 tags$hr(),
                 div(style="text-align:center",
                   actionButton("rock", "Rock"),
                   actionButton("paper","Paper"),
                   actionButton("scissors","Scissors")
                 ),
                 uiOutput("displayPlayer1")
                 
                 ),
             column(6, id="divright",
               tags$h2("Computer"),
               tags$hr(),
               tags$br(),
               uiOutput("displayPlayer2")
             ) 
         ),
         fluidRow(id="outcomeRow",
              tags$h1(uiOutput("outcomeText"))
         ),
         tags$hr(style="margin-top:0px"),
         fluidRow(
           column(1,
                  tags$br()
                  ),
           column(4,
                  selectInput("computerMode","Computer Mode*",
                               c("Random","Weights","Prediction"),
                               selected = "Prediction"),
                  textOutput("matches"),
                  textOutput("players"),
                  tags$hr(style="margin:2px"),
                  tags$p("* If matches is < 10 then all choices are random.")
                  ),
           column(4,
                  tags$h3("Computer Stats", style="margin-top:0px"),
                  tableOutput("matchesTable"),
                  textOutput("procTime")
                  )
         )
      )
    )
  ),
  tabPanel("The Explanation",
           fluidPage(fluidRow(
             includeHTML("./www/htmlText.html")
           ))
           
           )
))
