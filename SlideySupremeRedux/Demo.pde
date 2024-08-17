/*
    Demo.pde: Contains functions for saving/loading/validating demos.
    A demo is a recording of inputs, timestamps and initial state (optional),
    which are then played back to simulate a game replay.
    When a new best time is set, the demo will be saved.
    
    
    DemoBuilder: builds a demo, saves if new best.
    DemoPlayer:  loads/reconstructs demo and handles playback.
*/

/*
    Demo File Format (JSON):
    <m>x<n>.demo =
    [{
      m: <Move (U, D, L or R)< (int)
      t: <time of input (ms)> (long)
    }] (JSONArray)
    
*/

// name of folder in data/ that holds demos
final String demoFolder = "demos";
final String demoFileExt = ".demo";

class DemoNullException extends Exception {
  public DemoNullException(String eMsg){
    super(eMsg); 
  }
}

// saves and loads demos
// superclass of DemoBuilder and DemoPlayer
class DemoArchiver {
  private int mBoard;
  private int nBoard;
  private String demoName; // <m>x<n>.demo
  private String demoFilePath; // e.g. "demos/4x3.demo"
  
  protected JSONArray tempInputs;  // array of input/timestamp Objects
  
  public DemoArchiver(int currM, int currN){
    mBoard = currM;
    nBoard = currN;
    demoName = mBoard + "x" + nBoard + demoFileExt;
    demoFilePath = demoFolder + "/" + this.demoName;
  }
  
  // return "demos/4x3.demo"
  public String getDemoPath(){
    return this.demoFilePath; 
  }
  
  public boolean demoExists(){
    return (loadJSONArray(dataPath(demoFilePath)) != null);
  }
  
  // save current demo to file "demoName"
  public void saveDemo(){
    saveJSONArray(tempInputs, dataPath(demoFilePath));
  }
  
  // load demo to tempInputs
  // throws exception when demo not present
  public void loadDemo() throws DemoNullException {
    tempInputs = loadJSONArray(dataPath(demoFilePath));
    if(tempInputs == null){
      throw new DemoNullException("demo" + demoName + "missing!");
    }
  }
}

// builds a demo for a given m, n
// init. during transition to State.PREGAME
class DemoBuilder extends DemoArchiver {
  private int numMoves;  // current move number
  
  public DemoBuilder(int currM, int currN){
    super(currM, currN); // pass m and n to DemoArchiver
    numMoves = 0;
    // init empty demo
    tempInputs = new JSONArray();
  }
  
  // log the current move and timestamp, advance numMoves
  public void logInput(long ms, Move move){
    // assume move != Move.STOP
    JSONObject input = new JSONObject(); // current input
    input.setLong("t", ms);
    input.setInt("m", move.toInt());
    // add input to tempInputs
    this.tempInputs.setJSONObject(this.numMoves, input);
    this.numMoves++;
  }
}

// global object instance
DemoBuilder demo_builder;

// global initializer
void initDemoBuilder(int currM, int currN){
  demo_builder = new DemoBuilder(currM, currN);
}

// sub-states for use by DemoPlayer
enum DemoState { INIT, SETUP, PLAY, PAUSED, FINISH, ESCAPE }

// emulates the main game loop with a demo
class DemoPlayer extends DemoArchiver {
  private DemoState demostate; // current state of the demo replay
  private DemoState pDemostate; // prev. state of demo
  
  private int currPlaybackMove; // current move number
  private long finalMoveTime; // time of final move (ms)
  private int totalMoves; // total number of moves
  
  private boolean playing; // true if demo playback is currently active
  private long startTime; // staring time of playback (ms)
  private long currTime; // current time (time elapsed) of playback
  
  public DemoPlayer(int currM, int currN) {
    super(currM, currN); // pass m and n to DemoArchiver
    demostate = DemoState.INIT;
    pDemostate = DemoState.INIT;
    playing = false;
  }
  // change demostate
  public void setDemoState(DemoState dstate){
    this.pDemostate = demostate;
    this.demostate = dstate;
  }
  public boolean isPlaying(){
    return this.playing; 
  }
  public void setIsPlaying(boolean b){
    this.playing = b; 
  }
  
