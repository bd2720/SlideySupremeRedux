/*
    Defaults.pde: Saves and restores previous session's settings
*/

final String defaultsFileName = "defaults.json";
final String defaultsFilePath = "data/" + defaultsFileName;
JSONObject defaults; // stores m, n, colorSchemeName and resolution
int defaultM = 4;
int defaultN = 4;
String defaultColorSchemeName = "DEFAULT";

void loadDefaults(){ // load recent values of m, n, colorSchemeName
  defaults = loadJSONObject(defaultsFileName);
  if(defaults == null){
    m = defaultM;
    n = defaultN;
    colorSchemeName = defaultColorSchemeName;
    // create, fill + save "defaults" object
    defaults = new JSONObject();
    defaults.setInt("m", defaultM);
    defaults.setInt("n", defaultN);
    defaults.setString("colorSchemeName", defaultColorSchemeName);
    saveJSONObject(defaults, defaultsFilePath);
    return;
  }
  m = defaults.getInt("m");
  if(m < minDim || m > maxDim) m = defaultM;
  n = defaults.getInt("n");
  if(n < minDim || n > maxDim) n = defaultN;
  colorSchemeName = defaults.getString("colorSchemeName");
}

void saveDefaults(){ // saves values of m, n, colorSchemeName
  if(defaults == null) defaults = new JSONObject();
  defaults.setInt("m", m);
  defaults.setInt("n", n);
  defaults.setString("colorSchemeName", colorSchemeName);
  saveJSONObject(defaults, defaultsFilePath);
}
