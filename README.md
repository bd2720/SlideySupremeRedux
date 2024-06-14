# SlideySupremeRedux -- V1.1.1 #  
A 2D 15-puzzle of "arbitrary" width and height.  
Successor to my hard-coded 3x3 version from 2019.  
Created with the Processing sketchbook (Java Mode).  
  
Runs in 1280x720 or 800x600 @ 60fps.  
Designed for 16:9 and 4:3 aspect ratios.  
Supports key controls, but mouse is recommended.  
  
Minimum puzzle size is 2x2, maximum is 31x31.  
Settings and high scores save across playthroughs.  
Please enjoy, and feel free to suggest changes!  
  
You can safely ignore console messages about missing JSON files; SSR will create them as needed.  
The default Windows version contains Java, so it's big (>200MB).  
If you already have OpenJDK installed on Windows, download the "nojava" version.  
On Linux, you may need to run "chmod +x SlideySupremeRedux", and/or adjust the window size.  
  
***KEYBOARD CONTROLS***  
W / UP : Move a tile up to fill the empty square.  
A / LEFT: Move a tile left to fill the empty square.  
S / DOWN: Move a tile down to fill the empty square.  
D / RIGHT: Move a tile right to fill the empty square.  
P : Pause/Unpause the timer.  
R : Re-shuffle the board, resetting the timer and moves counter.  
X : Change the size of the puzzle (enter "*width* x *height*").  
C : Cycle the game's color scheme.  
M : Resize the game window.  
I : Display info about the game.  
ESCAPE : Exit the game.  
  
***COLOR SCHEMES***  
    DEFAULT : Black and white.  
    CLASSIC : Brown board. Color of the original version.  
    CLOUDY  : Soft greyscale theme.  
    MINT    : Low intensity greens.  
    EARTH   : Dark brown, green and blue.  
