/*
  Board.pde: contains code to init, shuffle, and display board.
  Also contains moveTile() which uses mouse input to move a tile.
*/

int m; // horizontal board length
int n; // vertical board length
int minDim = 2;
int maxDim = 31;
int maxDimLog = String.valueOf(maxDim).length(); // number of digits in maxDim
String mxnStr; // "m" + "n"

/*
  board is stored n x m.
  m*n represents the empty tile.
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

// Up, Down, Left, Right, None
enum Move {
  NONE(0),
  U(1),
  D(2),
  L(3),
  R(4);
  private int val;
  private Move(int v){
    this.val = v; 
  }
  public int toInt(){
    return this.val; 
  }
}

// called in initBoard and after window is resized
void sizeBoard(){
  int wSize = (width/2)/m;
  int hSize = height/n;
  tileSize = min(wSize, hSize);
  tileSize = 9*tileSize/10;
  boardStart = new Coord(width/4 - m * tileSize / 2, height/2 - n * tileSize / 2);
  if(m*n > 100) numSize = 3*tileSize/5;
  else numSize = 9*tileSize/10;
  boardEnd = new Coord(boardStart.x + m*tileSize, boardStart.y + n*tileSize);
}

void initBoard(){
  mxnStr = m + "x" + n;
  sizeBoard();
  resize_button.subtext = mxnStr;
  board = new int[n][m];
  moves = 0;
}

int countInversions(IntList nums){
  int inversions = 0;
  for(int i = 0; i < nums.size(); i++){
    //if(nums.get(i) == m*n) continue;
    for(int j = i+1; j < nums.size(); j++){
      //if(nums.get(j) == m*n) continue;
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
  boolean valid;
  
  // populate nums
  for(i = 1; i <= m*n; i++){
    nums.append(i);
  }
  // shuffle until valid
  do {
    // ensure the shuffle is not sorted
    do {
      nums.shuffle();
      valid = false;
      for(i = 0; i < m*n; i++){
        if(nums.get(i) != i+1){
          valid = true;
          break;
        }
      }
    } while(!valid); // shuffle again if sorted
    
    // count inversions
    inversions = countInversions(nums);
    // locate empty tile
    for(i = 0; i < m*n; i++){
      if(nums.get(i) == m*n){
        iEmpty = i/m;
        jEmpty = i%m;
        break;
      }
    }
    
    // determine if shuffle is valid
  } while(((inversions + iEmpty + jEmpty + (m+n)) & 1) != 0);
  
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
       if(board[iBoard][jBoard] != m*n){ // regular tile
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
Move keyMove(){
  switch(key){
    case 'w':
      if(iEmpty+1 >= n) break;
      board[iEmpty][jEmpty] = board[iEmpty+1][jEmpty];
      board[iEmpty+1][jEmpty] = m*n;
      iEmpty++;
      moves++;
      return Move.U;
    case 's':
      if(iEmpty-1 < 0) break;
      board[iEmpty][jEmpty] = board[iEmpty-1][jEmpty];
      board[iEmpty-1][jEmpty] = m*n;
      iEmpty--;
      moves++;
      return Move.D;
    case 'a':
      if(jEmpty+1 >= m) break;
      board[iEmpty][jEmpty] = board[iEmpty][jEmpty+1];
      board[iEmpty][jEmpty+1] = m*n;
      jEmpty++;
      moves++;
      return Move.L;
    case 'd':
      if(jEmpty-1 < 0) break;
      board[iEmpty][jEmpty] = board[iEmpty][jEmpty-1];
      board[iEmpty][jEmpty-1] = m*n;
      jEmpty--;
      moves++;
      return Move.R;
    default:
      break;
  }
  return Move.NONE;
}

// called by moveTile() if arrow keys are pressed
Move arrowKeyMove(){
  switch(keyCode){
    case UP:
      if(iEmpty+1 >= n) break;
      board[iEmpty][jEmpty] = board[iEmpty+1][jEmpty];
      board[iEmpty+1][jEmpty] = m*n;
      iEmpty++;
      moves++;
      return Move.U;
    case DOWN:
      if(iEmpty-1 < 0) break;
      board[iEmpty][jEmpty] = board[iEmpty-1][jEmpty];
      board[iEmpty-1][jEmpty] = m*n;
      iEmpty--;
      moves++;
      return Move.D;
    case LEFT:
      if(jEmpty+1 >= m) break;
      board[iEmpty][jEmpty] = board[iEmpty][jEmpty+1];
      board[iEmpty][jEmpty+1] = m*n;
      jEmpty++;
      moves++;
      return Move.L;
    case RIGHT:
      if(jEmpty-1 < 0) break;
      board[iEmpty][jEmpty] = board[iEmpty][jEmpty-1];
      board[iEmpty][jEmpty-1] = m*n;
      jEmpty--;
      moves++;
      return Move.R;
    default:
      break;
  }
  return Move.NONE;
}

Move moveTile(){
  // fixed integer division error
  int i = Math.floorDiv((mouseY - boardStart.y), tileSize);
  int j = Math.floorDiv((mouseX - boardStart.x), tileSize);
  boolean clicked = mousePressed && j >= 0 && j < m && i >= 0 && i < n;
  if(!clicked){ // mouse input takes priority over key input
    if(!keyPressed) return Move.NONE;
    if(key != CODED){ // WASD
      if((!pkeyPressed || pkey != key) && (key == 'w' || key == 'a' || key == 's' || key == 'd')){
        return keyMove(); 
      }
    } else { // ARROW KEYS
      if((!pkeyPressed || pkeyCode != keyCode) && (keyCode >= LEFT && keyCode <= DOWN)){
        return arrowKeyMove();
      }
    }
    return Move.NONE;
  }
  // if empty tile is UP
  if(i-1 >= 0 && board[i-1][j] == m*n){
    board[i-1][j] = board[i][j];
    board[i][j] = m*n;
    iEmpty = i;
    moves++;
    return Move.U;
  }
  // if empty tile is DOWN
  if(i+1 < n && board[i+1][j] == m*n){
    board[i+1][j] = board[i][j];
    board[i][j] = m*n;
    iEmpty = i;
    moves++;
    return Move.D;
  }
  // if empty tile is LEFT
  if(j-1 >= 0 && board[i][j-1] == m*n){
    board[i][j-1] = board[i][j];
    board[i][j] = m*n;
    jEmpty = j;
    moves++;
    return Move.L;
  }
  // if empty tile is RIGHT
  if(j+1 < m && board[i][j+1] == m*n){
    board[i][j+1] = board[i][j];
    board[i][j] = m*n;
    jEmpty = j;
    moves++;
    return Move.R;
  }
  return Move.NONE;
}
