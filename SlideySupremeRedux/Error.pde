/*
   Error.pde: create error message if JSON object improperly formatted.
   Display error message.
*/

String errorStr;

/* called when a .json is not formatted correctly
   "write" is true if the error occured in a save...() function
*/
void buildJSONError(Exception e, String filename, boolean write){
  // build string
  errorStr = "The following error occurred while ";
  errorStr += write ? "saving \"" : "loading \"";
  errorStr += filename + "\":\n\n";
  String errorMsg = e.toString();
  while(errorMsg.length() > 50){
    errorStr += errorMsg.substring(0, 50) + "\n";
    errorMsg = errorMsg.substring(50);
  }
  errorStr += errorMsg;
  errorStr += "\n\n";
  if(write){
    errorStr += "Ensure this application has sufficient permissions,\n";
    errorStr += "and is located in a place where it can safely write \"";
    errorStr += defaultsFilePath + "\".";
    return;
  }
  errorStr += "Correct the formatting of this JSON structure,\n";
  errorStr += "or delete \"";
  errorStr += filename + "\" so the program can create a new one.";
}

void displayJSONError(){
  textAlign(CENTER, CENTER);
  textSize(width/40);
  fill(activeScheme.text);
  text(errorStr, width/2, height/2);
}

/*  Wrapper functions for load() and save() methods.
    Catches error, builds errorStr, and changes state.
    True if no error, false otherwise
    Meant to be used in setup() and draw() like so:
    if(!load...()) return;
*/
boolean loadDefaultsSafe(){
  try {
    loadDefaults();
    return true;
  } catch(Exception e) {
    activeScheme = new Scheme();
    background(activeScheme.bg);
    // default resolution already hard-coded in size()
    buildJSONError(e, defaultsFileName, false);
    state = State.ERROR;
  }
  return false;
}

boolean saveDefaultsSafe(){
  try {
    saveDefaults();
    return true;
  } catch(Exception e){
    buildJSONError(e, defaultsFileName, true);
    state = State.ERROR;
  }
  return false;
}

boolean loadStatsSafe(){
  try {
    loadStats();
    return true;
  } catch(Exception e){
    buildJSONError(e, scoresFileName, false);
    state = State.ERROR;
  }
  return false;
}

boolean saveStatsSafe(){
  try {
    saveStats();
    return true;
  } catch(Exception e){
    buildJSONError(e, scoresFileName, true);
    state = State.ERROR;
  }
  return false;
}
