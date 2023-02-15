class Enemy {

  // position of enemy
  private float posX;
  private float posY;

  private Map map;
  // velocity of enemy in both directions
  private float velocityX;
  private float velocityY;
  private int lives;
  private float damageCooldown;

  //enemy image
  public PImage enemyImg;


  public Enemy(PImage enemyImg, float enemySpeed, int spawnX, int spawnY, char direction, Map map) {
    // construct a new enemy object and set default values. Speed can be set by the parameter.
    this.posX = spawnX * map.tileSize + map.tileSize/2;
    this.posY = spawnY * map.tileSize + map.tileSize/2;
    this.enemyImg = enemyImg;
    this.lives = 2;
    if (direction == 'x') {
      this.velocityX = enemySpeed;
      this.velocityY = 0;
    } else {
      this.velocityY = enemySpeed;
      this.velocityX = 0;
    }
    //  this.enemyR = 10;
    this.map = map;
  }
  // checks for collision with player, returs true if player is hit and false if not
  public boolean checkCollision(Player player) {
    if (player.getPlayerX()+playerImg.width/2 >=posX-enemyImg.width/2  && player.getPlayerY()+player.playerImg.height/2 >= posY-enemyImg.height/2  && player.getPlayerY()- player.playerImg.height/2  <=posY + enemyImg.height/2  && player.getPlayerX()-player.playerImg.width/2 <= posX + enemyImg.width/2) {

      return true;
    } else return false;
  }

  // check if the enemy collided with a bullet, and if yes reduce its live.
  // also set the bullet to isDestroyed, so it will get destroyed in the main program
  public void checkCollisionBullets(ArrayList<Bullet> bullets) {
    for (Bullet bullet : bullets) {
      float bulletPosX = bullet.getPosX();
      float bulletPosY = bullet.getPosY();
      float w = bullet.getRadius();
      float h = bullet.getRadius();
      if (bulletPosX + w >=posX-enemyImg.width/2  && bulletPosY + h >= posY-enemyImg.height/2  && bulletPosY - h  <=posY + enemyImg.height/2  && bulletPosX - h <= posX + enemyImg.width/2) {
        if (damageCooldown <= 0) {
          lives--;
          damageCooldown = 1;
        }
        bullet.setIsDestroyed(true);
      }
    }
  }
  // calculate the new position of the enemy and reduce Cooldowns
  public void updateEnemy() {
    if (damageCooldown >= 0) {
      damageCooldown -= 1/frameRate;
    }
    // calculate x and y position in the next frame
    float nextPosX = posX + velocityX / frameRate;
    float nextPosY = posY + velocityY / frameRate;
    if (map.testTileInRect(nextPosX-(enemyImg.width/2), nextPosY-(enemyImg.height/2), enemyImg.width, enemyImg.height, "W" ) ) {
      velocityX *= -1;
      velocityY *= -1;
      nextPosX = posX;
      nextPosY = posY;
    }

    posX = nextPosX;
    posY = nextPosY;
  }
  // draw enemy to the screen
  void drawEnemy(float screenLeftX, float screenTopY) {
    image( enemyImg, posX - screenLeftX-enemyImg.width/2, posY - screenTopY-enemyImg.height/2, enemyImg.width, enemyImg.height );
  }

  // helper and setter methods
  public int getLives() {
    return this.lives;
  }
}
