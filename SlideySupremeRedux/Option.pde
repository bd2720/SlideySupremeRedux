/*
    Option.pde: displays option prompts and parses/processes typed input.
    Displays and polls the pause button when paused (State.PAUSED)
    Initializes info string, containing info, key controls + schemes
    Displays info box when INFO is clicked.
*/

String inputTemp; // buffer for user input
int newM;
int newN;

// called during RESIZE
void puzzleSize(){ // draws, parses menu info for the resize window
  // darken screen
  fill(0, 127);
  noStroke();
  rectMode(LEFT);
  rect(0, 0, width, height);
  // draw prompt box
  stroke(activeScheme.board);
  fill(activeScheme.tile);
  rectMode(CENTER);
  rect(width/2, height/2, height/2, height/4);
  fill(activeScheme.nums);
  textSize(height/30);
  textAlign(CENTER, CENTER);
  text("Enter puzzle width x height.\nEx: \"2x2\" (min), \"4x3\", \"5x5\"...", width/2, 15*height/36);
  textSize(height/9);
  text(inputTemp, width/2, 19*height/36);
  if(!keyPressed || pkeyPressed) return;
  String tempStr;
  int xIndex;
  switch(key){
    case ENTER:
    case RETURN:
      xIndex = inputTemp.indexOf("x");
      if(xIndex == -1) break;
      if(xIndex == inputTemp.length()-1) break;
      tempStr = inputTemp.substring(xIndex + 1); // the string after "x"
      if(tempStr.length() > 2) break; // prevent overflow crash
      newN = Integer.parseInt(tempStr);
      if(newN < minDim || newN > maxDim) break;
      m = newM;
      n = newN;
      saveDefaults(); // update defaults.json with new m and n
      initStats();
      initBoard();
      shuffleBoard();
      tElapsed = 0;
      moves = 0;
      state = State.PREGAME;
      break;
    case BACKSPACE:
      if(inputTemp.length() == 0) break;
      inputTemp = inputTemp.substring(0, inputTemp.length()-1);
      break;
    case 'x':
    case 'X':
      if(inputTemp.length() == 0 || inputTemp.indexOf("x") >= 0) break;
      if(inputTemp.length() > 2) break; // prevent overflow crash
      newM = Integer.parseInt(inputTemp);
      if(newM < minDim || newM > maxDim) break;
      inputTemp += "x";
      break;
    default:
      if(key >= '1' && key <= '9') inputTemp += String.valueOf(key);
      // only write 0 if it isn't the first char after "" or "x"
      else if(key == '0' && inputTemp.length() > 0 && inputTemp.indexOf("x") != inputTemp.length()-1) inputTemp += '0';
      break;
  }
}

// called during the PAUSED state.
void paused(){
  // cover board
  fill(activeScheme.bg);
  noStroke();
  rectMode(CORNERS);
  rect(0, 0, width/2, height);
  // darken screen
  fill(0, 127);
  rectMode(LEFT);
  rect(0, 0, width, height);
  // "PAUSED"
  fill(activeScheme.text);
  textSize(height/12);
  textAlign(CENTER, CENTER);
  text("PAUSED", width/4, height/3);
  pause_button.drawButton();
  if(!pause_button.pollButton()) return;
  // back to play
  pause_button.text = "Pause";
  tStart = System.currentTimeMillis() - tElapsed;
  state = State.PLAY;
}

State pstate; // used for restoring the previous state after exiting INFO state
String infoString;

// called in setup()
// hard-coded, to guarantee consistency across platforms
void initInfoString(){
  infoString = "";
  // game info
  infoString += "A 2D sliding puzzle of \"arbitrary\" width and height.\n";
  infoString += "Created with the Processing sketchbook (Java Mode).\n";
  infoString += "Supports key controls, but mouse is recommended.\n";
  infoString += "Minimum puzzle size is 2x2, maximum is 31x31.\n";
  infoString += "Settings and high scores save across playthroughs.\n";
  infoString += "\n";
  // controls
  infoString += "KEYBOARD CONTROLS\n";
  infoString += "W / UP : Move a tile up to fill the empty square.\n";
  infoString += "A / LEFT: Move a tile left to fill the empty square.\n";
  infoString += "S / DOWN: Move a tile down to fill the empty square.\n";
  infoString += "D / RIGHT: Move a tile right to fill the empty square.\n";
  infoString += "P : Pause/Unpause the timer.\n";
  infoString += "R : Re-shuffle the board, resetting the timer and moves counter.\n";
  infoString += "X : Change the size of the puzzle (enter \"width x height\").\n";
  infoString += "C : Cycle the game's color scheme.\n";
  infoString += "M : Resize the game window.\n";
  infoString += "I : Display info about the game.\n";
  infoString += "ESCAPE : Exit the game.\n";
  infoString += "\n";
  // themes
  infoString += "COLOR SCHEMES\n";
  infoString += "DEFAULT : Black and white.\n";
  infoString += "CLASSIC : Brown board. Color of the original version.\n";
  infoString += "CLOUDY : Soft greyscale theme.\n";
  infoString += "MINT : Low intensity greens.\n";
  infoString += "EARTH : Dark brown, green and blue.\n";
}

// called during INFO state
void info(){
  // cover board
  fill(activeScheme.bg);
  noStroke();
  rectMode(CORNERS);
  rect(0, 0, width/2, height);
  // darken screen
  fill(0, 127);
  rectMode(LEFT);
  rect(0, 0, width, height);
  // draw info button
  info_button.drawButton();
  // draw info box, based on aspect ratio
  stroke(activeScheme.board);
  fill(activeScheme.tile);
  rectMode(CENTER);
  if(width/(float)height > 1.5){ // 16:9
    rect(width/4, height/2, 9*width/20, 9*height/10);
  } else { // 4:3
    rect(width/4, height/2, 9*width/20, 13*height/20);
  }
  // draw text
  fill(activeScheme.nums);
  textSize(width/60);
  textAlign(LEFT, CENTER);
  text(infoString, width/30, height/2 + 10);
  if(info_button.pollButton()){
    tStart = System.currentTimeMillis() - tElapsed;
    state = pstate;
  }
}
