/*
  Scheme.pde: Contains the Scheme class which defines a color scheme.
  Contains functions to init the list of schemes and select a scheme.
  
  Available Schemes:
    DEFAULT : Black and white.
    CLASSIC : Brown board. Color of the original 2019 version "SlideySupreme".
    CLOUDY  : Soft greyscale theme.
*/

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

ArrayList<Scheme> schemes; // a list of all color schemes
Scheme activeScheme; // a reference to the chosen color scheme


// initializes a number of default color schemes
void initSchemes(){
  schemes = new ArrayList<Scheme>();
  schemes.add(new Scheme()); // default scheme
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
