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

boolean pmousePressed; // mousePressed 1 frame ago
boolean pkeyPressed; // keyPressed 1 frame ago
char pkey; // key (last key pressed) 1 frame ago

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
  pmousePressed = mousePressed;
  pkey = key;
  pkeyPressed = keyPressed;
}

void draw(){
  switch(state){
    case PREGAME: // before the first move
      background(activeScheme.bg);
      drawButton(0);
      drawBoard();
      displayStatText();
      if(moveTile()){ // transition to PLAY
         tStart = System.currentTimeMillis();
         state = State.PLAY;
      } else if(pollButton(0)){ // "self-transition", just re-shuffle
        shuffleBoard(); 
      }
      break;
    case PLAY: // after the first move, before solve
      tElapsed = System.currentTimeMillis() - tStart;
      // tElapsed *= 600; // time multiplier (debug)
      background(activeScheme.bg);
      drawButton(0);
      drawBoard();
      displayStatText();
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
      }
      break;
    case SOLVED: // after puzzle is solved
      background(activeScheme.bg);
      drawButton(0);
      drawBoard();
      displayStatText();
      displayWinText();
      if(pollButton(0)){ // transition to PREGAME
        shuffleBoard();
        tElapsed = 0;
        moves = 0;
        state = State.PREGAME;
      }
      break;
    default:
      break;
  }
  pmousePressed = mousePressed;
  pkey = key;
  pkeyPressed = keyPressed;
}
