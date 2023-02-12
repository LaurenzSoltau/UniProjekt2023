class Enemy {

  // position of enemy
  private float posX;
  private float posY;

  private Map map;
  // velocity of enemy in both directions
  private float velocityX;
  private float velocityY;

  //enemy image
  public PImage enemyImg;


  public Enemy(PImage enemyImg, float enemySpeed, int spawnX, int spawnY, char direction, Map map) {
    // construct a new enemy object and set default values. Speed can be set by the parameter.
    this.posX = spawnX * map.tileSize + map.tileSize/2;
    this.posY = spawnY * map.tileSize + map.tileSize/2;
    this.enemyImg = enemyImg;
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
    if (player.getPlayerX() + player.playerImg.width >=posX  && player.getPlayerY()+player.playerImg.height >= posY  && player.getPlayerY()  <=posY + enemyImg.height  && player.getPlayerX() <= posX + enemyImg.width/2) {
    
      return true;
    } else return false;
  }

  /*  public boolean checkCollision(Player player) {
   float testX = player.getPlayerX();
   float testY = player.getPlayerY();
   if (posX < player.getPlayerX()-player.getPlayerX()+playerImg.width/2) {
   testX = player.getPlayerX()-player.playerImg.width/2;
   } else if (posX > player.getPlayerX()+player.playerImg.width/2) {
   testX = player.getPlayerX()+player.playerImg.width/2;
   }
   if (posY < player.getPlayerY()-player.playerImg.height/2) {
   testY = player.getPlayerY()-player.playerImg.height/2;
   } else if (posY > player.getPlayerY()+player.playerImg.height/2) {
   testY = player.getPlayerY()+player.playerImg.height/2;
   }
   
   float distance = dist(posX, posY, testX, testY);
   // collision detected
   if (distance <= enemyImg.height/2) {
   return true;
   }
   return false;
   }*/

  public void updateEnemy() {
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
  // draw enemy
  void drawEnemy(float screenLeftX, float screenTopY) {
    image( enemyImg, posX - screenLeftX-enemyImg.width/2, posY - screenTopY-enemyImg.height/2, enemyImg.width, enemyImg.height );
  }
}
