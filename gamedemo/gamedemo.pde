import processing.sound.*;
Map map;
Player player;
Enemy enemy;

PImage spiderRight;
PImage spiderLeft;
PImage helpScreen;
PImage playerImg;
PImage enemyImg;
PImage backgroundImg;
public SoundFile music;
public SoundFile hitSound;

ArrayList<Enemy> enemies;

Table highscore;

// Position of the goal center
// Will be set by restart
float goalX=0, goalY=0;
// left / top border of the screen in map coordinates
// used for scrolling
float screenLeftX, screenTopY;
//light cone around player
float brightness;
//Timer for flashlight object
float flashlightTimer;
//saves current brightness while flashlight óbject is used
float saveBrightness;

float helpTimer;
float startTimer;
//Timer for player
float time;
//Game States
int START=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3, HELP=4, HIGHSCORES=5;
int gameState;



void setup() {
  size(900, 768);
  ellipseMode(CORNER);
  playerImg = loadImage("data/images/player.png");
  enemyImg = loadImage("data/images/spider.png");
  spiderRight = loadImage("data/images/spiderRight.png");
  spiderLeft= loadImage("data/images/spiderLeft.png");
  helpScreen= loadImage("data/images/helpScreen.png");
  music = new SoundFile(this, "music.mp3");
  hitSound = new SoundFile(this, "hit.mp3");

  highscore = new Table();
  highscore.addColumn("date");
  highscore.addColumn("time");

  newGame();
}

// function that starts a new game by creating the map and player object and setting starting position of the player and
// the position of the goal. Also is sets the gametimer to zero and the state to waiting to wait until player presses a key
void newGame () {
  music.loop();
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
      // if floortile is G add enemy to ArrayList
      if (map.at(x, y) == 'G') {
        enemies.add(new Enemy(enemyImg, 150, x, y, 'x', map));
      }
    }
  }
  // set all variables to start/initial value
  time=0;
  player.setPlayerVX(0);
  player.setPlayerVY(0);
  brightness = 100;

  //  gameState = START;
}

