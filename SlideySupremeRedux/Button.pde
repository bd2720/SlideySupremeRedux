/*
   Button.pde: Outlines the Button class, and buttons ArrayList.
   Inits, polls, and draws buttons.
*/

class Button {
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
  Button(){
   id = -1;
   text = "text";
   subtext = "sub";
   textSize = 90;
   bX = bY = 0;
   bWidth = bHeight = 100;
   bKey = 0;
   bKey2 = 0;
   active = false;
  }
  Button(int id, String text, int textSize, int bX, int bY, int bWidth, int bHeight, char bKey, char bKey2){
   this.id = id;
   this.text = text;
   this.subtext = "";
   this.textSize = textSize;
   this.bX = bX;
   this.bY = bY;
   this.bWidth = bWidth;
   this.bHeight = bHeight;
   this.bKey = bKey;
   this.bKey2 = bKey2;
   active = false;
  }
  Button(int id, String text, String subtext, int textSize, int bX, int bY, int bWidth, int bHeight, char bKey, char bKey2){
   this.id = id;
   this.text = text;
   this.subtext = subtext;
   this.textSize = textSize;
   this.bX = bX;
   this.bY = bY;
   this.bWidth = bWidth;
   this.bHeight = bHeight;
   this.bKey = bKey;
   this.bKey2 = bKey2;
   active = false;
  }
}

ArrayList<Button> buttons;
int resetBID = 0;
int resizeBID = 1;
int pauseBID = 2;
int colorBID = 3;
//int infoBID = 4;


// called during setup()
void initButtons(){
  buttons = new ArrayList<Button>();
  buttons.add(new Button(resetBID, "Reset", height/16, 7*width/8, 5*height/8, width/6, height/8, 'r', 'R'));
  buttons.add(new Button(resizeBID, "Size:", mxnStr, height/19, 5*width/8, 7*height/8, width/6, height/8, 'x', 'X'));
  buttons.add(new Button(pauseBID, "Pause", height/16, 5*width/8, 5*height/8, width/6, height/8, 'p', 'P'));
  buttons.add(new Button(colorBID, "Theme:", colorSchemeName, height/19, 7*width/8, 7*height/8, width/6, height/8, 'c', 'C'));
  //buttons.add(new Button(infoBID, "Info", height/16, 5*width/8, 5*height/8, width/6, height/8, 'p', 'P'));
}

Button findButton(int id){
  for(int i = 0; i < buttons.size(); i++){
    if(buttons.get(i).id == id) return buttons.get(i);
  }
  return new Button();
}

// sets the button's "active" field. returns the previous value
boolean activateButton(int id){
  Button b = findButton(id);
  boolean oldActive = b.active;
  b.active = true;
  return oldActive;
}
boolean deactivateButton(int id){
  Button b = findButton(id);
  boolean oldActive = b.active;
  b.active = false;
  return oldActive;
}

// draws the button with the current id
void drawButton(int id){
  Button b = findButton(id);
  stroke(activeScheme.board);
  fill(activeScheme.tile);
  rectMode(CENTER);
  rect(b.bX, b.bY, b.bWidth, b.bHeight);
  fill(activeScheme.nums);
  textSize(b.textSize);
  textAlign(CENTER, CENTER);
  if(b.subtext.isEmpty()){
    text(b.text, b.bX, b.bY);
  } else {
     text(b.text + "\n", b.bX, b.bY);
     text("\n" + b.subtext, b.bX, b.bY);
  }
}

// draws all buttons; inactive buttons are greyed out
void drawAllButtons(){
  Button b;
  for(int i = 0; i < buttons.size(); i++){
    b = buttons.get(i);
    drawButton(b.id);
    if(!b.active){
      fill(0, 80);
      stroke(0, 80);
      rectMode(CENTER);
      rect(b.bX, b.bY, b.bWidth, b.bHeight); 
    }
  }
}

// returns true when the button with the given id is pressed
boolean pollButton(int id){
  boolean keyed, keyed2, clicked;
  Button b = findButton(id);
  if(!b.active) return false;
  keyed = keyPressed && (key == b.bKey && (!pkeyPressed || pkey != b.bKey));
  keyed2 = keyPressed && (key == b.bKey2 && (!pkeyPressed || pkey != b.bKey2));
  clicked = mousePressed && !pmousePressed && (abs(mouseX - b.bX)*2 <= b.bWidth) && (abs(mouseY - b.bY)*2 <= b.bHeight);
  return clicked || keyed || keyed2;
}

/* Polls all ACTIVE buttons in the buttons ArrayList.
   Called at the end of each frame.
   Unfortunately, must be updated manually, matching each button to its routine
   I wish I could use something like a function pointer array but we in java...
   
   In the future I'd try defining Button as an interface,
   where each Button extends the interface with its own "buttonRoutine()" function.
   
*/
void pollAllButtons(){
  if(pollButton(resetBID)){ // reset
    b_reset();
    return;
  }
  if(pollButton(resizeBID)){ // puzzleSize
    b_resize();
    return;
  }
  if(pollButton(pauseBID)){ // pause
    b_pause();
    return;
  }
  if(pollButton(colorBID)){ // change color scheme
    b_color();
    return;
  }
}

/*
  Specific button functions are defined below.
  Each button can have a setup function,
  called when the button is first pressed.
*/

void b_reset(){
  shuffleBoard();
  tElapsed = 0;
  moves = 0;
  deactivateButton(pauseBID);
  state = State.PREGAME;
}

void b_resize(){
  inputTemp = "";
  deactivateButton(pauseBID);
  state = State.RESIZE;
}

void b_pause(){
  Button pauseButton = buttons.get(pauseBID);
  pauseButton.text = "Resume";
  state = State.PAUSED;
}

void b_color(){ // "state" does not change
  int i;
  for(i = 0; i < schemes.size(); i++){
    if(schemes.get(i).name.equals(activeScheme.name)) break;
  }
  Scheme newScheme;
  if(i == schemes.size() - 1) newScheme = schemes.get(0);
  else newScheme = schemes.get(i+1);
  colorSchemeName = newScheme.name;
  findButton(colorBID).subtext = colorSchemeName;
  activeScheme = newScheme;
  saveDefaults(); // update defaults.json with new colorSchemeName
}
