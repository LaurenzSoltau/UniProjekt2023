//Original by Udo Frese
//
//Try to exit the program by closing the window instead of clicking the "stop" button. That will save your current open map for the next session.
//This currently stores the absolute path of your Map so sharing the usersettings between systems will break this connection.
//Starting the program and reopening the desired map will reestablish the connection for the current system if the window is closed again.

import java.io.*;
// Filename of the map currently edited
// If you insert a filename here it will be automatically loaded upon startup
// Maybe you need to use \\ (not \) instead of / for Windows?
String mapname="../gamedemo/data/demo.map";
// The map currently edited
Map map;


// x and y index of the block shown at 0,0 on the screen
int leftBlock, topBlock;
// current level element
int cursorX, cursorY;
//is tilemenu drawn?
boolean drawTileMenu = false;
boolean twoPages = false;
TileIcon[] pageOne = new TileIcon[13];
TileIcon[] pageTwo = new TileIcon[13];
int page = 0;

void openMap (String newMapName)
{
  mapname = newMapName;
  Map newMap=null;
  if (mapname!=null && !mapname.equals("")) newMap = new Map(mapname);
  if (newMap!=null) {
    map = newMap;
    leftBlock = topBlock = cursorX  = cursorY = 0;
  }
}

void openMapCallback(File newMapName)
{
  if (newMapName==null) return;
  openMap (newMapName.getAbsolutePath());
}
// opens a new map with a file input dialog
void openMap() {
  selectInput ("Open block-level map file", "openMapCallback");
}

// saves the current map into a new file
void saveAsMap() {
  selectOutput ("Save block-level map file as", "saveMapAsCallback");
}

void saveMapAsCallback (File newMapname) {
  if (newMapname==null) return;
  mapname=newMapname.getAbsolutePath();
  if (mapname!=null) map.saveFile (mapname);
}

// saves the current map to the current file
void saveMap () {
  if (mapname==null) saveAsMap();
  else map.saveFile (mapname);
}

void newMapCallback (File newMapname) {
  if (newMapname==null) return;
  mapname = newMapname.getAbsolutePath();
  if (mapname==null || mapname.equals("")) exit();
  else {
    String[] emptyMapAsStrings = {
      "_"
    };
    saveStrings (mapname, emptyMapAsStrings);
    map = new Map (mapname);
  }
}

void newMap() {
  selectOutput ("Save new block-level map file as", "newMapCallback");
}

void setup()
{
  size( 1024, 800 );
  String[] settings = loadStrings("usersettings/lastMap.set");
  if (settings != null) mapname = settings[0];
  else println("Could not find last loaded map. Trying to load default demo map.");
  openMap (mapname);

  int counter = 0;
  for (int i = 0; i < map.images.length; i++) {
    if (map.images[i] != null) {
      if (counter < 13) {
        pageOne[counter++] =  new TileIcon(map.images[i], char(i + 'A'));
      } else {
        pageTwo[counter++ % 13] =  new TileIcon(map.images[i], char(i + 'A'));
      }
    }
  }
  if (counter > 13)
    twoPages = true;
  else
    twoPages = false;
}

void mousePressed() {
  if (twoPages && drawTileMenu && mouseY > height - 130) {
    if (page == 0 && mouseX > width-30) page = 1;
    else if (page == 1 && mouseX < 30) page = 0;
  }
}

