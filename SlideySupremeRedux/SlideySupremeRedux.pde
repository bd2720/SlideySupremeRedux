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

enum State { INIT, PREGAME, PLAY, SOLVED }
State state; // initialized in setup()

void setup(){
  size(800, 600);
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
}

void draw(){
  switch(state){
    case PREGAME: // before the first move
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
      updateStats();
      state = State.SOLVED;
    } else {
      moveTile();
      background(activeScheme.bg);
      drawBoard();
      displayStatText();
    }
      break;
    case SOLVED: // after puzzle is solved
      if(pollButton(0)){
        shuffleBoard();
        tElapsed = 0;
        moves = 0;
        state = State.PREGAME;
      }
      background(activeScheme.bg);
      drawButton(0);
      drawBoard();
      displayStatText();
      displayWinText();
      break;
    default:
      break;
  }
}
