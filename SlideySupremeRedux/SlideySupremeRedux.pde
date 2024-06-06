/*
  15-puzzle of arbitrary size (mxn)
  Successor to my hard-coded 3x3 version from 2019
  
  SlideySupremeRedux.pde: main sketch. calls setup() and draw().
  Uses functions and variables from the other sketches.
  Uses switch() and State to simulate a finite state machine.
*/

enum State { INIT, PREGAME, PLAY, SOLVED, RESIZE, PAUSED }
State state; // initialized in setup()

boolean pmousePressed; // mousePressed 1 frame ago
boolean pkeyPressed; // keyPressed 1 frame ago
char pkey; // key (last key pressed) 1 frame ago

void setup(){
  size(1280, 720);
  frameRate(60);
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
  //activate buttons
  activateButton(resetBID);
  activateButton(resizeBID);
  activateButton(colorBID);
  state = State.PREGAME;
  pmousePressed = mousePressed;
  pkey = key;
  pkeyPressed = keyPressed;
}

void draw(){
  background(activeScheme.bg);
  drawAllButtons();
  drawBoard();
  displayStatText();
  switch(state){
    case PREGAME: // before the first move
      if(moveTile()){ // transition to PLAY
        tStart = System.currentTimeMillis();
        activateButton(pauseBID); // pause button only active during play
        state = State.PLAY;
      }
      pollAllButtons();
      break;
    case PLAY: // after the first move, before solve
      tElapsed = System.currentTimeMillis() - tStart;
      // tElapsed *= 600; // time multiplier (debug)
      moveTile();
      if(isSolved()){ // transition to SOLVED
        updateStats();
        deactivateButton(pauseBID);
        state = State.SOLVED;
      }
      pollAllButtons();
      break;
    case SOLVED: // after puzzle is solved
      displayWinText();
      pollAllButtons();
      break;
    case RESIZE: // change m and n
      puzzleSize();
      break;
    case PAUSED:
      paused();
      break;
    default:
      break;
  }
  pmousePressed = mousePressed;
  pkey = key;
  pkeyPressed = keyPressed;
}
