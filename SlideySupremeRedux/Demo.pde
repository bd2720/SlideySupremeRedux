/*
    Demo.pde: Contains functions for saving/loading/validating demos.
    A demo is a recording of inputs, timestamps and initial state,
    which are then played back to simulate a game replay.
    When a new best time is set, the demo will be saved.
    
    DemoBuilder: builds a demo, saves if new best.
    DemoPlayer:  loads demo and handles playback.
*/

/*
    Demo File Format (JSON):
    <m>x<n>.demo =
    {
      totalTime: demo runtime in milliseconds (long)
      inputs: [{
        inputDir: Move (U, D, L or R)
        timestamp: time of input (ms) (long)
      }] (JSONArray)
    }
    
*/

// builds a demo for a given m, n
// init. during transition to State.PREGAME
class DemoBuilder {
  private JSONObject tempDemo;   // current incomplete demo
  private JSONArray tempInputs;  // array of input/timestamp Objects  
  private long msTime;           // final displayed time in ms
  
  private String demoName; // <m>x<n>.ssr
  private int moveNumber;  // current move number
  private int mBoard;
  private int nBoard;
  
  public DemoBuilder(int currM, int currN){
    mBoard = currM;
    nBoard = currN;
    demoName = mBoard + "x" + nBoard + ".ssr";
    initEmptyDemo();
  }
  
  public void initEmptyDemo(){
    tempDemo = new JSONObject();
    tempInputs = new JSONArray();
  }
  
  public void logInput(long ms, Move move){
    return;
  }
  
}

enum DemoState { INIT, SETUP, PLAY, FINISH, ESCAPE } 

class DemoPlayer {
  public DemoState demostate; // current state of the demo replay
}
