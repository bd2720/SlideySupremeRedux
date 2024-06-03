/*
  Board.pde: contains code to init, shuffle, and display board.
  Also contains moveTile() which uses mouse input to move a tile.
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


int mn = m*n;
int nm = mn;

/*
  board is stored n x m.
  mn represents the empty tile.
*/

int board[][];
//IntList boardNums; // same as board, but a 1D list
// to be initialized by initBoard()
Coord boardStart; // coordinates of board's start (top left)
Coord boardEnd; // coordinates of board's end (bottom right)
int tileSize; // dimension of square tiles
int numSize; // font size of numbers on tiles

int moves; // number of moves taken
int inversions; // number of (a, b) where a appears before b and a > b

void initBoard(){
  board = new int[n][m];
  // ensures there is some room between the board and the screen.
  boardStart = new Coord(20, 20);
  tileSize = min(height/n - 10, (width/2)/m); 
  numSize = 9*tileSize/10;
  boardEnd = new Coord(boardStart.x + m*tileSize, boardStart.y + n*tileSize);
  
  moves = 0;
  
  //boardNums = new IntList();
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

// uses board[n][m]
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
        iEmpty = i/m;
        jEmpty = i%m;
        break;
      }
    }
    
    // determine if shuffle is valid
    valid = (inversions % 2) == ((m - jEmpty + n - iEmpty) % 2);
    //valid = (inversions % 2 == 0);
  } while(!valid);
  
  // copy nums to board
  for(i = 0; i < n; i++){
    for(j = 0; j < m; j++){
      board[i][j] = nums.get(i*m + j);
    }
  }
  //boardNums = nums.copy();
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
    
    //boardNums.set(i*m + j, mn);
    //boardNums.set((i-1)*m + j, board[i-1][j]);
    return true;
  }
  // if empty tile is DOWN
  if(i+1 < n && board[i+1][j] == mn){
    board[i+1][j] = board[i][j];
    board[i][j] = mn;
    moves++;
    
    //boardNums.set(i*m + j, mn);
    //boardNums.set((i+1)*m + j, board[i+1][j]);
    return true;
  }
  // if empty tile is LEFT
  if(j-1 >= 0 && board[i][j-1] == mn){
    board[i][j-1] = board[i][j];
    board[i][j] = mn;
    moves++;
    
    //boardNums.set(i*m + j, mn);
    //boardNums.set(i*m + j-1, board[i][j-1]);
    return true;
  }
  // if empty tile is RIGHT
  if(j+1 < m && board[i][j+1] == mn){
    board[i][j+1] = board[i][j];
    board[i][j] = mn;
    moves++;
    
    //boardNums.set(i*m + j, mn);
    //boardNums.set(i*m + j+1, board[i][j+1]);
    return true;
  }
  return false;
}
