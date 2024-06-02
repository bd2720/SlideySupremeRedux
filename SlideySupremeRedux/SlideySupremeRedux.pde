/*
  15-puzzle of arbitrary size (mxn)
  Successor to my hard-coded 3x3 version from 2019
*/

// 2D coordinate class
class Coord {
  public int x;
  public int y;
  Coord(){
   x = y = 0; 
  }
  Coord(int x, int y){
    this.x = x;
    this.y = y;
  }
}

// color scheme class
class Scheme {
  String name;
  public color bg;          // background color
  public color board;       // board color (behind tiles)
  public color tile;        // tile color
  public color nums;        // color of numbers on tiles
  public color text;        // text color
  Scheme(){
    name = "DEFAULT";
    bg = #000000;
    board = #ffffff;
    tile = #000000;
    nums = #ffffff;
    text = #ffffff;
  }
  Scheme(String n, color b, color p, color s, color x, color t){
   name = n;
   bg = b;
   board = p;
   tile = s;
   nums = x;
   text = t;
  }
}

//  *** CUSTOMIZABLE OPTIONS ***
int m = 3; // horizontal board length
int n = 3; // vertical board length
String colorSchemeName = "CLOUDY"; // color scheme (look at initSchemes for a list)

int mn = m*n;
int nm = mn;

/*
  board is stored n x m.
  mn represents the empty tile.
*/
int board[][];
// to be initialized by initBoard()
Coord boardStart; // coordinates of board's start (top left)
Coord boardEnd; // coordinates of board's end (bottom right)
int tileSize; // dimension of square tiles
int numSize; // font size of numbers on tiles

boolean solved; // true when puzzle is solved. halts gameplay
int moves; // number of moves taken
long tStart;
long tElapsed;

enum State { INIT, PLAY, SOLVED }
State state; // initialized in setup()

ArrayList<Scheme> schemes; // a list of all color schemes
Scheme activeScheme; // a reference to the chosen color scheme