void keyPressed () {
  if (key==14) newMap(); // CTRL-N
  else if (key==15) openMap(); // CTRL-O
  if (map!=null) {
    if (keyCode==LEFT) cursorX--;
    else if (keyCode==RIGHT) cursorX++;
    else if (keyCode==UP) cursorY--;
    else if (keyCode==DOWN) cursorY++;
    else if (key==' ' || key=='_' || ('A'<=key && key<='Z')) map.set (cursorX, cursorY, key);
    else if ('a'<=key && key<='z') map.set (cursorX, cursorY, char('A'+(key-'a')));
    else if (key==19) saveMap(); // CTRL-S
    else if (key==1) saveAsMap(); // CTRL-A
    else if (key==20) drawTileMenu = !drawTileMenu; // CTRL-T
    //else println ("key="+key+" "+int(key));

    // No negative indices
    if (cursorX<0) cursorX=0;
    if (cursorY<0) cursorY=0;

    // Scroll with cursor
    int scrollStep = ceil((130 + map.tileSize) / map.tileSize) + 1;
    if (cursorX-scrollStep<leftBlock) leftBlock=cursorX-scrollStep;
    if (cursorX-width/map.tileSize+scrollStep>leftBlock) leftBlock=cursorX-width/map.tileSize+scrollStep;
    if (cursorY-scrollStep<topBlock) topBlock=cursorY-scrollStep;
    if (cursorY-height/map.tileSize+scrollStep>topBlock) topBlock=cursorY-height/map.tileSize+scrollStep;

    if (leftBlock<0) leftBlock=0;
    if (topBlock<0) topBlock=0;
  }
}

void drawCursor () {
  stroke (255);
  strokeWeight(3);
  fill (0, 0, 0, 50);
  if (map!=null) rect ((cursorX-leftBlock)*map.tileSize, (cursorY-topBlock)*map.tileSize, map.tileSize, map.tileSize);
}

void drawTextInfo () {
  fill(200);
  noStroke();
  rect(0, height-30, width, 30);

  fill(255);
  textSize(10);
  textAlign(LEFT, BOTTOM);
  if (!drawTileMenu) text("Current Map: " + mapname, 10, height-30);

  fill (0);
  textSize (18);
  textAlign (LEFT, CENTER);
  if (map!=null)
    text("New = CTRL-N | Open = CTRL-O | Save = CTRL-S | Save as = CTRL-A | Delete Tile = SPACE               ("+cursorX+"/"+cursorY+") ["+map.at(cursorX, cursorY)+"]", 10, height-18);
  else
    text("New CTRL-N   Open CTRL-O", 10, height-18);

  textAlign (RIGHT, CENTER);
  text("Toggle Tile-Menu = CTRL-T", width-10, height-18);
}

void drawTileMenu() {
  stroke (255);
  fill (0, 0, 0, 140);
  float m = 30;
  float h = 100;
  float iconW = 40;
  float iM = (width - 13 * iconW - 2*m) / 14;
  rect(m, height - (h + m), width - (2*m), h);

  TileIcon[] p = page == 0 ? pageOne : pageTwo;

  for (int i = 0; i < p.length; i++) {
    if (p[i] == null) break;
    PImage tile = p[i].img;
    char letter = p[i].letter;

    imageMode(CORNER);
    image(tile, m+iM+i*(iM + iconW), height - (h + m - iM/2), iconW, iconW);

    fill(255);
    textAlign(CENTER, BOTTOM);
    textSize(20);
    text(letter, m+iM+i*(iM + iconW) + iconW/2, height - (m + iM/2 - 5));
  }

  if (twoPages) {
    float xs = m-20;
    if (page == 0) xs = width - m;
    fill(0, 0, 0, 128);
    stroke(255);
    rect(xs, height-m-h/2-15, 20, 30);
  }
}

void exit() {
  saveStrings("usersettings/lastMap.set", new String[]{mapname});
  println("Saved currently open map for next session");
  super.exit();
}

void draw () {
  background (180);
  // Draw lines:
  if (map != null) {
    stroke(200);
    strokeWeight(1);
    float x = map.tileSize;
    while(x < width) {
      line(x, 0, x, height);
      x += map.tileSize;
    }
    float y = map.tileSize;
    while(y < height) {
      line(0, y, width, y);
      y += map.tileSize;
    }
  }
  // Draw the map
  if (map!=null)
    map.draw (-leftBlock*map.tileSize, -topBlock*map.tileSize);
  drawTextInfo();
  drawCursor ();
  if (drawTileMenu) drawTileMenu();
}

class TileIcon {
  TileIcon(PImage i, char l) {
    img = i;
    letter = l;
  }

  public PImage img;
  public char letter;
}
