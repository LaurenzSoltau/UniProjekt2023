class Player {
  // position of player
  private float playerX;
  private float playerY;

  // verlocity of player in both directions
  private float playerVX;
  private float playerVY;

  //speed and radius of the player character
  private float playerSpeed;
  private float playerR;


  public Player(float playerSpeed) {
    // construct a new Player object and set default values. Speed can be set by the parameter.
    this.playerX = 0;
    this.playerY = 0;
    this.playerVX = 0;
    this.playerVY = 0;
    this.playerSpeed = playerSpeed;
    this.playerR = 10;
  }


  public void updatePlayer(Map map) {
    // update player position and returns an Array with the new xPos at index 0 and the yPos at index 1
    float nextX = playerX + playerVX/frameRate,
      nextY = playerY + playerVY/frameRate;
    if ( map.testTileInRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "W" ) ) {
      playerVX = 0;
      playerVY = 0;
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
  
  void drawPlayer(float screenLeftX, float screenTopY, Map map) {
  // draw player
  noStroke();
  fill(0, 255, 255);
  ellipseMode(CENTER);
  ellipse( playerX - screenLeftX, playerY - screenTopY, 2*playerR, 2*playerR );

  // understanding this is optional, skip at first sight
  if (showSpecialFunctions) {
    // draw a line to the next hole
    Map.TileReference nextHole = map.findClosestTileInRect (playerX-100, playerY-100, 200, 200, "H");
    stroke(255, 0, 255);
    if (nextHole!=null) line (playerX-screenLeftX, playerY-screenTopY,
      nextHole.centerX-screenLeftX, nextHole.centerY-screenTopY);

    // draw line of sight to goal (until next wall) (understanding this is optional)
    stroke(0, 255, 255);
    Map.TileReference nextWall = map.findTileOnLine (playerX, playerY, goalX, goalY, "W");
    if (nextWall!=null)
      line (playerX-screenLeftX, playerY-screenTopY, nextWall.xPixel-screenLeftX, nextWall.yPixel-screenTopY);
    else
      line (playerX-screenLeftX, playerY-screenTopY, goalX-screenLeftX, goalY-screenTopY);
  }
}
  
  //setter and getter
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