// initializes a number of default color schemes
void initSchemes(){
  schemes = new ArrayList<Scheme>();
  schemes.add(new Scheme()); // default scheme, black and white
  schemes.add(new Scheme("CLASSIC", #000000, #633302, #964b00, #000000, #ffffff)); // 2019 version color
  schemes.add(new Scheme("CLOUDY", #1f1f1f, #cfcfcf, #9f9f9f, #ffffff, #ffffff)); // nice soft greyscale
}

/*
  Sets activeScheme based on schemeName.
  If a scheme with schemeName is not found, DEFAULT is used.
*/
void applyScheme(String schemeName){
  for(int i = 0; i < schemes.size(); i++){
    if((schemes.get(i).name).equals(schemeName)){
       activeScheme = schemes.get(i);
       return;
    }
  }
  activeScheme = new Scheme(); // apply default
}

void initBoard(){
  board = new int[n][m];
  // ensures there is some room between the board and the screen.
  boardStart = new Coord(20, 20);
  tileSize = min(height/n - 10, (width/2)/m); 
  numSize = 9*tileSize/10;
  boardEnd = new Coord(boardStart.x + m*tileSize, boardStart.y + n*tileSize);
  
  moves = 0;
}

int countInversions(IntList nums){
  int inversions = 0;
  for(int i = 0; i < nums.size(); i++){
    //if(nums.get(i) == mn) continue;
    for(int j = i+1; j < nums.size(); j++){
      //if(nums.get(j) == mn) continue;
      if(nums.get(i) > nums.get(j)) inversions++;
    }
  }
  return inversions;
}

boolean isSolved(){
  int num = 0;
  for(int i = 0; i < n; i++){
    for(int j = 0; j < m; j++){
      if(board[i][j] < num) return false;
      num = board[i][j];
    }
  }
  return true;
}

void shuffleBoard(){
  int i, j;
  IntList nums = new IntList();
  int inversions;
  int iEmpty = 0;
  int jEmpty = 0; 
  boolean valid = false;
  
  // populate nums
  for(i = 1; i <= mn; i++){
    nums.append(i);
  }
  // shuffle until valid
  do {
    do {
      nums.shuffle();
      for(i = 0; i < mn; i++){
        if(nums.get(i) != i+1){
          valid = true;
          break;
        }
      }
    } while(!valid); // shuffle again if sorted
    // count inversions
    inversions = countInversions(nums);
    // locate empty tile
    for(i = 0; i < mn; i++){
      if(nums.get(i) == mn){
        iEmpty = i/n;
        jEmpty = i%m;
        break;
      }
    }
    
    // determine if shuffle is valid
    valid = (inversions % 2) == ((m - jEmpty + n - iEmpty) % 2);
  } while(!valid);
  
  // copy nums to board
  for(i = 0; i < n; i++){
    for(j = 0; j < m; j++){
      board[i][j] = nums.get(i*m + j);
    }
  }
}

void drawBoard(){
  // draw tiles
  stroke(activeScheme.board);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(numSize);
  int i, j, iBoard, jBoard;
  // draw each tile
  iBoard = 0;
  for(i = boardStart.y + tileSize/2; i < boardEnd.y; i += tileSize){
    jBoard = 0;
    for(j = boardStart.x + tileSize/2; j < boardEnd.x; j += tileSize){
       if(board[iBoard][jBoard] != mn){ // regular tile
         fill(activeScheme.tile); // tile color
         square(j, i, tileSize);
         fill(activeScheme.nums); // number color
         text(board[iBoard][jBoard], j, i);
       } else { // empty tile: no number, draw lighter
         fill(activeScheme.board);
         square(j, i, tileSize);
       }
       jBoard++;
    }
    iBoard++;
  }
}

boolean moveTile(){
  if(!mousePressed) return false;
  int j = (mouseX - boardStart.x)/tileSize;
  if(j < 0 || j >= m) return false;
  int i = (mouseY - boardStart.y)/tileSize;
  if(i < 0 || i >= n) return false;
  int temp;
  // if empty tile is UP
  if(i-1 >= 0 && board[i-1][j] == mn){
    board[i-1][j] = board[i][j];
    board[i][j] = mn;
    moves++;
    return true;
  }
  // if empty tile is DOWN
  if(i+1 < n && board[i+1][j] == mn){
    board[i+1][j] = board[i][j];
    board[i][j] = mn;
    moves++;
    return true;
  }
  // if empty tile is LEFT
  if(j-1 >= 0 && board[i][j-1] == mn){
    board[i][j-1] = board[i][j];
    board[i][j] = mn;
    moves++;
    return true;
  }
  // if empty tile is RIGHT
  if(j+1 < m && board[i][j+1] == mn){
    board[i][j+1] = board[i][j];
    board[i][j] = mn;
    moves++;
    return true;
  }
  return false;
}

// display text for moves and timer
void displayStatText(){
  textSize(40);
  textAlign(RIGHT);
  fill(activeScheme.text);
  text("Time: ", 3*width/4 - 20, height/8);
  text("Moves: ", 3*width/4 - 20, height/4);
  textAlign(LEFT);
  // build time string from tElapsed
  long msec = tElapsed % 1000;
  long sec = (tElapsed / 1000) % 60;
  long min = (tElapsed / 60000) % 60;
  long hour = tElapsed / 3600000;
  String timeStr;
  if(tElapsed < 60000){
    timeStr = sec + "." + String.format("%03d", msec);
  } else if(tElapsed < 3600000) {
    timeStr = min + ":" + String.format("%02d", sec) + "." + String.format("%03d", msec);
  } else {
    timeStr = hour + ":" + String.format("%02d", min) + ":" + String.format("%02d", sec) + "." + String.format("%03d", msec);
  }
  text(timeStr, 3*width/4 - 20, height/8);
  text(moves, 3*width/4 - 20, height/4);
}

void displayWinText(){
  textSize(60);
  textAlign(CENTER);
  fill(activeScheme.text);
  text("You Did It!", 3*width/4 - 20, 2*height/3);
}

void setup(){
  size(800, 600);
  state = State.INIT;
  initSchemes();
  applyScheme(colorSchemeName);
  initBoard();
  shuffleBoard();
  background(activeScheme.bg);
  drawBoard();
  displayStatText(); // timer and moves
}

void draw(){
  switch(state){
    case INIT: // before the first move
      if(moveTile()){ // transition to PLAY
         tStart = System.currentTimeMillis();
         state = State.PLAY;
      } else {
        background(activeScheme.bg);
        drawBoard();
        displayStatText();
      }
    break;
    case PLAY: // after the first move, before solve
    tElapsed = System.currentTimeMillis() - tStart;
    // tElapsed *= 600; // time multiplier (debug)
    if(isSolved()){
      state = State.SOLVED;
    } else {
      moveTile();
      background(activeScheme.bg);
      drawBoard();
      displayStatText();
    }
    break;
    case SOLVED:
      background(activeScheme.bg);
      drawBoard();
      displayStatText();
      displayWinText();
    break;
  }
}