  // check if element of tempInputs is correctly formatted
  private boolean validateInput(JSONObject input){
    try {
      int moveVal = input.getInt("m");
      if(moveFromInt(moveVal) == Move.NONE) return false;
      long moveTime = input.getLong("t");
      if(moveTime < 0) return false;
    } catch(Exception e){
      return false;
    }
    return true;
  }
  
  /* fill board[][] with original state of demo board
     init. finalNumMoves and finalMoveTime
     returns true if demo is valid
     called in DemoState.INIT, and XXX-->DemoState.SETUP
  */ 
  public boolean reconstructBoard(){
    this.totalMoves = tempInputs.size(); // init totalMoves
    this.finalMoveTime = tempInputs.getJSONObject(totalMoves-1).getLong("t");
    if(totalMoves == 0) return false;
    // init. board[][] to solved
    solveBoard();
    // loop backwards over inputs
    JSONObject input;
    Move move;
    long moveTime = 0;
    for(int inputID = totalMoves-1; inputID >= 0; inputID--){
      // get current input
      input = tempInputs.getJSONObject(inputID);
      // ensure input is valid
      if(!validateInput(input)) return false;
      // apply opposite move to board
      move = moveFromInt(input.getInt("m")).opposite();
      executeMove(move);
      // save timestamp
      moveTime = input.getLong("t");
    } //<>//
    return true;
  }
  
  // take current timestamp
  public void beginPlayback() {
    // init. starting time
    this.startTime = System.currentTimeMillis();
    // init. moves to 0
    this.currPlaybackMove = 0;
  }
  
  // plays back move(s) that occurred in the current 1/fps ms window
  public void playback() {
    // take current time
    this.currTime = System.currentTimeMillis() - this.startTime;
    // replay more moves until timestamp exceeds currTime
    while(currPlaybackMove < this.totalMoves){
      JSONObject input = this.tempInputs.getJSONObject(currPlaybackMove);
      long inputTime = input.getLong("t");
      // stop "frame" of playback if time exceeds currTime
      if(inputTime > currTime) break;
      // otherwise, execute move
      Move inputMove = moveFromInt(input.getInt("m"));
      executeMove(inputMove);
      // increment current move number
      currPlaybackMove++;
    }
    // update GLOBAL tElapsed, moves
    moves = this.currPlaybackMove;
    // cap global time at demo's final move time
    if(this.currTime > this.finalMoveTime){
      tElapsed = this.finalMoveTime; 
    } else {
      tElapsed = this.currTime;
    }
  }
  
  // execute part of the demo loop consistent with demostate
  public void execStateFunction(){
    //background has already been drawn
    switch(this.demostate){
       case SETUP: // after INIT, before PLAY
         drawBoard();
         drawAllButtons();
         displayStatText();
         // exit demo if exit demo pressed
         if(demo_button.pollButton()) {
           demo_button.buttonFunction();
           return;
         }
         // transition to DemoState.PLAY if pause button pressed 
         if(pause_button.pollButton()){
           pause_button.buttonFunction();
           return;
         }
         break;
       case PLAY:
         drawBoard();
         drawAllButtons();
         displayStatText();
         // playback for current "frame"
         this.playback();
         // if demo finished, transition to DemoState.FINISH
         if(this.currPlaybackMove == this.totalMoves) {
           this.setDemoState(DemoState.FINISH);
           return;
         }
         break;
       case FINISH:
         drawBoard();
         drawAllButtons();
         displayStatText();
         displayDemoText();
         break;
       default:
         break;
    }
  }
}

// global object instance
DemoPlayer demo_player;

// global initializer
void initDemoPlayer(int currM, int currN){
  demo_player = new DemoPlayer(currM, currN);
}
