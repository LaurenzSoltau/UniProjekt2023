Map map;
Player player;
ArrayList<Enemy> enemies;
Enemy enemy;
PImage playerImg;
PImage enemyImg;
//NEED FOR HIGHSCORE

String nameOfPlayer = "";
String cacheNameOfPlayer = "";

Table highscore;


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
float helpTimer;
float startTimer;

float time;
int START=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3, HELP=4, HIGHSCORES=5;
int gameState;

PImage backgroundImg;

void setup() {
  size(900, 768);
  playerImg = loadImage("data/images/player.png");
  enemyImg = loadImage("data/images/A.png");
  newGame();
  //NEED FOR HIGHSCORE

  highscore = new Table();
  highscore.addColumn("name");
  highscore.addColumn("time");
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
  gameState = START;
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
  if (gameState == GAMEWON) {

    if (key == '\n' ) {
      cacheNameOfPlayer = nameOfPlayer;

      nameOfPlayer = "";
    } else {

      nameOfPlayer = nameOfPlayer + key;
    }
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
  if (gameState==START) text ("press space to start", width/2, height/2);
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

void drawStartScreen() {
  background(0);
  fill(#930C0C);
  textSize(40);
  text("NYCTOPHOBIA", 330, 150);
  textSize(30);
  text("Help", width/4, 520 );
  textSize(20);
  text("Press 'H'", width/4, 545);
  textSize(30);
  text("Start", 600, 520 );
  textSize(20);
  text("Press 'SPACE'", 600, 545);
}

void drawHelpScreen() {
  background(0);
  fill(#930C0C);
  text("Guide me trhough the labyrinth", 20, 60);
  text("You have three lives. If they are gone: Game Over!", 20, 90);
  text("You loose lives by getting attacked by spiders...", 20, 120);
  text("... if your light goes out... you die.", 20, 150);
  text("Collect matches and flashlights to survive longer.", 20, 180);
  text("Press 'H' to get back to the Startscreen!", width/2-150, height-100);
}

void drawGameOverScreen() {
  background(0);
  fill(#930C0C);

  textSize(80);
  text("GAME OVER", 450, 150);
  textSize(30);
  text("Restart", 630, height-100);
  textSize(20);
  text("Press 'SPACE'!", 630, height-75);

  //display score at gameover page

  textSize(30);
  text("You lasted " + round(time) + " seconds", 465, 250);
}

void drawGameWonScreen() {
  background(0);
  fill(#930C0C);

  textSize(80);
  text("YOU SURVIVED", 450, 150);
  textSize(30);
  text("Play again", 630, height-100);
  text("Name", 320, 250);
  text("Time", 520, 250);
  textSize(20);
  text("Press 'SPACE'!", 630, height-75);

  drawHighscore();
}
void drawHighscore() {
  loadTable("new.csv");
  TableRow row = highscore.addRow();
  nameOfPlayer = nameOfPlayer(nameOfPlayer);
  row.setString("name", nameOfPlayer);
  row.setInt("time", round(time));

  //   highscore.sort("time");


  if (highscore.getRowCount() > 5) {
    highscore.removeRow(highscore.getRowCount()-1);
  }
    saveTable(highscore, "data/new.csv");

  int textPosition = 300;
  for (int i = 0; i < highscore.getRowCount(); i++) {
    TableRow rows = highscore.getRow(i);
    text(rows.getString("name"), 320, textPosition);
    text(rows.getInt("time"), 520, textPosition);
    textPosition += 50;
  }

}

String nameOfPlayer(String nameOfPlayer) {
  textSize(30);
  fill(#930C0C);
  text("Type in your name", 450, 50);
  noFill();
  stroke(#930C0C);
  rect(350, 100, 200, 20);
  fill(#930C0C);
  text(nameOfPlayer, 355, 102);

  return nameOfPlayer;
}

void draw() {

  if (gameState==START) {
    if (keyPressed && key == ' ') {
      gameState = GAMERUNNING;
    }
    if (keyPressed && key == 'h' && helpTimer <= 0) {
      helpTimer = 0.5;
      gameState = HELP;
    }
    drawStartScreen();
  }
  if (gameState == HELP) {
    drawHelpScreen();
    if (keyPressed && key == 'h' && helpTimer <= 0) {
      helpTimer = 0.5;
      gameState = START;
    }
  }
  if (gameState == GAMEOVER) {
    drawGameOverScreen();
    if ( keyPressed && key == ' ') {
      newGame();
    }
  }
  if (gameState == GAMEWON) {
    drawGameWonScreen();
    if ( keyPressed && key == ' ') {
      newGame();
    }
  }
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
      startTimer = 0.5;
      brightness = 1000;
    }

    if (brightness <= 20) {
      gameState = GAMEOVER;
      startTimer = 0.5;
      // set brightness high so player can see map in gameover screen
      brightness = 1000;
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
    // check if user starts game by pressing spacebar or if he restarts the game
  }
  if (helpTimer >= 0) {
    helpTimer -= 1/frameRate;
  }

  if (startTimer >= 0) {
    helpTimer -= 1/frameRate;
  }
}
