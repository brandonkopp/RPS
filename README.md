<h2>RPS Shiny</h2>

<p>This is a simple Rock, Paper, Scissors application built in R Shiny. The computer's selections are driven by a multiple logistic regression model.</p>

<p>You can preview the app at: <a href="https://brandonkopp.shinyapps.io/RPS-Shiny/">https://brandonkopp.shinyapps.io/RPS-Shiny/</a>.</p>

<p>I developed this app to show my coworkers something neat you can do with R Shiny.  This app was also an opportunity for me to learn some new things. This is what I learned while creating this app and hope to pass on to anyone who comes across this repo:</p>

- <b>Persistent Storage:</b> This is the first app I've built that collects and stores data on the Shiny server (oh, by the way, your matches against the computer were recorded in a data file).
- <b>Predictive Modeling:</b> I wanted to build a predictive model into an application. How the model works is explained below.
- <b>Image Elements:</b> I wanted to incorporate dynamic images that appear and disappear as part of the game.
- <b>Resetting:</b> Through building this app, I discovered the InvalidateLater() function which is tremendously useful for resetting the game board.


<h3>The Predictive Model</h3>

<p>The heart of the app is the predictive model that drives the computer's choices.  I started out with random selection, but that wasn't any fun. Why not record game data and put it to work. At first, I thought Rock, Paper, Scissors might not be the best game to try out a predictive model on. In order for a model to work, there has to be some pattern to pick up on and RPS is supposed to be random right?  The more I played, the more I realized there probably is a pattern worth picking up and the computer has been beating me fairly regularly. Here's how it works:</p>

<p><b>Prediction: </b> The computer uses multiple logistic regression to make a prediction about Player 1's next move. The prediction is then shifted on choice to the right (e.g., Rock becomes Paper) in order to counter the predicted move.  There are three computer 'modes.'  I hope to add more later.</p>

- <b>Random:</b> As the name implies the computer selects randomly with all options having equal probabilities. The model always uses Random when there are fewer than 10 moves in the training dataset.
- <b>Weighted: </b>A multiple logistic regression is performed and the output probabilities for each of the options are used to weight the probability of selection of each option. This seemed like it made sense.
- <b>Prediction: </b>The same logistic regression as the Weighted mode is performed, but in this case, the option with the highest probability is selected and used as the prediction.

<p><b>The Features: </b> The logistic regression uses all of the previous matches as training data whether they were from the current player or not. I am considering adding an option to base predictions only on the current player, but I doubt a single player will play it long enough to train the model to recognize their specific patterns.</p>

- <b>Player 1 Choices: </b>The last 4 choices by Player 1
- <b>Computer Choices: </b>The last 4 choices by the Computer
- <b>Outcomes: </b>The outcomes of the last 4 matches
- <b>Time to make choice: </b>The amount of time between the end of the previous round and the selection of an option by Player 1
- <b>Number of Rock Uses: </b>The cumulative number of times Player 1 used Rock
- <b>Number of Paper Uses: </b>The cumulative number of times Player 1 used Paper
- <b>Number of Scissors Uses: </b>The cumulative number of times Player 1 used Scissors

<p>That's it. With each new match, the model runs again. I am interested to see at what point latency starts to become a real issue. How many matches can it cruch through before there starts to be some real performance consequences. I added a process timer that measures the time required to run the model.  Perhaps at some point, I will add a criterion that says only use the last X number of matches to make predictions. Or I could learn how to simply update the model rather than run the full thing. I'm still learning.</p>
