/*
    Screen.pde: Contains positional screen-related code
    Saves, loads, and manages current screen resolution
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

String resolutionStr = "800x600";
Coord activeResolution;
ArrayList<Coord> resolutions;

void initResolutions(){
  resolutions = new ArrayList<Coord>();
  resolutions.add(new Coord(800, 600)); // 4:3
  resolutions.add(new Coord(1280, 720)); // 16:9
}

void applyResolution(String resolutionStr){
  for(int i = 0; i < resolutions.size(); i++){
    if(resolutionStr.equals(resolutions.get(i).x + "x" + resolutions.get(i).y)){
       activeResolution = resolutions.get(i);
       windowResize(activeResolution.x, activeResolution.y);
       return;
    }
  }
  activeResolution = resolutions.get(0); // apply default
  windowResize(activeResolution.x, activeResolution.y);
}
