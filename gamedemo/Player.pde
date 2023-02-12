class Player {
  // position of player
  private float playerX;
  private float playerY;
  // lives
  private int lives;
  private float damageTimer;

  private Map map;
  // verlocity of player in both directions
  private float playerVX;
  private float playerVY;

  private boolean isTint;

  //speed of the player character
  private float playerSpeed;

  // player Image
  public PImage playerImg;


  public Player(PImage playerImg, float playerSpeed, Map map) {
    // construct a new Player object and set default values. Speed can be set by the parameter.
    this.playerX = 0;
    this.playerY = 0;
    this.playerVX = 0;
    this.playerVY = 0;
    this.playerSpeed = playerSpeed;
 
    this.map = map;
    this.lives = 3;
    this.damageTimer = 0;
    this.playerImg = playerImg;
  }


  public void updatePlayer() {
    // update player position and returns an Array with the new xPos at index 0 and the yPos at index 1
    if (damageTimer >= 0) {
      damageTimer -= 1/frameRate;
    }
    if (damageTimer >= 0 && damageTimer <= 0.8) {
      isTint = false;
      // has to be implemented
    }
    float nextX = playerX + playerVX/frameRate, nextY = playerY + playerVY/frameRate;
    if ( map.testTileInRect( nextX-playerImg.width/2, nextY- playerImg.height/2, playerImg.width, playerImg.height, "W" ) ) {
      playerVX = 0;
      nextX = playerX;
      nextY = playerY;
    }

    playerX = nextX;
    playerY = nextY;
  }

  void gotHit() {
    if (damageTimer <= 0) {
      damageTimer = 1;
      isTint = true;
      lives -= 1;
    }
  }
  void drawPlayer(float screenLeftX, float screenTopY) {
    // draw player
    if (isTint) {
      tint(255, 0, 0);
    } else {
      noTint();
    }
    image(playerImg, playerX - screenLeftX-playerImg.width/2, playerY - screenTopY-playerImg.height/2, playerImg.width, playerImg.height);
  }

  //setter and getter
  public int getLives() {
    return this.lives;
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
