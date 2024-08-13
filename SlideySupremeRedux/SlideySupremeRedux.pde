/*
  Sliding puzzle game of arbitrary size (mxn)
  Successor to my hard-coded 3x3 version from 2019
  
  SlideySupremeRedux.pde: main sketch. calls setup() and draw().
  Uses functions and variables from the other sketches.
  Uses switch() and State to simulate a finite state machine.
*/

enum State { INIT, PREGAME, PLAY, SOLVED, RESIZE, PAUSED, INFO, ERROR, DEMO }
State state; // initialized in setup()
State pstate; // previous state, in case we want to restore last state
// set state
void setState(State s){
   pstate = state;
   state = s;
}

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
  pstate = State.INIT;
  setState(State.INIT);
  initResolutions();
  initSchemes();
  if(!loadDefaultsSafe()) return;
  // init. resolution and bg color ASAP
  applyScheme(colorSchemeName);
  background(activeScheme.bg);
  applyResolution(resolutionStr);
  if(!loadStatsSafe()) return;
  initInfoString();
  // vv (depends on correct resolution) vv
  initButtons();
  initBoard();
  shuffleBoard();
  initDemoBuilder(m, n);
  //activate buttons
  reset_button.activateButton();
  resize_button.activateButton();
  theme_button.activateButton();
  window_button.activateButton();
  info_button.activateButton();
  // only activate demo button if demo exists
  if(demo_builder.demoExists()){
    demo_button.activateButton();
  }
  state = State.PREGAME;
  updateIOVars();
}

void draw(){
  background(activeScheme.bg);
  switch(state){
    case PREGAME: // before the first move
      drawAllButtons();
      drawBoard();
      displayStatText();
      Move currMove = moveTile();
      if(currMove != Move.NONE){ // transition to PLAY
        tStart = System.currentTimeMillis();
        tElapsed = 0;
        demo_builder.logInput(tElapsed, currMove);
        // solved after 1 move
        if(isSolved()){ // transition to SOLVED
          if(!saveStatsSafe()) return;
          if(beatTime){
            if(!saveDemoSafe(demo_builder)) return;
            demo_button.activateButton(); // activate demo button
          }
          //pause_button.deactivateButton();
          setState(State.SOLVED);
        } else {
          pause_button.activateButton(); // pause button only active during play
          setState(State.PLAY);
        }
      }
      pollAllButtons();
      break;
    case PLAY: // after the first move, before solve
      drawAllButtons();
      drawBoard();
      displayStatText();
      tElapsed = System.currentTimeMillis() - tStart;
      currMove = moveTile();
      if(currMove != Move.NONE){
        demo_builder.logInput(tElapsed, currMove);
        // only run isSolved() after a move is made
        if(isSolved()){ // transition to SOLVED
          if(!saveStatsSafe()) return;
          if(beatTime){
            // attempt to save demo if new best time
            if(!saveDemoSafe(demo_builder)) return; 
            demo_button.activateButton(); // activate demo button
          }
          pause_button.deactivateButton();
          setState(State.SOLVED);
        }
      }
      pollAllButtons();
      break;
    case SOLVED: // after puzzle is solved
      drawAllButtons();
      drawBoard();
      displayStatText();
      displayWinText();
      pollAllButtons();
      break;
    case RESIZE: // change m and n
      drawAllButtons();
      displayStatText();
      puzzleSize();
      break;
    case PAUSED: // pause the game
      drawAllButtons();
      displayStatText();
      paused();
      // theme and window should work here
      theme_button.drawButton();
      window_button.drawButton();
      if(theme_button.pollButton()){
        if(!theme_button.buttonFunction()) return;
      }
      if(window_button.pollButton()){
        if(!window_button.buttonFunction()) return;
      }
      break;
    case INFO: // display info, keys + themes
      drawAllButtons();
      displayStatText();
      info();
      // theme and window should work here
      theme_button.drawButton();
      window_button.drawButton();
      if(theme_button.pollButton()){
        if(!theme_button.buttonFunction()) return;
      }
      if(window_button.pollButton()){
        if(!window_button.buttonFunction()) return;
      }
      break;
    case DEMO:
      demo_player.execStateFunction();
      break;
    case ERROR:
      displayJSONError();
      noLoop();
      break;
    default:
      noLoop();
      break;
  }
  updateIOVars();
}
