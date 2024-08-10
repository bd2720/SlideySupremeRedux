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
enum DemoState { INIT, SETUP, PLAY, FINISH, ESCAPE } 

// emulates the main game loop with a demo
class DemoPlayer extends DemoArchiver {
  private DemoState demostate; // current state of the demo replay
  private DemoState pDemostate; // prev. state of demo
  
  private long movesLeft; // current move number
  private long finalMoveTime; // time of final move (ms)
  
  public DemoPlayer(int currM, int currN) {
    super(currM, currN); // pass m and n to DemoArchiver
    demostate = DemoState.INIT;
    pDemostate = DemoState.INIT;
    movesLeft = 0;
  }
  
  // fill board[][] with original state of demo board
  public boolean reconstructDemo(){
    return false;
  }
}
