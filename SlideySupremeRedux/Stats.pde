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

final String dataFolderName = "data";
final String dataFileName = "scores.json";
final String dataFilePath = dataFolderName + "/" + dataFileName;
JSONArray scores; // array of JSON Objects: {"mxn", time, timeStr, moves}

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
  //text("Inversions: ", 3*width/4 - 20, 3*height/8);
  textAlign(LEFT);
  // build time string from tElapsed
  String timeStr = formatTimeStr(tElapsed);
  fill(activeScheme.text);
  textSize(height/16);
  text(timeStr, 3*width/4 - 20, height/8);
  text(moves, 3*width/4 - 20, height/4);
  //int inv = countInversions(boardNums);
  //text(inv, 3*width/4 - 20, 3*height/8);
  
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
  textSize(60);
  textAlign(CENTER, CENTER);
  fill(activeScheme.text);
  text("You Did It!", 3*width/4, 7*height/16);
}

// searches for the current n and m in the (non-null) scores JSONArray
int getScoreIndex(int currM, int currN){
  JSONObject currScore;
  for(int i = 0; i < scores.size(); i++){
    currScore = scores.getJSONObject(i);
    if(currScore.getInt("m") == currM && currScore.getInt("n") == currN) return i;
  }
  return -1;
}

// called in setup() (INIT)
void initStats(){
  // default values
  bestTime = Long.MAX_VALUE;
  bestTimeStr = "";
  bestMoves = Integer.MAX_VALUE;
  // attempt to load score data from file
  scores = loadJSONArray(dataFileName);
  if(scores == null){
    scores = new JSONArray(); // create a new scores array
    return;
  }
  // attempts to find "mxn" data from file
  int scoreID = getScoreIndex(m, n);
  if(scoreID == -1) return; // mxn score record not found
  JSONObject currScore = scores.getJSONObject(scoreID);
  bestTime = currScore.getLong("time");
  bestTimeStr = currScore.getString("timeStr");
  bestMoves = currScore.getInt("moves");
}

// called during : PLAY --> SOLVED
void updateStats(){
  boolean beatTime = false;
  boolean beatMoves = false;
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
    currScore.setString("timeStr", bestTimeStr);
    currScore.setInt("moves", bestMoves);
    scores.append(currScore);
    saveJSONArray(scores, dataFilePath);
    return;
  };
  JSONObject currScore = scores.getJSONObject(scoreID);
  if(beatTime){
    currScore.setLong("time", bestTime);
    currScore.setString("timeStr", bestTimeStr);
  }
  if(beatMoves) currScore.setInt("moves", bestMoves);
  saveJSONArray(scores, dataFilePath);
}
