/*
   Button.pde: Outlines the Button class, and buttons ArrayList.
   Contains classes for buttons that extend the Button class
   Inits, polls, and draws buttons.
*/

abstract class Button {
  int id;
  boolean active; // true when the button is pressable
  String text;
  String subtext;
  int textSize; // size of text
  int bX; // x-pos of center
  int bY; // y-pos of center
  int bWidth; // button width
  int bHeight; // button height
  char bKey; // keyboard key for button
  char bKey2; // alternate key (opposite case)
  abstract boolean buttonFunction(); // function to be executed once, upon button press (false if error)
  abstract void buttonSize(); // needed for efficiently resizing buttons after window resize
  
  // sets the button's "active" field. returns the previous value
  boolean activateButton(){
    boolean oldActive = active;
    active = true;
    return oldActive;
  }
  
  boolean deactivateButton(){
    boolean oldActive = active;
    active = false;
    return oldActive;
  }
  
  // draws the button
  void drawButton(){
    stroke(activeScheme.board);
    fill(activeScheme.tile);
    rectMode(CENTER);
    rect(bX, bY, bWidth, bHeight);
    fill(activeScheme.nums);
    textSize(textSize);
    textAlign(CENTER, CENTER);
    if(subtext.isEmpty()){
      text(text, bX, bY);
    } else {
      text(text + "\n", bX, bY);
      text("\n" + subtext, bX, bY);
    }
  }
  
  // returns true when the button with the given id is pressed
  boolean pollButton(){
    boolean keyed, keyed2, clicked;
    if(!active) return false;
    keyed = keyPressed && (key == bKey && (!pkeyPressed || pkey != bKey));
    keyed2 = keyPressed && (key == bKey2 && (!pkeyPressed || pkey != bKey2));
    clicked = mousePressed && !pmousePressed && (abs(mouseX - bX)*2 <= bWidth) && (abs(mouseY - bY)*2 <= bHeight);
    return clicked || keyed || keyed2;
  }
}

class ResetButton extends Button {
  ResetButton(){
    text = "Reset";
    subtext = "";
    bKey = 'r';
    bKey2 = 'R';
    this.buttonSize();
  }
  void buttonSize(){
    // smaller text if subtext exists
    textSize = subtext.isEmpty() ? height/16 : height/19;
    bX = 7*width/8;
    bY = height/2;
    bWidth = width/6;
    bHeight = height/8;
  }
  boolean buttonFunction(){
    shuffleBoard();
    initDemoBuilder(m, n);
    tElapsed = 0;
    moves = 0;
    pause_button.deactivateButton();
    setState(State.PREGAME);
    return true;
  }
}

class ResizeButton extends Button {
  ResizeButton(){
    text = "Size:";
    subtext = mxnStr;
    bKey = 'x';
    bKey2 = 'X';
    this.buttonSize();
  }
  void buttonSize(){
    textSize = height/19;
    bX = 7*width/8;
    bY = 11*height/16;
    bWidth = width/6;
    bHeight = height/8;
  }
  boolean buttonFunction(){
    inputTemp = "";
    setState(State.RESIZE);
    return true;
  }
}
// in DEMO MODE, functions as play/stop
class PauseButton extends Button {
  PauseButton(){ 
    text = "Pause";
    subtext = "";
    bKey = 'p';
    bKey2 = 'P';
    this.buttonSize();
  }
  void buttonSize(){
    // smaller text if subtext exists
    textSize = subtext.isEmpty() ? height/16 : height/19;
    bX = 5*width/8;
    bY = height/2;
    bWidth = width/6;
    bHeight = height/8; 
  }
  boolean buttonFunction(){
    this.text = "Resume";
    setState(State.PAUSED);
    return true;
  }
}

class ThemeButton extends Button {
  ThemeButton(){
    text = "Theme:";
    subtext = colorSchemeName;
    bKey = 'c';
    bKey2 = 'C';
    this.buttonSize();
  }
  void buttonSize(){
    textSize = height/19;
    bX = 7*width/8;
    bY = 7*height/8;
    bWidth = width/6;
    bHeight = height/8; 
  }
  boolean buttonFunction(){
    int i;
    for(i = 0; i < schemes.size(); i++){
      if(schemes.get(i).name.equals(activeScheme.name)) break;
    }
    Scheme newScheme;
    if(i == schemes.size() - 1) newScheme = schemes.get(0);
    else newScheme = schemes.get(i+1);
    colorSchemeName = newScheme.name;
    this.subtext = colorSchemeName;
    activeScheme = newScheme;
    return saveDefaultsSafe(); // update defaults.json with new colorSchemeName
  }
}

class WindowButton extends Button {
  WindowButton(){ 
    text = "Window:";
    subtext = resolutionStr;
    bKey = 'm';
    bKey2 = 'M';
    this.buttonSize();
  }
  void buttonSize(){
    textSize = height/19;
    bX = 5*width/8;
    bY = 7*height/8;
    bWidth = width/6;
    bHeight = height/8;
  }
  boolean buttonFunction(){
    int i;
    for(i = 0; i < resolutions.size(); i++){
      if(resolutions.get(i).equals(activeResolution)) break;
    }
    Coord newRes;
    if(i == resolutions.size() - 1) newRes = resolutions.get(0);
    else newRes = resolutions.get(i+1);
    resolutionStr = newRes.x + "x" + newRes.y;
    this.subtext = resolutionStr;
    applyResolution(resolutionStr);
    sizeBoard();
    sizeAllButtons();
    return saveDefaultsSafe(); // update defaults.json with new screen resolution
  }
}

