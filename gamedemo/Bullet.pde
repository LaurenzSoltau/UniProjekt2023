class Bullet {
  private float posX;
  private float posY;
  private float velocityX;
  private float velocityY;
  private float radius;
  private Map map;
  private boolean isDestroyed;

  // construct a bullet with position and direction
  public Bullet(float posX, float posY, String direction, Map map) {
    this.posX = posX;
    this.posY = posY;
    this.radius = 10;
    this.map = map;
    this.isDestroyed = false;

    // set the velocity according to the direction the player was looking in
    if (direction == "u") {
      velocityX = 0;
      velocityY = -200;
    } else if (direction == "d") {
      velocityX = 0;
      velocityY = 200;
    } else if (direction == "l") {
      velocityX = -200;
      velocityY = 0;
    } else if (direction == "r") {
      velocityX = 200;
      velocityY = 0;
    }
  }

  // update the position of the bullet, and check if it is collided with a wall.
  public void updateBullet() {
    float nextPosX = posX + velocityX / frameRate;
    float nextPosY = posY + velocityY / frameRate;
    if (map.testTileInRect(nextPosX, nextPosY, radius, radius, "W" ) ) {
      isDestroyed = true;
      nextPosX = posX;
      nextPosY = posY;
    }

    posX = nextPosX;
    posY = nextPosY;
  }

  // draw the bullet to the screen
  public void drawBullet(float screenLeftX, float screenTopY) {
    fill(#930C0C);
    circle(posX - screenLeftX, posY - screenTopY, radius);
  }

  // getter and setter
  public boolean getIsDestroyed() {
    return this.isDestroyed;
  }

  public float getPosX() {
    return this.posX;
  }
  public float getPosY() {
    return this.posY;
  }
  public float getRadius() {
    return this.radius;
  }

  public void setIsDestroyed(boolean isDestroyed) {
    this.isDestroyed = isDestroyed;
  }
}
