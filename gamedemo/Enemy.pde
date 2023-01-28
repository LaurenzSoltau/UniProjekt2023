class Enemy {

  // position of player
  private float posX;
  private float posY;

  private Map map;
  // velocity of player in both directions
  private float velocityX;
  private float velocityY;

  //speed and radius of the player character
  private float enemyR;


  public Enemy(float enemySpeed, int spawnX, int spawnY, char direction, Map map) {
    // construct a new enemy object and set default values. Speed can be set by the parameter.
    this.posX = spawnX * map.tileSize + map.tileSize/2;
    this.posY = spawnY * map.tileSize + map.tileSize/2;
    if (direction == 'x') {
      this.velocityX = enemySpeed;
      this.velocityY = 0;
    } else {
      this.velocityY = enemySpeed;
      this.velocityX = 0;
    }
    this.enemyR = 10;
    this.map = map;
  }


  public void updateEnemy() {
    // calculate x and y position in the next frame
    float nextPosX = posX + velocityX / frameRate;
    float nextPosY = posY + velocityY / frameRate;
    if ( map.testTileInRect( nextPosX-enemyR, nextPosY-enemyR, 2*enemyR, 2*enemyR, "W" ) ) {
      velocityX *= -1;
      velocityY *= -1;
      nextPosX = posX;
      nextPosY = posY;
    }

    posX = nextPosX;
    posY = nextPosY;
  }

  void drawEnemy(float screenLeftX, float screenTopY) {
    // draw player
    noStroke();
    fill(255, 0, 0);
    ellipseMode(CENTER);
    ellipse( posX - screenLeftX, posY - screenTopY, 2*enemyR, 2*enemyR );
  }
}
