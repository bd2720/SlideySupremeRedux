/*
  Text.pde: Contains code to display number of moves and time elapsed.
  Contains a function to format elapsed milliseconds into a readable string.
  Inits and tracks best stats.
  Also displays winning text.
*/

long tStart;
long tElapsed;

long bestTime; // lowest number of milliseconds
String bestTimeStr; // string rep. of bestTime
int bestMoves; // lowest number of moves

// display text for moves and timer
void displayStatText(){
  textAlign(RIGHT);
  textSize(40);
  fill(activeScheme.text);
  text("Time: ", 3*width/4 - 20, height/8);
  text("Moves: ", 3*width/4 - 20, height/4);
  textSize(20);
  fill(activeScheme.board);
  text("Best: ", 3*width/4 - 30, 3*height/16 - 5);
  text("Best: ", 3*width/4 - 30, 5*height/16 - 5);
  //text("Inversions: ", 3*width/4 - 20, 3*height/8);
  textAlign(LEFT);
  // build time string from tElapsed
  String timeStr = formatTimeStr(tElapsed);
  fill(activeScheme.text);
  textSize(40);
  text(timeStr, 3*width/4 - 20, height/8);
  text(moves, 3*width/4 - 20, height/4);
  //int inv = countInversions(boardNums);
  //text(inv, 3*width/4 - 20, 3*height/8);
  
  textSize(20);
  fill(activeScheme.board);
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
  text("You Did It!", 3*width/4, height/2);
}

// called in setup()
void initStats(){
  bestTime = Long.MAX_VALUE;
  bestTimeStr = "";
  bestMoves = Integer.MAX_VALUE;
}

// called during : PLAY --> SOLVED
void updateStats(){
  if(tElapsed < bestTime){
    bestTime = tElapsed;
    bestTimeStr = formatTimeStr(bestTime);
  }
  if(moves < bestMoves){
    bestMoves = moves;
  }
}