// control of player
void keyPressed() {
  if ( keyCode == UP || key == 'w') {
    player.setPlayerVY(-1);
    player.setDirection("u");
  } else if ( keyCode == DOWN || key == 's') {
    player.setPlayerVY(1);
    player.setDirection("d");
  } else if ( keyCode == LEFT || key == 'a') {
    player.setPlayerVX(-1);
    player.setDirection("l");
  } else if ( keyCode == RIGHT || key == 'd') {
    player.setPlayerVX(1);
    player.setDirection("r");
  }
}
//control of player
void keyReleased() {
  if (keyCode == UP || keyCode == DOWN || key == 'w' || key == 's') {
    player.setPlayerVY(0);
  }
  if (keyCode == RIGHT || keyCode == LEFT || key == 'a' || key == 'd') {
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
//draws text that is needed while the game is running
void drawText() {
  textAlign(CENTER);
  fill(#930C0C);
  textSize(40);
  text("Lives: " +player.getLives(), 100, 50);
  text("Bullets: " + player.getBullets(), 250, 50);
  text("Time: "+round(time), width-100, 50);
  text("Flashlight: "+round(flashlightTimer), width/2, 50);
}

//draws a cone of light around player (around the center of the screen)
void drawLightcone() {
  loadPixels();
  // iterate over pixel
  for (int x = 0; x < width; x++ ) {
    for (int y = 0; y < height; y++ ) {

      // Calculate position of pixel
      int loc = x + y*width;

      // Get the rgb values from image
      float r = red(pixels[loc]);
      float g = green(pixels[loc]);
      float b = blue(pixels[loc]);

      // brightness based on players position
      float distance = dist(x, y, player.getPlayerX()-screenLeftX, player.getPlayerY()-screenTopY);

      // map brigthness

      float adjustBrightness = map(distance, 0, brightness, 4, 0);
      r *= adjustBrightness;
      g *= adjustBrightness;
      b *= adjustBrightness;


      // constrain rgb to between 0 and 255
      r = constrain(r, 0, 255);
      g = constrain(g, 0, 255);
      b = constrain(b, 0, 255);

      // set new color
      color c = color(r, g, b);
      pixels[loc] = c;
    }
  }

  updatePixels();
}

//checks if player is on an effect tile
// returns true if yes and false if not
boolean checkForEffectTile() {
  // get current position of the player
  int playerX = (int) player.getPlayerX();
  int playerY = (int) player.getPlayerY();
  if (map.atPixel(playerX, playerY) == 'M') {
    collectMatchsticks(playerX, playerY);
  }
  if (map.atPixel(playerX, playerY) == 'L') {
    collectFlashlight(playerX, playerY);
  }
  if (map.atPixel(playerX, playerY) == 'H') {
    drawGameOverScreen();
    gameState = GAMEOVER;
  }
  if (map.atPixel(playerX, playerY) == 'E') {
    gameState = GAMEWON;
    return true;
  }
  return false;
}
//if player collects matchsticks brightness is increased and effect tile is replaced with floor tile
void collectMatchsticks(int x, int y) {
  brightness += 25;
  map.setPixel(x, y, 'F');
}

//if player collects Flashlight brightness is increased, flashlighttimer starts
// effect tile is replaced with floor tile
void collectFlashlight(int x, int y) {
  saveBrightness = brightness;
  flashlightTimer = 5;
  brightness = 1000;

  map.setPixel(x, y, 'F');
}
// draws Start Screen
void drawStartScreen() {
  background(0);
  fill(#930C0C);
  textSize(45);
  text("NYCTO", 270, 145);
  text("ARACHNO", 210, 185);
  textSize(100);
  text("PHOBIA", 400, 180);
  textSize(30);
  text("Help", width/4, 520 );
  textSize(20);
  text("Press 'H'", width/4, 545);
  textSize(30);
  text("Start", 600, 520 );
  textSize(20);
  text("Press 'SPACE'", 600, 545);
  image(spiderRight, 100, 200, spiderRight.width, spiderRight.height);
  image(spiderLeft, 600, 200, spiderLeft.width, spiderLeft.height);
}
//draws Helpscreen
void drawHelpScreen() {
  background(0);
  fill(#930C0C);
  image(helpScreen, 50, 100, helpScreen.width*1.2, helpScreen.height*1.2);
  if (keyPressed && key == 'b' ) {
    //   helpTimer = 0.5;
    gameState = START;
  }
}
// Draws Game Over Screen
void drawGameOverScreen() {
  background(0);
  fill(#930C0C);

  textSize(80);
  text("GAME OVER", 450, 150);
  textSize(30);
  text("Restart", 630, height-100);
  textSize(20);
  text("Press 'R'!", 630, height-75);

  //display score at gameover page
  textSize(30);
  text("You survived " + round(time) + " seconds", 450, 220);
  image(spiderRight, 100, 200, spiderRight.width, spiderRight.height);
  image(spiderLeft, 600, 200, spiderLeft.width, spiderLeft.height);
}
//draws Victory Screen
public void drawGameWonScreen() {
  background(0);
  fill(#930C0C);

  textSize(80);
  text("YOU SURVIVED", 450, 150);
  textSize(30);
  text("Play again", 630, height-100);
  text("Date", 420, 250);
  text("Time", 550, 250);
  textSize(20);
  text("Press 'R'!", 630, height-75);

  drawHighscore();
}
//displays Highscore
void drawHighscore() {
  loadTable("new.csv");
  TableRow newRow = highscore.addRow();
  int day = day();
  int month = month();
  int year = year();
  String date = String.valueOf(day) + "." + String.valueOf(month) + "." + String.valueOf(year);
  String formattedTime = String.valueOf(round(time)) + " seconds";
  newRow.setString("date", date);
  newRow.setString("time", formattedTime);
  //sorted from best to worst time
  highscore.sort("time");

  //only display best five scores
  if (highscore.getRowCount() > 5) {
    highscore.removeRow(highscore.getRowCount()-1);
  }
  //saves highscore
  saveTable(highscore, "data/new.csv");
  //draws highscore
  int textPosition = 300;
  for (int i = 0; i < highscore.getRowCount(); i++) {
    TableRow rows = highscore.getRow(i);
    text(i+1, 320, textPosition);
    text(rows.getString("date"), 420, textPosition);
    text(rows.getString("time"), 550, textPosition);
    textPosition += 50;
  }
}


void draw() {
  //
  if (gameState==START) {
    //draw startscreen
    drawStartScreen();
    //start game if space is pressed
    if (keyPressed && key == ' ') {
      gameState = GAMERUNNING;
    }
    //got to helpscreen if h is pressed
    if (keyPressed && key == 'h' ) {
      //   helpTimer = 0.5;
      gameState = HELP;
    }
  }
  //if 'h' is pressed go to helpScreen
  if (gameState == HELP) {
    drawHelpScreen();
  }

  if (gameState == GAMEOVER || gameState == GAMEWON) {
    if ( keyPressed && key == 'r') {
      newGame();
      gameState = GAMERUNNING;
    }
  }
  /*  if (gameState == GAMEWON) {
   if ( keyPressed && key == ' ') {
   newGame();
   }
   }*/
  //update enemies and player
  if (gameState==GAMERUNNING) {
    player.updatePlayer();
    ArrayList<Enemy> enemyRemoves = new ArrayList<Enemy>();
    for (Enemy enemy : enemies) {
      enemy.updateEnemy();
      enemy.checkCollisionBullets(player.getBulletList());
      if (enemy.checkCollision(player)) {
        player.gotHit();
      }
      if (enemy.getLives() < 1) {
        enemyRemoves.add(enemy);
      }
    }
    enemies.removeAll(enemyRemoves);
    
    // handle bullets
    boolean isWin = checkForEffectTile();
    if (isWin) {
      gameState = GAMEWON;
      drawGameWonScreen();
      return;
    }
    //increase playing time every secon
    time+=1/frameRate;
    //light cone gets smaller over time
    brightness-=8/frameRate;
    //decrease flashlight timer
    if (flashlightTimer > 0) {
      flashlightTimer-= 1/frameRate;
      //if flashlight timer is 0 set brightness to previous brightness
      if (flashlightTimer <= 0) {
        brightness = saveBrightness;
      }
    }
    // if  all lives are gone or brightness is too small game over
    if (player.getLives() <= 0 || brightness <= 20) {
      gameState = GAMEOVER;
      //   startTimer = 0.5;
      brightness = 1000;
      drawGameOverScreen();
      music.stop();
      return;
    }
    // centers screeen on player
    screenLeftX = player.getPlayerX() - width/2;
    screenTopY  = player.getPlayerY() - height/2;

    background(0);
    //draws Map
    drawMap();
    // draws player
    player.drawPlayer(screenLeftX, screenTopY);
    // draws enemies
    for (Enemy enemy : enemies) {
      enemy.drawEnemy(screenLeftX, screenTopY);
    }
    ArrayList<Bullet> removes = new ArrayList<Bullet>();
    for (Bullet bullet : player.getBulletList()) {
      if (bullet.getIsDestroyed()) {
        removes.add(bullet);
      }
      bullet.updateBullet();
      bullet.drawBullet(screenLeftX, screenTopY);
    }
    player.getBulletList().removeAll(removes);

    drawLightcone();
    drawText();
  }
}