class InfoButton extends Button {
  InfoButton(){ 
    text = "Info";
    subtext = "";
    bKey = 'i';
    bKey2 = 'I';
    this.buttonSize();
  }
  void buttonSize(){
    textSize = height/16;
    bX = 5*width/8;
    bY = 11*height/16;
    bWidth = width/6;
    bHeight = height/8;
  }
  boolean buttonFunction(){
    info_button.text = "Resume";
    setState(State.INFO);
    return true;
  }
}
// playback a demo/recording of the fastest solve, if available
class DemoButton extends Button {
  DemoButton(){ 
    text = "View Demo";
    subtext = "";
    bKey = 'z';
    bKey2 = 'Z';
    this.buttonSize();
  }
  void buttonSize(){
    textSize = height/32;
    bX = 5*width/8;
    bY = 9*height/24 - 10;
    bWidth = height/6;
    bHeight = height/24;
  }
  boolean buttonFunction(){
    /* TRANSITION OUT OF DEMO MODE (GO TO PREGAME) */
    if(state == State.DEMO){
      // take care of PREGAME transition stuff
      setState(State.PREGAME);
      shuffleBoard();
      initDemoBuilder(m, n);
      tElapsed = 0;
      moves = 0;
      // deal with buttons
      pause_button.deactivateButton();
      reset_button.activateButton();
      info_button.activateButton();
      resize_button.activateButton();
      // only activate demo button if demo exists
      if(demo_builder.demoExists()){
        demo_button.activateButton();
      }
   
      pause_button.text = "Pause";
      pause_button.subtext = reset_button.subtext = "";
      pause_button.buttonSize();
      reset_button.buttonSize();
      demo_button.text = "View Demo";
      return true;
    }
    /* TRANSITION INTO DEMO MODE */
    // init. demo_player
    initDemoPlayer(m, n);
    // change state and demostate
    setState(State.DEMO);
    demo_player.setDemoState(DemoState.INIT);
    // attempt to load demo
    if(!loadDemoSafe(demo_player)) return false;
    // attempt to reconstruct board
    if(!demo_player.reconstructBoard()) return false;
    // change demo_button subtext
    demo_button.text = "Exit Demo";
    // activate pause (play demo) button
    pause_button.activateButton();
    // deactivate info + size + reset buttons
    info_button.deactivateButton();
    resize_button.deactivateButton();
    reset_button.deactivateButton();
    // edit button text to describe demo-mode functionality
    pause_button.text = "Play";
    pause_button.subtext = "Demo";
    reset_button.subtext = "Demo";
    // resize buttons that previously did not have subtext
    pause_button.buttonSize();
    reset_button.buttonSize();
    // zero moves and timer
    moves = 0;
    tElapsed = 0;
    // copy demo's initialBoard to global board
    demo_player.copyToBoardDP();
    demo_player.setDemoState(DemoState.SETUP);
    return true;
  }
}

ArrayList<Button> buttons;

ResetButton reset_button;
ResizeButton resize_button;
PauseButton pause_button;
ThemeButton theme_button;
WindowButton window_button;
InfoButton info_button;
DemoButton demo_button;

// called during setup()
void initButtons(){
  buttons = new ArrayList<Button>();
  reset_button = new ResetButton();
  buttons.add(reset_button);
  resize_button = new ResizeButton();
  buttons.add(resize_button);
  pause_button = new PauseButton();
  buttons.add(pause_button);
  theme_button = new ThemeButton();
  buttons.add(theme_button);
  window_button = new WindowButton();
  buttons.add(window_button);
  info_button = new InfoButton();
  buttons.add(info_button);
  demo_button = new DemoButton();
  buttons.add(demo_button);
}

// draws all buttons; inactive buttons are greyed out
void drawAllButtons(){
  Button b;
  for(int i = 0; i < buttons.size(); i++){
    b = buttons.get(i);
    b.drawButton();
    if(!b.active){
      fill(0, 80);
      noStroke();
      rectMode(CENTER);
      rect(b.bX, b.bY, b.bWidth, b.bHeight); 
    }
  }
}

void pollAllButtons(){
  Button b;
  for(int i = 0; i < buttons.size(); i++){
    b = buttons.get(i);
    if(b.pollButton()){
      b.buttonFunction();
    }
  }
}

// called after window resizes
void sizeAllButtons(){
  for(int i = 0; i < buttons.size(); i++){
    buttons.get(i).buttonSize();
  }
}

// function specifically to poll cosmetic buttons (window and theme)
void pollCosmeticButtons(){
  if(window_button.pollButton()){
    window_button.buttonFunction(); 
  }
  if(theme_button.pollButton()){
     theme_button.buttonFunction();
  }
}
