Map map;
// Position of player center in level coordinates
float playerX, playerY;
// Velocity of player
float playerVX, playerVY;
// Speed at which the player moves
float playerSpeed = 150;
// The player is a circle and this is its radius
float playerR = 10;
// Position of the goal center
// Will be set by restart
float goalX=0, goalY=0;
// Whether to illustrate special functions of class Map
boolean showSpecialFunctions=false;

// left / top border of the screen in map coordinates
// used for scrolling
float screenLeftX, screenTopY;
//light beam around player
float brightness = 100;

float time;
int GAMEWAIT=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3;
int gameState;

PImage backgroundImg;

void setup() {
  size( 500, 500 );
  newGame ();
}

void newGame () {
  map = new Map( "demo.map");
  for ( int x = 0; x < map.w; ++x ) {
    for ( int y = 0; y < map.h; ++y ) {
      // put player at 'S' tile and replace with 'F'
      if ( map.at(x, y) == 'S' ) {
        playerX = map.centerXOfTile (x);
        playerY = map.centerYOfTile (y);
        map.set(x, y, 'F');
      }
      // put goal at 'E' tile
      if ( map.at(x, y) == 'E' ) {
        goalX = map.centerXOfTile (x);
        goalY = map.centerYOfTile (y);
      }
    }
  }
  time=0;
  playerVX = 0;
  playerVY = 0;
  gameState = GAMEWAIT;
}

void keyPressed() {
  if ( keyCode == UP) {
    playerVY = -playerSpeed;
    playerVX = 0;
  } else if ( keyCode == DOWN) {
    playerVY = playerSpeed;
    playerVX = 0;
  } else if ( keyCode == LEFT) {
    playerVX = -playerSpeed;
    playerVY = 0;
  } else if ( keyCode == RIGHT) {
    playerVX = playerSpeed;
    playerVY = 0;
  } else if ( keyCode == 'S' ) showSpecialFunctions = !showSpecialFunctions;
}


void updatePlayer() {
  // update player
  float nextX = playerX + playerVX/frameRate,
    nextY = playerY + playerVY/frameRate;
  if ( map.testTileInRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "W" ) ) {
    playerVX = 0;
    playerVY = 0;
    nextX = playerX;
    nextY = playerY;
  }
  if ( map.testTileFullyInsideRect (nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "H_" ) ) {
    gameState=GAMEOVER;
  }
  if ( map.testTileFullyInsideRect (nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "E" ) ) {
    gameState=GAMEWON;
  }

  playerX = nextX;
  playerY = nextY;
}

// Maps x to an output y = map(x,xRef,yRef,factor), such that
//     - x0 is mapped to y0
//     - increasing x by 1 increases y by factor
float map (float x, float xRef, float yRef, float factor) {
  return factor*(x-xRef)+yRef;
}

void drawMap() {
  // The left border of the screen is at screenLeftX in map coordinates
  // so we draw the left border of the map at -screenLeftX in screen coordinates
  // Same for screenTopY.
  map.draw( -screenLeftX, -screenTopY );
}


void drawPlayer() {
  // draw player
  noStroke();
  fill(0, 255, 255);
  ellipseMode(CENTER);
  ellipse( playerX - screenLeftX, playerY - screenTopY, 2*playerR, 2*playerR );

  // understanding this is optional, skip at first sight
  if (showSpecialFunctions) {
    // draw a line to the next hole
    Map.TileReference nextHole = map.findClosestTileInRect (playerX-100, playerY-100, 200, 200, "H");
    stroke(255, 0, 255);
    if (nextHole!=null) line (playerX-screenLeftX, playerY-screenTopY,
      nextHole.centerX-screenLeftX, nextHole.centerY-screenTopY);

    // draw line of sight to goal (until next wall) (understanding this is optional)
    stroke(0, 255, 255);
    Map.TileReference nextWall = map.findTileOnLine (playerX, playerY, goalX, goalY, "W");
    if (nextWall!=null)
      line (playerX-screenLeftX, playerY-screenTopY, nextWall.xPixel-screenLeftX, nextWall.yPixel-screenTopY);
    else
      line (playerX-screenLeftX, playerY-screenTopY, goalX-screenLeftX, goalY-screenTopY);
  }
}


void drawText() {
  textAlign(CENTER, CENTER);
  fill(0, 255, 0);
  textSize(40);
  if (gameState==GAMEWAIT) text ("press space to start", width/2, height/2);
  else if (gameState==GAMEOVER) text ("game over", width/2, height/2);
  else if (gameState==GAMEWON) text ("won in "+ round(time) + " seconds", width/2, height/2);
}

//cone of light around player
void drawFlashlight() {
  loadPixels();


  // iterate over pixel
  for (int x = 0; x < width; x++ ) {
    for (int y = 0; y < height; y++ ) {

      // Calculate position of pixel
      int loc = x + y*width;

      // Get the R G B values from image
      float r = red  (pixels[loc]);
      float g = green(pixels[loc]);
      float b = blue (pixels[loc]);


      // brightness based on players position
      float distance = dist(x, y, playerX-screenLeftX, playerY-screenTopY);

      //brightness based on distance from player
      float adjustBrightness = map(distance, 0, brightness, 4, 0);
      r *= adjustBrightness;
      g *= adjustBrightness;
      b *= adjustBrightness;

      // Constrain RGB to between 0 and 255
      r = constrain(r, 0, 255);
      g = constrain(g, 0, 255);
      b = constrain(b, 0, 255);

      // Make a new color and set pixel in the window
      color c = color(r, g, b);
      pixels[loc] = c;
    }
  }

  updatePixels();
}


void draw() {
  if (gameState==GAMERUNNING) {
    updatePlayer();
    time+=1/frameRate;
    //light cone gets smaller over time
    brightness-=10/frameRate;
    
  } else if (keyPressed && key==' ') {
    if (gameState==GAMEWAIT) gameState=GAMERUNNING;
    else if (gameState==GAMEOVER || gameState==GAMEWON) newGame();
  }
  screenLeftX = playerX - width/2;
  screenTopY  = playerY- height/2;

  background(0);
  drawMap();
  drawFlashlight();
  drawPlayer();
  drawText();
}
