class Player {
  // position of player
  private float playerX;
  private float playerY;

  private int lives;
  private float damageTimer;

  private Map map;
  // verlocity of player in both directions
  private float playerVX;
  private float playerVY;

  //speed and radius of the player character
  private float playerSpeed;
  private float playerR;

  private color playerColor;

  public Player(float playerSpeed, Map map) {
    // construct a new Player object and set default values. Speed can be set by the parameter.
    this.playerX = 0;
    this.playerY = 0;
    this.playerVX = 0;
    this.playerVY = 0;
    this.playerSpeed = playerSpeed;
    this.playerR = 10;
    this.map = map;
    this.lives = 3;
    this.damageTimer = 0;
    this.playerColor = color(0, 255, 255);
  }


  public void updatePlayer() {
    // update player position and returns an Array with the new xPos at index 0 and the yPos at index 1
    if (damageTimer >= 0) {
      damageTimer -= 1/frameRate;
    }
    if (damageTimer >= 0 && damageTimer <= 0.8) {
     playerColor = color(0, 255, 255);
    }
    float nextX = playerX + playerVX/frameRate,
      nextY = playerY + playerVY/frameRate;
    if ( map.testTileInRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "W" ) ) {
      playerVX = 0;
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

  void gotHit() {
    if (damageTimer <= 0) {
      damageTimer = 1;
      lives -= 1;
    }
    playerColor = color(255, 0, 0);
  }
  void drawPlayer(float screenLeftX, float screenTopY) {
    // draw player
    noStroke();
    fill(playerColor);
    ellipseMode(CENTER);
    ellipse(playerX - screenLeftX, playerY - screenTopY, 2*playerR, 2*playerR);
  }

  //setter and getter
  public int getLives() {
    return this.lives;
  }

  public float getPlayerR() {
    return this.playerR;
  }



  public float getPlayerX() {
    return this.playerX;
  }

  public float getPlayerY() {
    return this.playerY;
  }

  public float getPlayerVX() {
    return this.playerVX;
  }

  public float getPlayerVY() {
    return this.playerVY;
  }

  public void setPlayerX(float x) {
    this.playerX = x;
  }

  public void setPlayerY(float y) {
    this.playerY = y;
  }

  public void setPlayerVX(float multi) {
    this.playerVX = abs(playerSpeed) * multi;
  }

  public void setPlayerVY(float multi) {
    this.playerVY = abs(playerSpeed) * multi;
  }
}
