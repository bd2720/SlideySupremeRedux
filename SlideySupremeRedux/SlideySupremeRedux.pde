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
String colorSchemeName = "CLOUDY"; // color scheme (look at initSchemes for a list)

enum State { INIT, PLAY, SOLVED }
State state; // initialized in setup()

void setup(){
  size(1280, 720);
  state = State.INIT;
  initSchemes();
  applyScheme(colorSchemeName);
  initBoard();
  shuffleBoard();
  background(activeScheme.bg);
  drawBoard();
  displayStatText(); // timer and moves
}

void draw(){
  switch(state){
    case INIT: // before the first move
      if(moveTile()){ // transition to PLAY
         tStart = System.currentTimeMillis();
         state = State.PLAY;
      } else {
        background(activeScheme.bg);
        drawBoard();
        displayStatText();
      }
    break;
    case PLAY: // after the first move, before solve
    tElapsed = System.currentTimeMillis() - tStart;
    // tElapsed *= 600; // time multiplier (debug)
    if(isSolved()){
      state = State.SOLVED;
    } else {
      moveTile();
      background(activeScheme.bg);
      drawBoard();
      displayStatText();
    }
    break;
    case SOLVED:
      background(activeScheme.bg);
      drawBoard();
      displayStatText();
      displayWinText();
    break;
  }
}
