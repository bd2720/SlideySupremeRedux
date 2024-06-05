/*
   Button.pde: Outlines the Button class, and buttons ArrayList.
   Inits, polls, and draws buttons.
*/

class Button {
  int id;
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
  }
}

ArrayList<Button> buttons;

// called during setup()
void initButtons(){
  buttons = new ArrayList<Button>();
  buttons.add(new Button(0, "Reset", height/12, 5*width/8, 5*height/6, width/6, height/8, 'r'));
  buttons.add(new Button(1, "Puzzle\nSize", height/18, 7*width/8, 5*height/6, width/6, height/8, 'c'));
}

// returns true when the button with the given id is pressed
boolean pollButton(int id){
  boolean keyed, clicked;
  Button b = buttons.get(id);
  keyed = keyPressed && key == b.bKey && (!pkeyPressed || pkey != b.bKey);
  clicked = mousePressed && !pmousePressed && (abs(mouseX - b.bX)*2 <= b.bWidth) && (abs(mouseY - b.bY)*2 <= b.bHeight);
  return clicked || keyed;
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
