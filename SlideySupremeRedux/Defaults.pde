/*
    Defaults.pde: Saves and restores previous session's settings
    Contains default values for customizable settings.
    Should not crash given a valid JSONObject/JSONArray.
*/

final String defaultsFileName = "defaults.json";
final String defaultsFilePath = "data/" + defaultsFileName;
JSONObject defaults; // stores m, n, colorSchemeName and resolution
int defaultM = 4;
int defaultN = 4;
String defaultColorSchemeName = "DEFAULT";
Coord defaultRes = new Coord(800, 600);

/* fills JSONObject "defaults" with default values,
   also initializes globals with default values.
*/
void fillDefaults(){
  m = defaultM;
  n = defaultN;
  colorSchemeName = defaultColorSchemeName;
  resolutionStr = defaultRes.x + "x" + defaultRes.y;
  defaults.setInt("m", defaultM);
  defaults.setInt("n", defaultN);
  defaults.setString("colorSchemeName", defaultColorSchemeName);
  defaults.setInt("res.x", defaultRes.x);
  defaults.setInt("res.y", defaultRes.y);
}

void loadDefaults(){ // load recent values of m, n, colorSchemeName
  defaults = loadJSONObject(sketchPath(defaultsFilePath)); // sketchPath() added, or else macOS won't read
  if(defaults == null){
    defaults = new JSONObject();
    fillDefaults();
    return;
  }
  try {
    m = defaults.getInt("m");
    if(m < minDim || m > maxDim) m = defaultM;
    n = defaults.getInt("n");
    if(n < minDim || n > maxDim) n = defaultN;
    colorSchemeName = defaults.getString("colorSchemeName");
    if(!validateScheme(colorSchemeName)) colorSchemeName = defaultColorSchemeName;
    resolutionStr = defaults.getInt("res.x") + "x" + defaults.getInt("res.y");
    if(!validateResolution(resolutionStr)) resolutionStr = defaultRes.x + "x" + defaultRes.y;
  } catch(Exception e){ // if any of the fields are missing, fill all with defaults
    fillDefaults();
  }
}


void saveDefaults(){ // saves values of m, n, colorSchemeName, resolution
  if(defaults == null) defaults = new JSONObject();
  defaults.setInt("m", m);
  defaults.setInt("n", n);
  defaults.setString("colorSchemeName", colorSchemeName);
  defaults.setInt("res.x", activeResolution.x);
  defaults.setInt("res.y", activeResolution.y);
  saveJSONObject(defaults, defaultsFilePath);
}
