/*
    Demo.pde: Contains functions for saving/loading/validating demos.
    A demo is a recording of inputs, timestamps and initial state (optional),
    which are then played back to simulate a game replay.
    When a new best time is set, the demo will be saved.
    
    DemoBuilder: builds a demo, saves if new best.
    DemoPlayer:  loads demo and handles playback.
*/

/*
    Demo File Format (JSON):
    <m>x<n>.demo =
    [{
      m: <Move (U, D, L or R)< (int)
      t: <time of input (ms)> (long)
    }] (JSONArray)
    
*/

// sub-states for use by DemoPlayer
enum DemoState { INIT, SETUP, PLAY, FINISH, ESCAPE } 

// name of folder in data/ that holds demos
final String demoFolder = "demos";
final String demoFileExt = ".demo";

// builds a demo for a given m, n
// init. during transition to State.PREGAME
class DemoBuilder {
  private JSONArray tempInputs;  // array of input/timestamp Objects
  private String demoName; // <m>x<n>.demo
  private String demoFilePath; // e.g. "demos/4x3.demo"
  private int numMoves;  // current move number
  private int mBoard;
  private int nBoard;
  
  public DemoBuilder(int currM, int currN){
    mBoard = currM;
    nBoard = currN;
    numMoves = 0;
    demoName = mBoard + "x" + nBoard + demoFileExt;
    demoFilePath = demoFolder + "/" + this.demoName;
    initEmptyDemo();
  }
  
  public String getDemoPath(){
    return this.demoFilePath; 
  }
  
  private void initEmptyDemo(){
    tempInputs = new JSONArray();
  }
  
  public void logInput(long ms, Move move){
    // assume move != Move.STOP
    JSONObject input = new JSONObject(); // current input
    input.setLong("t", ms);
    input.setInt("m", move.toInt());
    // add input to tempInputs
    this.tempInputs.setJSONObject(this.numMoves, input);
    this.numMoves++;
  }
  // save inputs as demo when new best
  public void saveDemoDB(){
    saveJSONArray(tempInputs, dataPath(demoFilePath));
  }
}
// global object instance
DemoBuilder demo_builder;
// global initializer
void initDemoBuilder(int currM, int currN){
  demo_builder = new DemoBuilder(currM, currN);
}

class DemoPlayer {
  public DemoState demostate; // current state of the demo replay
}
