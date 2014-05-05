class Cloud {
  PVector position;
  float oppacity;
  float w;
  color clr;
  float timer;

  protected Cloud(float x, float y, float wid, color c, float o) {
    position = new PVector(x, y);
    w = wid;
    clr = c;
    oppacity = o;
    timer = 100.0;
  }

  void update() {
       timer -= 15;
  }

  boolean dead(){
      if ( timer <= 0.0 ){
       return true;
      //timer = 100.0;
    } else {
      return false;
    } 
  }

  public void drawCloud() {
    fill(clr, oppacity);
    ellipse(position.x, position.y, 50, 50);
  }
}
