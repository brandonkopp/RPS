#### INITIALIZE VARIABLES AND IMPORT DATA ####
options <- c("Rock", "Paper", "Scissors")

dat <- readRDS("./www/dat.rds")
dat <- dat[complete.cases(dat), ]

comp <- readRDS("./www/compScore.rds")
comp <- comp[complete.cases(comp), ]

timestart <- Sys.time()

if(is.na(max(dat$id,na.rm = T))){
  id <- 1
}else if(max(dat$id,na.rm = T) == -Inf){
  id <- 1
}else{
  id <- max(dat$id, na.rm = T) + 1  
}

#### CONVERT INTEGER TO ROCK, PAPER, SCISSORS ####
rpsTranslate <- function(choice, abv = F){
    string <- options[choice]
    
    if(abv == T){
      string <- substr(string, 1,1)
    }
}

#### SCORE THE MATCH ####
outcome1 <- function(player1, player2){
  
  if(player1 == player2){
    return("Tie")
  }
  
  if(player1 == 1 & player2 == 2){
    return("Computer Wins")
  }else if(player1 == 2 & player2 == 1){
    return("Player 1 Wins")
  }else if(player1 == 1 & player2 == 3){
    return("Player 1 Wins")
  }else if(player1 == 3 & player2 == 1){
    return("Computer Wins")
  }else if(player1 == 2 & player2 == 3){
    return("Computer Wins")
  }else if(player1 == 3 & player2 == 2){
    return("Player 1 Wins")
  }
  
}

outcome2 <- function(player1, player2){
  
  if(player1 == player2){
    return("Tie")
  }
  
  if(player1 == 1 & player2 == 2){
    return("Paper Covers Rock")
  }else if(player1 == 2 & player2 == 1){
    return("Paper Covers Rock")
  }else if(player1 == 1 & player2 == 3){
    return("Rock Breaks Scissors")
  }else if(player1 == 3 & player2 == 1){
    return("Rock Breaks Scissors")
  }else if(player1 == 2 & player2 == 3){
    return("Scissors Cuts Paper")
  }else if(player1 == 3 & player2 == 2){
    return("Scissors Cuts Paper")
  }
  
}

outcometable <- function(outcome){
  if(outcome == "Tie"){
    return(0)
  }else if(outcome == "Player 1 Wins"){
    return(1)
  }else if(outcome == "Computer Wins"){
    return(-1)
  }
}

#### THIS IS NOT CURRENTLY USED BUT WILL BE PART OF A FUTURE ENHANCEMENT ####
outcomeicon <- function(outcome){
  
  if(outcome == "Tie"){
     return("./icons/tie")
  }else if(outcome == "Player 1 Wins"){
     return("./icons/win.png")
  }else if(outcome == "Computer Wins"){
     return("./icons/loss.png")
  }
  
}

#### FUNCTION FOR COMPUTER RESPONSE SELECTION ####
readyPlayer2 <- function(dat, choiceType = 'Random'){
  if((choiceType == 'Random') | nrow(dat) < 10){
     choice <- sample(1:3, 1 ,prob = c(0.33,0.33,0.33))
  }else if(choiceType == 'Weights'){
     x <- educatedGuess(dat)
     choice <- sample(1:3, 1 ,prob = x[[1]])
     choice <- predShift(choice)
  }else if(choiceType == 'Prediction'){
     x <- educatedGuess(dat)
     choice <- x[[4]][[1]]
  }
  
  return(choice)
}

educatedGuess <- function(dat){
  x <- dat[ ,c(1,3:7)]
  x$prevp1 <- lag(x$p1choice, default = 0)
  x$prev2p1 <- lag(x$p1choice,n = 2, default = 0)
  x$prev3p1 <- lag(x$p1choice,n = 3,default = 0)
  x$prevp2 <- lag(x$p2choice, default = 0)
  x$prev2p2 <- lag(x$p2choice,n = 2, default = 0)
  x$prev3p2 <- lag(x$p2choice,n = 3,default = 0)
  x$prevout <- lag(x$outcome, default = 0)
  x$prev2out <- lag(x$outcome,n = 2, default = 0)
  x$prev3out <- lag(x$outcome,n = 3,default = 0)
  
  x$rock <- ifelse(x$p1choice == 1, 1, 0)
  x$paper <- ifelse(x$p1choice == 2, 1, 0)
  x$scissors <- ifelse(x$p1choice == 3, 1, 0)
  
  sumrock <- x %>% select(id, rock) %>% group_by(id) %>% mutate(sumrock = cumsum(rock)) %>% ungroup()
  sumpaper <- x %>% select(id, paper) %>% group_by(id) %>% mutate(sumpaper = cumsum(paper)) %>% ungroup()
  sumscissors <- x %>% select(id, scissors) %>% group_by(id) %>% mutate(sumscissors = cumsum(scissors)) %>% ungroup()
  x <- cbind(x, sumrock$sumrock)
  x <- cbind(x, sumpaper$sumpaper)
  x <- cbind(x, sumscissors$sumscissors)
  x <- x[ ,! names(x) %in% c("rock", "paper","scissors")]
  x$future <- lead(x$p1choice,1)
  
  glm.fit=multinom(future~., data=x[1:(nrow(x)-1), ])
  
  Xs <- x[nrow(x), ]
  Xs$predictiontime[1] <- Sys.time() - timestart
  
  preds <- predict(glm.fit, Xs, "probs")
  
  prediction <- which.max(preds)
  prob <- max(preds)
  move <- predShift(prediction)[[1]]
  
  return(list(preds, prob,prediction, move))
}

