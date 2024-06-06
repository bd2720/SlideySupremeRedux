/*
   Button.pde: Outlines the Button class, and buttons ArrayList.
   Inits, polls, and draws buttons.
*/

class Button {
  int id;
  boolean active; // true when the button is pressable
  String text;
  int textSize; // size of text
  int bX; // x-pos of center
  int bY; // y-pos of center
  int bWidth; // button width
  int bHeight; // button height
  char bKey; // keyboard key for button
  Button(){
   id = -1;
   text = "text";
   textSize = 90;
   bX = bY = 0;
   bWidth = bHeight = 100;
   bKey = 0;
   active = false;
  }
  Button(int id, String text, int textSize, int bX, int bY, int bWidth, int bHeight, char bKey){
   this.id = id;
   this.text = text;
   this.textSize = textSize;
   this.bX = bX;
   this.bY = bY;
   this.bWidth = bWidth;
   this.bHeight = bHeight;
   this.bKey = bKey;
   active = false;
  }
}

ArrayList<Button> buttons;
int resetBID = 0;
int resizeBID = 1;
int pauseBID = 2;
int colorBID = 3;


// called during setup()
void initButtons(){
  buttons = new ArrayList<Button>();
  buttons.add(new Button(resetBID, "Reset", height/12, 7*width/8, 5*height/8, width/6, height/8, 'r'));
  buttons.add(new Button(resizeBID, "Puzzle\nSize", height/18, 5*width/8, 7*height/8, width/6, height/8, 'x'));
  buttons.add(new Button(pauseBID, "Pause", height/12, 5*width/8, 5*height/8, width/6, height/8, 'p'));
  buttons.add(new Button(colorBID, "Color\nScheme", height/18, 7*width/8, 7*height/8, width/6, height/8, 'c'));
}

// sets the button's "active" field. returns the previous value
boolean activateButton(int id){
  Button b = buttons.get(id);
  boolean oldActive = b.active;
  b.active = true;
  return oldActive;
}
boolean deactivateButton(int id){
  Button b = buttons.get(id);
  boolean oldActive = b.active;
  b.active = false;
  return oldActive;
}

// draws the button with the current id
void drawButton(int id){
  Button b = buttons.get(id);
  stroke(activeScheme.board);
  fill(activeScheme.tile);
  rectMode(CENTER);
  rect(b.bX, b.bY, b.bWidth, b.bHeight);
  fill(activeScheme.nums);
  textSize(b.textSize);
  textAlign(CENTER, CENTER);
  text(b.text, b.bX, b.bY);
}

// draws all buttons; inactive buttons are greyed out
void drawAllButtons(){
  Button b;
  for(int i = 0; i < buttons.size(); i++){
    b = buttons.get(i);
    drawButton(b.id);
    if(!b.active){
      fill(0, 80);
      rectMode(CENTER);
      rect(b.bX, b.bY, b.bWidth, b.bHeight); 
    }
  }
}

// returns true when the button with the given id is pressed
boolean pollButton(int id){
  boolean keyed, clicked;
  Button b = buttons.get(id);
  if(!b.active) return false;
  keyed = keyPressed && key == b.bKey && (!pkeyPressed || pkey != b.bKey);
  clicked = mousePressed && !pmousePressed && (abs(mouseX - b.bX)*2 <= b.bWidth) && (abs(mouseY - b.bY)*2 <= b.bHeight);
  return clicked || keyed;
}

/* Polls all ACTIVE buttons in the buttons ArrayList.
   Called at the end of each frame.
   Unfortunately, must be updated manually, matching each button to its routine
   I wish I could use something like a function pointer array but we in java...
*/
void pollAllButtons(){
  if(pollButton(0)){ // reset
    b_reset();
    return;
  }
  if(pollButton(1)){ // puzzleSize
    b_resize();
    return;
  }
  if(pollButton(2)){ // pause
    b_pause();
    return;
  }
}

/*
  Specific button functions are defined below.
  Each button can have a setup function,
  called when the button is first pressed.
  This function will ultimately change the game's "state" var.
*/

// RESET BUTTON --> State = (none)
void b_reset(){
  shuffleBoard();
  tElapsed = 0;
  moves = 0;
  deactivateButton(pauseBID);
  state = State.PREGAME;
}

void b_resize(){
  inputTemp = "";
  state = State.RESIZE;
}

void b_pause(){
  Button pauseButton = buttons.get(pauseBID);
  pauseButton.text = "Resume";
  state = State.PAUSED;
}
