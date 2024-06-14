/*
   Error.pde: create error message if JSON object improperly formatted.
   Display error message.
*/

String errorStr;

// called when a .json is not formatted correctly
void buildJSONError(Exception e, String filename){
  // build string
  errorStr = "The following error occurred while reading \"";
  errorStr += filename + "\":\n\n";
  errorStr += e.toString() + "\n\n";
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
