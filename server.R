# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  v <- reactiveValues(data = NULL)
  v$score <- data.frame(outcome = c("Win","Loss","Tie"), count = c(0,0,0), stringsAsFactors = F)
  v$iteration <- 0
  v$id <- id
  
  shoot <- function(rps){
    v$player1 <- rps
    
    choiceStart <- Sys.time()
    v$player2 <- readyPlayer2(dat, choiceType = input$computerMode)
    v$endTime <- Sys.time() - choiceStart
    
    v$score <- updateScore(v$score, outcome1(v$player1, v$player2))
    v$iteration <- v$iteration + 1
  }
  
  
  #User's Choice
  observeEvent(input$rock, {shoot(1)})
  
  observeEvent(input$paper, {shoot(2)}) 
  
  observeEvent(input$scissors, {shoot(3)}) 
  
  observeEvent(input$newPlayer, {
     v$score$count <- 0
     v$iteration <- 0
     timestart <- Sys.time()
     id <- id + 1
     v$id <- v$id + 1
     print(v$id)
  }) 
  
  #### MAIN BODY ELEMENTS ####
  output$imgPlayer1 <- renderImage({   #This is where the image is set 
    if(v$player1 == 1){            
      list(src = "./icons/left-rock.png", width = "90%")
    }                                        
    else if(v$player1 == 2){
      list(src = "./icons/left-paper.png", width = "90%")
    }
    else if(v$player1 == 3){
      list(src = "./icons/left-scissors.png", width = "90%")
    }else if(is.null(v$player1)){
      
    }
  }, deleteFile = FALSE)
  
  output$displayPlayer1 <- renderUI({
       if(is.null(v$player1)){
         
       }else{
         div(id="pl1", imageOutput("imgPlayer1"))
       }
      
  })
  
  output$imgPlayer2 <- renderImage({   #This is where the image is set 
    if(v$player2 == 1){            
      list(src = "./icons/right-rock.png", width = "90%")
    }                                        
    else if(v$player2 == 2){
      list(src = "./icons/right-paper.png", width = "90%")
    }
    else if(v$player2 == 3){
      list(src = "./icons/right-scissors.png", width = "90%")
    }else if(is.null(v$player2)){
      
    }
  }, deleteFile = FALSE)
  
  output$displayPlayer2 <- renderUI({
    if(is.null(v$player1)){
 
    }else{
      div(id="pl2", imageOutput("imgPlayer2"))
    }
  })
  
  output$outcomeText <- renderUI({
      
    if(!is.null(v$player1) & !is.null(v$player2)){
        textOutput("outcomeHeader")
      }
  })
  
  output$outcomeHeader <- renderText({
      outcome2(v$player1, v$player2)
  })
  
  output$outcome2Text <- renderUI({
    if(!is.null(v$player1) & !is.null(v$player2)){
      textOutput("outcomeFooter")
    }
  })
  
  output$outcomeFooter <- renderText({
    outcome1(v$player1, v$player2)
  })
  
  
  #### SIDEBAR ELEMENTS ####
  output$scoreGraph <- renderPlot({
      updateGraph(v$score)
  },height=30, bg="transparent")
  
  output$scoreText <- renderText({
      HTML(updateScoreText(v$score))
  })
  
  output$scoreTable <- renderDataTable({
      v$iteration
      v$id
      updateScoreTable(dat, v$id)
  },escape = FALSE,options = list(searching = FALSE, paging=FALSE))

  #### RESET THE GAME BOARD BY REFRESHING PLAYER 1 AND COMPUTER CHOICES ####
  observe({
    invalidateLater(input$timeBetween*1000, session)
    v$player1 <- NULL
    v$player2 <- NULL
    timestart <- Sys.time()
  })
  
  #### APPEND DATA TO THE TRAINING DATA TABLE AND COMPUTER SCORE TABLE ####
  observe({
      if(!is.null(v$player1) & !is.null(v$player2)){
        dat <- roundAppend(dat,v$id, v$iteration, v$player1, v$player2, outcometable(outcome1(v$player1, v$player2)))
        comp <- compAppend(comp,v$id, v$player1, v$player2, outcometable(outcome1(v$player1, v$player2)), input$computerMode, v$endTime)
      }
  })
  
  #### BOTTOM PANEL ELEMENTS ####
  output$matches <- renderText({
    invalidateLater(input$timeBetween*1000, session)
    paste0("Matches: ", nrow(dat))
  })
  
  output$players <- renderText({
    paste0("Human Players: ", length(unique(dat$id)))
  })
  
  output$matchesTable <- renderTable({
    invalidateLater(input$timeBetween*1000, session)
    compTable(comp, v$id)
  })
  
  output$procTime <- renderText({
    if(is.null(v$endTime)){
      return("")
    }
    paste0("Processing Time: ", round(v$endTime,3), "s")
  })
  
})
