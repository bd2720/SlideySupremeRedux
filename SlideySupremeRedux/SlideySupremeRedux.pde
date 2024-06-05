/*
  15-puzzle of arbitrary size (mxn)
  Successor to my hard-coded 3x3 version from 2019
  
  SlideySupremeRedux.pde: main sketch. calls setup() and draw().
  Uses functions and variables from the other sketches.
  Uses switch() and State to simulate a finite state machine.
*/


//  *** CUSTOMIZABLE OPTIONS ***
int m = 4; // horizontal board length
int n = 4; // vertical board length
String colorSchemeName = "DEFAULT"; // color scheme (look at initSchemes for a list)

enum State { INIT, PREGAME, PLAY, SOLVED, RESIZE }
State state; // initialized in setup()

boolean pmousePressed; // mousePressed 1 frame ago
boolean pkeyPressed; // keyPressed 1 frame ago
char pkey; // key (last key pressed) 1 frame ago

String inputTemp;
int newM;
int newN;

void setup(){
  size(1280, 720);
  state = State.INIT;
  initStats();
  initButtons();
  initSchemes();
  applyScheme(colorSchemeName);
  initBoard();
  shuffleBoard();
  background(activeScheme.bg);
  drawBoard(); 
  displayStatText(); // timer and moves
  state = State.PREGAME;
  pmousePressed = mousePressed;
  pkey = key;
  pkeyPressed = keyPressed;
}

void draw(){
  background(activeScheme.bg);
  drawButton(0);
  drawButton(1);
  drawBoard();
  displayStatText();
  switch(state){
    case PREGAME: // before the first move
      if(moveTile()){ // transition to PLAY
         tStart = System.currentTimeMillis();
         state = State.PLAY;
      } else if(pollButton(0)){ // "self-transition", just re-shuffle
        shuffleBoard(); 
      } else if(pollButton(1)){
        inputTemp = "";
        state = State.RESIZE; 
      }
      break;
    case PLAY: // after the first move, before solve
      tElapsed = System.currentTimeMillis() - tStart;
      // tElapsed *= 600; // time multiplier (debug)
      moveTile();
      if(isSolved()){ // transition to SOLVED
        updateStats();
        state = State.SOLVED;
      }
      else if(pollButton(0)){ // transition to PREGAME
        shuffleBoard();
        tElapsed = 0;
        moves = 0;
        state = State.PREGAME;
      } else if(pollButton(1)){
        inputTemp = "";
        state = State.RESIZE; 
      }
      break;
    case SOLVED: // after puzzle is solved
      displayWinText();
      if(pollButton(0)){ // transition to PREGAME
        shuffleBoard();
        tElapsed = 0;
        moves = 0;
        state = State.PREGAME;
      } else if(pollButton(1)){
        inputTemp = "";
        state = State.RESIZE; 
      }
      break;
  
    case RESIZE: // change m and n
      // darken screen
      fill(0, 127);
      rectMode(LEFT);
      rect(0, 0, width, height);
      // draw prompt box
      stroke(activeScheme.board);
      fill(activeScheme.tile);
      rectMode(CENTER);
      rect(width/2, height/2, width/4, height/4);
      fill(activeScheme.nums);
      textSize(height/30);
      textAlign(CENTER, CENTER);
      text("Enter puzzle width x height.\nEx: \"2x2\" (min), \"4x3\", \"5x5\"...", width/2, 15*height/36);
      textSize(height/9);
      text(inputTemp, width/2, 19*height/36);
      if(!keyPressed || pkeyPressed) break;
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
      
      break;
    default:
      break;
  }
  pmousePressed = mousePressed;
  pkey = key;
  pkeyPressed = keyPressed;
}