predShift <- function(pred){
  if(pred %in% 1:2){
     move <- pred + 1
  }else{
     move <- 1
  }
  
}

#### UPDATE AND SAVE DATASETS ####
roundAppend <- function(dat,vid,iteration, player1, player2, outcome){
  x <- data.frame(matrix(ncol = 7))
  names(x) <- c("id", "datetime", "selectiontime","iteration","p1choice", "p2choice","outcome")
  
  x$id[1] <- vid
  x$datetime[1] <- as.POSIXct(Sys.time(), origin="1970-01-01")
  x$selectiontime[1] <- Sys.time() - timestart
  x$iteration[1] <- iteration
  x$p1choice[1] <- player1
  x$p2choice[1] <- player2
  x$outcome[1] <- outcome
 
  dat <<- rbind(dat, x)
  saveRDS(dat, "./www/dat.rds")
  
  return(dat)
}

compAppend <- function(comp,vid, player1, player2, outcome, mode, dtime){
  x <- data.frame(matrix(ncol=6), stringsAsFactors = F)
  names(x) <- c('playerid','p1choice','p2choice', 'outcome', 'mode', 'decisionTime')
  
  x$playerid[1] <- vid
  x$p1choice[1] <- player1
  x$p2choice[1] <- player2
  x$outcome[1] <- outcome
  x$mode[1] <- mode
  x$decisionTime[1] <- dtime
  
  comp <<- rbind(comp, x)
  saveRDS(comp, "./www/compScore.rds")
  
  return(comp)
}

#### BOTTOM PANEL ELEMENTS ####
compTable <- function(comp, id=NULL){
  compTable <- comp %>%
    filter(playerid == id) %>%
    filter(outcome !=0) %>%
    group_by(mode) %>%
    summarize(Matches = n(),
              Win_Percent = round(abs((sum(outcome[outcome == -1])/Matches))*100, 1)) %>%
    ungroup()
  
  names(compTable)[1] <- "Mode"
  
  return(compTable)
}

#### SIDE PANEL ELEMENTS ####
updateScore <- function(dat, outcome){
  if(outcome == "Player 1 Wins"){
     dat$count[dat$outcome == "Win"] <- dat$count[dat$outcome == "Win"] + 1
  }else if(outcome == "Computer Wins"){
    dat$count[dat$outcome == "Loss"] <- dat$count[dat$outcome == "Loss"] + 1
  }else if(outcome == "Tie"){
    dat$count[dat$outcome == "Tie"] <- dat$count[dat$outcome == "Tie"] + 1
  }
  
  return(dat)
}

updateScoreText <- function(dat){
  text1 <- paste0("W/T/L")
  text2 <- paste0(dat$count[dat$outcome == "Win"], "/", dat$count[dat$outcome == "Tie"],"/",dat$count[dat$outcome == "Loss"])
  
  paste(text1, text2, sep = " ")
}

updateGraph <- function(dat){
      
      dat$outcome <- factor(dat$outcome, levels = c("Loss","Tie","Win"), ordered = T)
      
      ggplot(dat, aes("x", count)) +
        geom_bar(stat="identity", aes(fill=outcome)) +
        scale_fill_manual(values = c('indianred3','darkgoldenrod1','forestgreen')) +
        theme_bw() + 
        theme(legend.position = "none",
              axis.text = element_blank(),
              axis.title = element_blank(),
              axis.ticks = element_blank(),
              plot.background = element_blank(),
              panel.border = element_blank(),
              panel.grid = element_blank()) +
        coord_flip() 

}

updateScoreTable <- function(dat, id){
    dat <- dat[dat$id == id, ]
    if(nrow(dat) == 0){
      return("")
    }
    
    dat <- select(dat, iteration, p1choice, p2choice, outcome)
    
    dat$iteration <- as.integer(dat$iteration)
    dat$p1choice <- unlist(lapply(dat$p1choice, function(x){rpsTranslate(x, abv=T)}))
    dat$p2choice <- unlist(lapply(dat$p2choice, function(x){rpsTranslate(x, abv=T)}))
    dat$outcome[dat$outcome == 1] <- HTML('<img src="win-small.png" height="20"/>')
    dat$outcome[dat$outcome == 0] <- '<img src="tie-small.png" height="20"/>'
    dat$outcome[dat$outcome == -1] <- '<img src="loss-small.png" height="20"/>'
    
    names(dat) <- c("i","P1","C","W/L")
    return(dat)
}