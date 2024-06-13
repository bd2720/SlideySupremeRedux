/*
  Board.pde: contains code to init, shuffle, and display board.
  Also contains moveTile() which uses mouse input to move a tile.
*/

int m; // horizontal board length
int n; // vertical board length
int minDim = 2;
int maxDim = 31;

// useful "constants"
int mn;
int nm;
int mPn;
int nPm;
String mxnStr;

/*
  board is stored n x m.
  mn represents the empty tile.
*/

// to be initialized by initBoard()
int board[][];
Coord boardStart; // coordinates of board's start (top left)
Coord boardEnd; // coordinates of board's end (bottom right)
int tileSize; // dimension of square tiles
int numSize; // font size of numbers on tiles

int moves; // number of moves taken

int iEmpty; // vertical position of the empty tile
int jEmpty; // horizontal position of the empty tile

// called in initBoard and after window is resized
void sizeBoard(){
  int wSize = (width/2)/m;
  int hSize = height/n ;
  tileSize = min(wSize, hSize);
  tileSize = 9*tileSize/10;
  boardStart = new Coord(width/4 - m * tileSize / 2, height/2 - n * tileSize / 2);
  if(mn <= 100) numSize = 9*tileSize/10;
  else numSize = 3*tileSize/5;
  boardEnd = new Coord(boardStart.x + m*tileSize, boardStart.y + n*tileSize);
}

void initBoard(){
  sizeBoard();
  
  mn = m*n;
  nm = mn;
  mPn = m+n;
  nPm = mPn;
  mxnStr = m + "x" + n;
  
  resize_button.subtext = mxnStr;
  
  board = new int[n][m];
  // ensures there is some room between the board and the screen.
  
  
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
  iEmpty = 0;
  jEmpty = 0; 
  boolean valid = false;
  
  // populate nums
  for(i = 1; i <= mn; i++){
    nums.append(i);
  }
  // shuffle until valid
  do {
    // ensure the shuffle is not sorted
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
    valid = ((inversions + iEmpty + jEmpty + mPn) & 1) == 0;
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

// called by moveTile() if WASD is pressed
boolean keyMove(){
  switch(key){
    case 'w':
      if(iEmpty+1 >= n) break;
      board[iEmpty][jEmpty] = board[iEmpty+1][jEmpty];
      board[iEmpty+1][jEmpty] = mn;
      iEmpty++;
      moves++;
      return true;
    case 's':
      if(iEmpty-1 < 0) break;
      board[iEmpty][jEmpty] = board[iEmpty-1][jEmpty];
      board[iEmpty-1][jEmpty] = mn;
      iEmpty--;
      moves++;
      return true;
    case 'a':
      if(jEmpty+1 >= m) break;
      board[iEmpty][jEmpty] = board[iEmpty][jEmpty+1];
      board[iEmpty][jEmpty+1] = mn;
      jEmpty++;
      moves++;
      return true;
    case 'd':
      if(jEmpty-1 < 0) break;
      board[iEmpty][jEmpty] = board[iEmpty][jEmpty-1];
      board[iEmpty][jEmpty-1] = mn;
      jEmpty--;
      moves++;
      return true;
    default:
      break;
  }
  return false;
}

// called by moveTile() if arrow keys are pressed
boolean arrowKeyMove(){
  switch(keyCode){
    case UP:
      if(iEmpty+1 >= n) break;
      board[iEmpty][jEmpty] = board[iEmpty+1][jEmpty];
      board[iEmpty+1][jEmpty] = mn;
      iEmpty++;
      moves++;
      return true;
    case DOWN:
      if(iEmpty-1 < 0) break;
      board[iEmpty][jEmpty] = board[iEmpty-1][jEmpty];
      board[iEmpty-1][jEmpty] = mn;
      iEmpty--;
      moves++;
      return true;
    case LEFT:
      if(jEmpty+1 >= m) break;
      board[iEmpty][jEmpty] = board[iEmpty][jEmpty+1];
      board[iEmpty][jEmpty+1] = mn;
      jEmpty++;
      moves++;
      return true;
    case RIGHT:
      if(jEmpty-1 < 0) break;
      board[iEmpty][jEmpty] = board[iEmpty][jEmpty-1];
      board[iEmpty][jEmpty-1] = mn;
      jEmpty--;
      moves++;
      return true;
    default:
      break;
  }
  return false;
}

boolean moveTile(){
  int i = (mouseY - boardStart.y)/tileSize;
  int j = (mouseX - boardStart.x)/tileSize;
  boolean clicked = mousePressed && j >= 0 && j < m && i >= 0 && i < n;
  if(!clicked){ // mouse input takes priority over key input
    if(!keyPressed) return false;
    if(key != CODED){ // WASD
      if((!pkeyPressed || pkey != key) && (key == 'w' || key == 'a' || key == 's' || key == 'd')){
        return keyMove(); 
      }
    } else { // ARROW KEYS
      if((!pkeyPressed || pkeyCode != keyCode) && (keyCode >= LEFT && keyCode <= DOWN)){
        return arrowKeyMove();
      }
    }
    return false;
  }
  // if empty tile is UP
  if(i-1 >= 0 && board[i-1][j] == mn){
    board[i-1][j] = board[i][j];
    board[i][j] = mn;
    iEmpty = i;
    moves++;
    return true;
  }
  // if empty tile is DOWN
  if(i+1 < n && board[i+1][j] == mn){
    board[i+1][j] = board[i][j];
    board[i][j] = mn;
    iEmpty = i;
    moves++;
    return true;
  }
  // if empty tile is LEFT
  if(j-1 >= 0 && board[i][j-1] == mn){
    board[i][j-1] = board[i][j];
    board[i][j] = mn;
    jEmpty = j;
    moves++;
    return true;
  }
  // if empty tile is RIGHT
  if(j+1 < m && board[i][j+1] == mn){
    board[i][j+1] = board[i][j];
    board[i][j] = mn;
    jEmpty = j;
    moves++;
    return true;
  }
  return false;
}
