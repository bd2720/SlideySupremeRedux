/*
    Option.pde: displays option prompts and parses/processes typed input.
    Displays and polls the pause button when paused (State.PAUSED)
*/

String inputTemp; // buffer for user input
int newM;
int newN;

// called during RESIZE
void puzzleSize(){ // draws, parses menu info for the resize window
  // darken screen
  fill(0, 127);
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
  switch(key){
  case ENTER:
    case RETURN:
      if(inputTemp.indexOf("x") == inputTemp.length()-1) break;
      newN = Integer.parseInt(inputTemp.substring(inputTemp.indexOf("x")+1));
      if(newN < 2) break;
      m = newM;
      n = newN;
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
      if(inputTemp.length() == 0 || inputTemp.indexOf("x") >= 0) break;
      newM = Integer.parseInt(inputTemp);
      if(newM < 2) break;
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
  stroke(activeScheme.bg);
  rectMode(CORNERS);
  rect(boardStart.x, boardStart.y, boardEnd.x, boardEnd.y);
  // darken screen
  fill(0, 127);
  rectMode(LEFT);
  rect(0, 0, width, height);
  // "PAUSED"
  fill(activeScheme.text);
  textSize(height/12);
  textAlign(CENTER, CENTER);
  text("PAUSED", width/4, height/3);
  drawButton(pauseBID);
  if(!pollButton(pauseBID)) return;
  // back to play
  Button pauseButton = buttons.get(pauseBID);
  pauseButton.text = "Pause";
  tStart = System.currentTimeMillis() - tElapsed;
  state = State.PLAY;
}
