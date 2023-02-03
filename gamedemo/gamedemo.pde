Map map;
Player player;
ArrayList<Enemy> enemies;
Enemy enemy;
PImage playerImg;
PImage enemyImg;
//NEED FOR HIGHSCORE
/*
String nameOfPlayer = "";
String cacheNameOfPlayer = "";

Table highscore;
*/

// The players is a circle and this is its radius
float playerR = 10;
// Position of the goal center
// Will be set by restart
float goalX=0, goalY=0;

// left / top border of the screen in map coordinates
// used for scrolling
float screenLeftX, screenTopY;
//light beam around player
float brightness;
float flashlightTimer;
float saveBrightness;

float time;
int GAMEWAIT=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3;
int gameState;

PImage backgroundImg;

void setup() {
  size(900, 900);
  playerImg = loadImage("data/images/player.png");
  enemyImg = loadImage("data/images/A.png");
  newGame();
  //NEED FOR HIGHSCORE
  /*
  highscore = new Table();
  highscore.addColumn("name");
  highscore.addColumn("time");*/
}

// function that starts a new game by creating the map and player object and setting starting position of the player and
// the position of the goal. Also is sets the gametimer to zero and the state to waiting to wait until player presses a key
void newGame () {
  map = new Map( "demo.map");
  player = new Player(playerImg, 150, map);
  enemies = new ArrayList<Enemy>();
  // loop trhough map pixels and find the starting position
  for ( int x = 0; x < map.w; ++x ) {
    for ( int y = 0; y < map.h; ++y ) {
      // put player at 'S' tile and replace with 'F'
      if (map.at(x, y) == 'S') {
        // when startingposition is found, set the position of the player to this position
        float playerX = map.centerXOfTile(x);
        float playerY = map.centerYOfTile(y);
        player.setPlayerX(playerX);
        player.setPlayerY(playerY);
        // replace the start tile with a normal floor tile
        map.set(x, y, 'F');
      }
      // put goal at 'E' tile
      if ( map.at(x, y) == 'E' ) {
        // set goalposition when goal tile is found
        goalX = map.centerXOfTile (x);
        goalY = map.centerYOfTile (y);
      }

      if (map.at(x, y) == 'G') {
        enemies.add(new Enemy(enemyImg, 150, x, y, 'x', map));
      }
    }
  }
  time=0;
  player.setPlayerVX(0);
  player.setPlayerVY(0);
  brightness = 100;
  gameState = GAMEWAIT;
}


void keyPressed() {
  if ( keyCode == UP) {
    player.setPlayerVY(-1);
  } else if ( keyCode == DOWN) {
    player.setPlayerVY(1);
  } else if ( keyCode == LEFT) {
    player.setPlayerVX(-1);
  } else if ( keyCode == RIGHT) {
    player.setPlayerVX(1);
  }
}

void keyReleased() {
  if (keyCode == UP || keyCode == DOWN) {
    player.setPlayerVY(0);
  }
  if (keyCode == RIGHT || keyCode == LEFT) {
    player.setPlayerVX(0);
  }
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

void drawText() {
  textAlign(CENTER, CENTER);
  fill(0, 255, 0);
  textSize(40);
  text(player.getLives(), 100, 100);
  if (gameState==GAMEWAIT) text ("press space to start", width/2, height/2);
  else if (gameState==GAMEOVER) text ("game over", width/2, height/2);
  else if (gameState==GAMEWON) text ("won in "+ round(time) + " seconds", width/2, height/2);
}

//cone of light around player (around the center of the screen)
void drawLightcone() {
  loadPixels();
  // iterate over pixel
  for (int x = 0; x < width; x++ ) {
    for (int y = 0; y < height; y++ ) {

      // Calculate position of pixel
      int loc = x + y*width;

      // Get the R G B values from image
      float r = red(pixels[loc]);
      float g = green(pixels[loc]);
      float b = blue(pixels[loc]);


      // brightness based on players position
      float distance = dist(x, y, player.getPlayerX()-screenLeftX, player.getPlayerY()-screenTopY);

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
//------ vvvv HIGHSCORE TABLE  UNDER THIS LINE vvvv---------------------------------------
/*void drawHighscore() {
  TableRow row = highscore.addRow();
  nameOfPlayer(nameOfPlayer);
  row.setString("name", nameOfPlayer);
  row.setInt("time", round(time));

  highscore.sort("time");


  if (highscore.getRowCount() > 5) {
    highscore.removeRow(highscore.getRowCount());
  }
  int rowCount = 0;
 int textPosition = 200;
  for (TableRow rows : highscore.rows()) {
 text(rows.getString("name"), 50, textPosition);
    text(rows.getInt("time"), 150, textPosition);
    textPosition += 50;
    rowCount++;
  }
  saveTable(highscore, "data/new.csv");
}

String nameOfPlayer(String nameOfPlayer) {
  if (keyPressed && key == '\n' ) {
    cacheNameOfPlayer = nameOfPlayer;

    nameOfPlayer = "";
  } else if (keyPressed) {

    nameOfPlayer = nameOfPlayer + key;
  }
  return nameOfPlayer;
}*/
//-------------HIGHSCORE TABLE ABOVE THIS LINE -------------------

void checkForEffectTile() {
  // get current position of the player
  int playerX = (int) player.getPlayerX();
  int playerY = (int) player.getPlayerY();
  if (map.atPixel(playerX, playerY) == 'M') {
    collectMatchsticks(playerX, playerY);
  }
  if (map.atPixel(playerX, playerY) == 'L') {
    collectFlashlight(playerX, playerY);
  }
}

void collectMatchsticks(int x, int y) {
  brightness += 25;
  map.setPixel(x, y, 'F');
}
void collectFlashlight(int x, int y) {
  saveBrightness = brightness;
  flashlightTimer = 5;
  brightness = 1000;

  if (flashlightTimer <= 0) {
    brightness = 100;
  }

  map.setPixel(x, y, 'F');
}

void draw() {
  if (gameState==GAMERUNNING) {
    player.updatePlayer();
    for (Enemy enemy : enemies) {
      enemy.updateEnemy();
      if (enemy.checkCollision(player)) {
        player.gotHit();
      }
    }
    checkForEffectTile();
    time+=1/frameRate;
    //light cone gets smaller over time
    brightness-=8/frameRate;
    //if light cone is gone gameover
    if (flashlightTimer > 0) {
      flashlightTimer-= 1/frameRate;
      if (flashlightTimer <= 0) {
        brightness = saveBrightness;
      }
    }



    if (player.getLives() <= 0) {
      gameState = GAMEOVER;
      brightness = 1000;
    }

    if (brightness <= 20) {
      gameState = GAMEOVER;
      // set brightness high so player can see map in gameover screen
      brightness = 1000;
    }
    // check if user starts game by pressing spacebar or if he restarts the game
  } else if (keyPressed && key==' ') {
    if (gameState==GAMEWAIT) {
      gameState=GAMERUNNING;
    } else if (gameState==GAMEOVER || gameState==GAMEWON)
    {
      newGame();
    }
  }
  screenLeftX = player.getPlayerX() - width/2;
  screenTopY  = player.getPlayerY() - height/2;

  background(0);

  drawMap();
  // image(playerImg, player.playerX - screenLeftX, player.playerY - screenTopY, playerImg.width, playerImg.height);
  player.drawPlayer(screenLeftX, screenTopY);
  for (Enemy enemy : enemies) {
    enemy.drawEnemy(screenLeftX, screenTopY);
  }
  drawLightcone();
  drawText();
  fill(255);
  text(flashlightTimer, 50, 50);
}
