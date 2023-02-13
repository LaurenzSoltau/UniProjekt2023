class Bullet {
  private float posX;
  private float posY;
  private float velocityX;
  private float velocityY;
  private float radius;
  private Map map;
  private boolean isDestroyed;

  public Bullet(float posX, float posY, String direction, Map map) {
    this.posX = posX;
    this.posY = posY;
    this.radius = 10;
    this.map = map;
    this.isDestroyed = false;

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

  public void drawBullet(float screenLeftX, float screenTopY) {
    fill(255, 0, 0);
    circle(posX - screenLeftX, posY - screenTopY, radius);
  }

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
