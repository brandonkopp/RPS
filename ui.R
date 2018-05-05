library(shiny)
library(ggplot2)
library(dplyr)
library(nnet)

shinyUI(navbarPage("RPS Shiny", theme="main.css",
  
  tabPanel("The Game",
    #### SIDEBAR INCLUDING NEW PLAYER BUTTON, RESULTS GRAPH, & RESULTS TABLE ####
    sidebarLayout(position="right",
      sidebarPanel(width=3,id = "sidebar",
         actionButton("newPlayer", "New Player"),
         sliderInput("timeBetween", "Time Between Rounds", 2, 10, 7, 1),
         tags$hr(),
         textOutput("scoreText"),
         plotOutput("scoreGraph", height=25),
         div(dataTableOutput("scoreTable"), style="font-size:80%")
      ),
      
      #### MAIN PANEL WITH DIVs FOR PLAYER 1 AND COMPUTER ####
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
         tags$p(id="branding",style="color:white", "This app is a ", tags$a(href="https://brandonkopp.com", "brandonkopp.com"), " creation."),
         #### BOTTOM PANEL WITH COMPUTER SETTINGS AND RESULTS ####
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
  #### SECONDARY TAB WITH EXPLANATION OF APP DESIGN ####
  tabPanel("The Explanation",
           fluidPage(fluidRow(
             includeHTML("./www/htmlText.html") #Imports separate HTML File.
           ))
           
           )
))
