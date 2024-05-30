/*
  15-puzzle of arbitrary size (mxn)
  In 2019 I hard-coded a 3x3 version,
  now I'd like to generalize the game.
*/

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

int m = 5; // x-length
int n = 7; // y-length

/*
  board is stored n x m.
  0 represents the empty tile.
*/
int board[][];
// to be initialized by initBoard()
Coord boardStart; // coordinates of board's start (top left)
Coord boardEnd; // coordinates of board's end (bottom right)
int tileSize; // dimension of square tiles
int numSize; // font size of numbers on tiles


void initBoard(){
  board = new int[n][m];
  // ensures there is some room between the board and the screen.
  boardStart = new Coord(height/30, width/30);
  tileSize = 72; // hard-coded, change later?
  numSize = 50; // hard-coded, change later?
  boardEnd = new Coord(boardStart.x + m*tileSize, boardStart.y + n*tileSize);
}

void shuffleBoard(){
  int i, j;
  IntList nums = new IntList();
  for(i = 0; i < m*n; i++){
    nums.append(i);
  }
  nums.shuffle();
  for(i = 0; i < n; i++){
    for(j = 0; j < m; j++){
      board[i][j] = nums.get(i*m + j);
    }
  }
}

void drawBoard(){
  // draw tiles
  stroke(#cfcfcf);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(numSize);
  int i, j, iBoard, jBoard;
  // draw each tile
  iBoard = 0;
  for(i = boardStart.y + tileSize/2; i < boardEnd.y; i += tileSize){
    jBoard = 0;
    for(j = boardStart.x + tileSize/2; j < boardEnd.x; j += tileSize){
       if(board[iBoard][jBoard] != 0){ // regular tile
         fill(#9f9f9f); // tile color
         square(j, i, tileSize);
         fill(#ffffff); // text color
         text(board[iBoard][jBoard], j, i);
       } else { // empty tile: no number, draw lighter
         fill(#cfcfcf);
         square(j, i, tileSize);
       }
       jBoard++;
    }
    iBoard++;
  }
}

void moveTile(){
  if(!mousePressed) return;
  int j = (mouseX - boardStart.x)/tileSize;
  if(j < 0 || j >= m) return;
  int i = (mouseY - boardStart.y)/tileSize;
  if(i < 0 || i >= n) return;
  int temp;
  // if empty tile is UP
  if(i-1 >= 0 && board[i-1][j] == 0){
    board[i-1][j] = board[i][j];
    board[i][j] = 0;
    return;
  }
  // if empty tile is DOWN
  if(i+1 < n && board[i+1][j] == 0){
    board[i+1][j] = board[i][j];
    board[i][j] = 0;
    return;
  }
  // if empty tile is LEFT
  if(j-1 >= 0 && board[i][j-1] == 0){
    board[i][j-1] = board[i][j];
    board[i][j] = 0;
    return;
  }
  // if empty tile is RIGHT
  if(j+1 < m && board[i][j+1] == 0){
    board[i][j+1] = board[i][j];
    board[i][j] = 0;
    return;
  }
}

void setup(){
  size(800, 600);
  initBoard();
  shuffleBoard();
  background(#1f1f1f);
  drawBoard();
}

void draw(){
  moveTile();
  background(#1f1f1f);
  drawBoard();
}
