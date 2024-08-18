/*
  Stats.pde: Contains code to display number of moves and time elapsed.
  Contains a function to format elapsed milliseconds into a readable string.
  Initializes best stats for a given mxn by loading from (or creating) scores.json
  Updates best moves and best time after solve, storing to scores.json
  Also displays winning text.
*/

long tStart;
long tElapsed;

long bestTime; // lowest number of milliseconds
String bestTimeStr; // string rep. of bestTime
int bestMoves; // lowest number of moves

final String scoresFileName = "scores.json"; // load here
final String scoresFilePath = "data/" + scoresFileName; // save here
JSONArray scores; // array of JSON Objects: {"mxn", time, timeStr, moves}

boolean beatTime;  // did we beat the best time?
boolean beatMoves; // did we beat the fewest moves?

// display text for moves and timer
void displayStatText(){
  textAlign(RIGHT);
  textSize(height/16);
  fill(activeScheme.text);
  text("Time: ", 3*width/4 - 20, height/8);
  text("Moves: ", 3*width/4 - 20, height/4);
  textSize(height/32);
  fill(activeScheme.subtext);
  text("Best: ", 3*width/4 - 30, 3*height/16 - 5);
  text("Best: ", 3*width/4 - 30, 5*height/16 - 5);
  textAlign(LEFT);
  // build time string from tElapsed
  String timeStr = formatTimeStr(tElapsed);
  fill(activeScheme.text);
  textSize(height/16);
  text(timeStr, 3*width/4 - 20, height/8);
  text(moves, 3*width/4 - 20, height/4);
  
  textSize(height/32);
  fill(activeScheme.subtext);
  if(bestTimeStr.isEmpty()){
    text("---", 3*width/4 - 30, 3*height/16 - 5);
    text("---", 3*width/4 - 30, 5*height/16 - 5);
  } else {
    text(bestTimeStr, 3*width/4 - 30, 3*height/16 - 5);
    text(bestMoves, 3*width/4 - 30, 5*height/16 - 5);
  }
}

// formats a readable time string for tElapsed
String formatTimeStr(long timeElapsed){
  long msec = timeElapsed % 1000;
  long sec = (timeElapsed / 1000) % 60;
  long min = (timeElapsed / 60000) % 60;
  long hour = timeElapsed / 3600000;
  String timeStr;
  if(timeElapsed < 60000){
    timeStr = sec + "." + String.format("%03d", msec);
  } else if(timeElapsed < 3600000) {
    timeStr = min + ":" + String.format("%02d", sec) + "." + String.format("%03d", msec);
  } else {
    timeStr = hour + ":" + String.format("%02d", min) + ":" + String.format("%02d", sec) + "." + String.format("%03d", msec);
  }
  return timeStr;
}

// called in SOLVED
void displayWinText(){
  textSize(height/12);
  textAlign(CENTER, CENTER);
  fill(activeScheme.text);
  text("You Win!", 5*width/6, 3*height/8 - 10);
}

// called in DemoState.FINISH, when state == State.DEMO
void displayDemoText(){
  textSize(height/15);
  textAlign(CENTER, CENTER);
  fill(activeScheme.text);
  text("Demo End.", 5*width/6, 3*height/8 - 10);
}

// searches for the current n and m in the (non-null) scores JSONArray
int getScoreIndex(int currM, int currN){
  JSONObject currScore;
  for(int i = 0; i < scores.size(); i++){
    currScore = scores.getJSONObject(i);
    try {
      if(currScore.getInt("m") == currM && currScore.getInt("n") == currN) return i;
    } catch(Exception e) { // if m or n missing, skip object
    }
  }
  return -1;
}

// called in setup() (INIT)
void loadStats(){
  // default values
  bestTime = Long.MAX_VALUE;
  bestTimeStr = "";
  bestMoves = Integer.MAX_VALUE;
  // attempt to load score data from file
  scores = loadJSONArray(dataPath(scoresFileName));
  if(scores == null){
    scores = new JSONArray(); // create a new scores array
    return;
  }
  // attempts to find "mxn" data from file
  int scoreID = getScoreIndex(m, n);
  if(scoreID == -1) return; // mxn score record not found
  JSONObject currScore = scores.getJSONObject(scoreID);
  try {
  bestTime = currScore.getLong("time");
  if(bestTime < 0){
    bestTime = Long.MAX_VALUE;
    bestTimeStr = "";
  } else {
    bestTimeStr = formatTimeStr(bestTime); 
  }
  bestMoves = currScore.getInt("moves");
  if(bestMoves <= 0){
    bestMoves = Integer.MAX_VALUE;
  }
  } catch(Exception e){ // if any field is missing, fill all with defaults
    bestTime = Long.MAX_VALUE;
    bestTimeStr = "";
    bestMoves = Integer.MAX_VALUE;
  }
}

// called during : PLAY --> SOLVED
void saveStats(){
  beatTime = false;
  beatMoves = false;
  if(tElapsed < bestTime){
    bestTime = tElapsed;
    bestTimeStr = formatTimeStr(bestTime);
    beatTime = true;
  }
  if(moves < bestMoves){
    bestMoves = moves;
    beatMoves = true;
  }
  if(!(beatTime || beatMoves)) return; 
  // assumes scores array is already loaded
  int scoreID = getScoreIndex(m, n);
  if(scoreID == -1){  // mxn score record not found, must create
    JSONObject currScore = new JSONObject();
    currScore.setInt("m", m);
    currScore.setInt("n", n);
    currScore.setLong("time", bestTime);
    currScore.setInt("moves", bestMoves);
    scores.append(currScore);
    saveJSONArray(scores, dataPath(scoresFileName));
    return;
  }
  JSONObject currScore = scores.getJSONObject(scoreID);
  if(beatTime) currScore.setLong("time", bestTime);
  if(beatMoves) currScore.setInt("moves", bestMoves);
  saveJSONArray(scores, dataPath(scoresFileName));
}
