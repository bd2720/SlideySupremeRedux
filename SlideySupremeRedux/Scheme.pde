/*
  Scheme.pde: Contains the Scheme class which defines a color scheme.
  Contains functions to init the list of schemes and select a scheme.
  
  Available Schemes:
    DEFAULT : Black and white.
    CLASSIC : Brown board. Color of the original 2019 version "SlideySupreme".
    CLOUDY  : Soft greyscale theme.
    MINT    : Low intensity greens.
    EARTH   : Dark brown, green and blue.
    MAGMA   : Dark and hot colors.
    AUTUMN  : Warm Fall greens, yellows and browns.
*/

String colorSchemeName; // color scheme

// color scheme class
class Scheme {
  String name;
  public color bg;          // background color
  public color board;       // board color (behind tiles), button outline color
  public color tile;        // tile color, button fill color
  public color nums;        // color of numbers on tiles, text on buttons
  public color text;        // text (on bg) color
  public color subtext;     // high score text color (less pronounced)
  Scheme(){
    name = "DEFAULT";
    bg = #000000;
    board = #ffffff;
    tile = #000000;
    nums = #ffffff;
    text = #ffffff;
    subtext = #ffffff;
  }
  Scheme(String name, color bg, color board, color tile, color nums, color text, color subtext){
   this.name = name;
   this.bg = bg;
   this.board = board;
   this.tile = tile;
   this.nums = nums;
   this.text = text;
   this.subtext = subtext;
  }
}

ArrayList<Scheme> schemes; // a list of all color schemes
Scheme activeScheme; // a reference to the chosen color scheme


// initializes a number of default color schemes
void initSchemes(){
  schemes = new ArrayList<Scheme>();
  schemes.add(new Scheme()); // default scheme
  schemes.add(new Scheme("CLASSIC", #000000, #633302, #964b00, #000000, #ffffff, #ffffff)); // 2019 version color
  schemes.add(new Scheme("CLOUDY", #1f1f1f, #cfcfcf, #9f9f9f, #ffffff, #ffffff, #9f9f9f)); // nice soft greyscale
  schemes.add(new Scheme("MINT", #536359, #9bc7ba, #93adac, #defff5, #defff5, #a3c4ba)); // muted greens
  schemes.add(new Scheme("EARTH", #4a382c, #5e788f, #405669, #819cb5, #afc4a5, #708267)); // blue, green and brown
  schemes.add(new Scheme("MAGMA", #141313, #6e1904, #c74204, #000000, #ffaa4f, #b89469)); // dark and hot colors
  schemes.add(new Scheme("AUTUMN", #772f1a, #f58549, #0f0f0f, #eec170, #eec170, #877c36));
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

// checks if a color scheme with the given name exists
boolean validateScheme(String schemeName){
 for(int i = 0; i < schemes.size(); i++){
   if((schemes.get(i).name).equals(schemeName)) return true;
 }
 return false;
}
