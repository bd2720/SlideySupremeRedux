/*
  Text.pde: Contains code to display number of moves and time elapsed.
  Also displays winning text.
*/

int moves; // number of moves taken
long tStart;
long tElapsed;

// display text for moves and timer
void displayStatText(){
  textSize(40);
  textAlign(RIGHT);
  fill(activeScheme.text);
  text("Time: ", 3*width/4 - 20, height/8);
  text("Moves: ", 3*width/4 - 20, height/4);
  textAlign(LEFT);
  // build time string from tElapsed
  long msec = tElapsed % 1000;
  long sec = (tElapsed / 1000) % 60;
  long min = (tElapsed / 60000) % 60;
  long hour = tElapsed / 3600000;
  String timeStr;
  if(tElapsed < 60000){
    timeStr = sec + "." + String.format("%03d", msec);
  } else if(tElapsed < 3600000) {
    timeStr = min + ":" + String.format("%02d", sec) + "." + String.format("%03d", msec);
  } else {
    timeStr = hour + ":" + String.format("%02d", min) + ":" + String.format("%02d", sec) + "." + String.format("%03d", msec);
  }
  text(timeStr, 3*width/4 - 20, height/8);
  text(moves, 3*width/4 - 20, height/4);
}

void displayWinText(){
  textSize(60);
  textAlign(CENTER);
  fill(activeScheme.text);
  text("You Did It!", 3*width/4 - 20, 2*height/3);
}
