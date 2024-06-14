/*
  15-puzzle of arbitrary size (mxn)
  Successor to my hard-coded 3x3 version from 2019
  
  SlideySupremeRedux.pde: main sketch. calls setup() and draw().
  Uses functions and variables from the other sketches.
  Uses switch() and State to simulate a finite state machine.
*/

enum State { INIT, PREGAME, PLAY, SOLVED, RESIZE, PAUSED, INFO }
State state; // initialized in setup()
State pstate; // previous state, in case we want to restore last state

boolean pmousePressed; // mousePressed 1 frame ago
boolean pkeyPressed; // keyPressed 1 frame ago
char pkey; // key (last key pressed) 1 frame ago
int pkeyCode; // keyCode 1 frame ago

void updateIOVars(){ // called after each frame
  pmousePressed = mousePressed;
  pkey = key;
  pkeyPressed = keyPressed;
  pkeyCode = (int)keyCode;
}

void setup(){
  size(800, 600);
  frameRate(60);
  state = State.INIT;
  initInfoString();
  initResolutions();
  initSchemes();
  loadDefaults();
  applyResolution(resolutionStr);
  initStats();
  initButtons();
  applyScheme(colorSchemeName);
  initBoard();
  shuffleBoard();
  background(activeScheme.bg);
  drawBoard(); 
  displayStatText(); // timer and moves
  //activate buttons
  reset_button.activateButton();
  resize_button.activateButton();
  theme_button.activateButton();
  window_button.activateButton();
  info_button.activateButton();
  state = State.PREGAME;
  updateIOVars();
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
        pause_button.activateButton(); // pause button only active during play
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
        pause_button.deactivateButton();
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
    case INFO:
      info();
    default:
      break;
  }
  updateIOVars();
}
