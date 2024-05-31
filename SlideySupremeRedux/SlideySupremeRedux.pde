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

int m = 4; // x-length
int n = 4; // y-length
int mn = m*n;

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


void initBoard(){
  board = new int[n][m];
  // ensures there is some room between the board and the screen.
  boardStart = new Coord(height/30, width/30);
  tileSize = 72; // hard-coded, change later?
  numSize = 50; // hard-coded, change later?
  boardEnd = new Coord(boardStart.x + m*tileSize, boardStart.y + n*tileSize);
}

// TODO: make countInversions()

void shuffleBoard(){
  int i, j;
  IntList nums = new IntList();
  int inversions; // solvable shuffles have an even number of inversions
  int iEmpty = 0;
  int jEmpty = 0; 
  boolean valid;
  
  // populate nums
  for(i = 1; i <= mn; i++){
    nums.append(i);
  }
  // shuffle until valid
  do {
    nums.shuffle();
    // count inversions
    inversions = 0;
    for(i = 1; i < mn; i++){
      if(nums.get(i) == mn){
        iEmpty = i%m;
        jEmpty = i/n;
        continue;
      }
      if(nums.get(i-1) > nums.get(i)) inversions++;
    }
    
    // determine if shuffle is valid
    if(m % 2 != n % 2){ // parities of n and m do not match
      valid = (inversions % 2) != ((m - jEmpty + n - iEmpty) % 2);
    } else if(n % 2 == 0) { // both n and m are even
      valid = (inversions % 2) == ((m - jEmpty + n - iEmpty) % 2);
    } else { // both n and m are odd
      valid = (inversions % 2 != 0);
    }
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
       if(board[iBoard][jBoard] != mn){ // regular tile
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
  if(i-1 >= 0 && board[i-1][j] == mn){
    board[i-1][j] = board[i][j];
    board[i][j] = mn;
    return;
  }
  // if empty tile is DOWN
  if(i+1 < n && board[i+1][j] == mn){
    board[i+1][j] = board[i][j];
    board[i][j] = mn;
    return;
  }
  // if empty tile is LEFT
  if(j-1 >= 0 && board[i][j-1] == mn){
    board[i][j-1] = board[i][j];
    board[i][j] = mn;
    return;
  }
  // if empty tile is RIGHT
  if(j+1 < m && board[i][j+1] == mn){
    board[i][j+1] = board[i][j];
    board[i][j] = mn;
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
