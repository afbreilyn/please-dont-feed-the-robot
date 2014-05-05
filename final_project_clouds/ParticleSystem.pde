class ParticleSystem {

  ArrayList particles;
  PVector origin;
  float r, v, b;


  float op = 3.5;
  int flip = 1;
  int w = 10;

  ParticleSystem(int num, float re, float gr, float bl) {
    r = re;
    v = gr;
    b = bl;
    particles = new ArrayList(); 
    for (int i = 0; i < num; i ++) {
      particles.add(new Cloud( random(0, width), random(0, height), 300, color(r, v, b), op));
    }
  }

  void run () {
    //println(particles.size());
    for (int i = particles.size()-1; i >= 0; i--) {
      Cloud cloud = (Cloud) particles.get(i);
      cloud.update();
      cloud.drawCloud();
      if (cloud.dead()) {
        particles.remove(i);
      }
    }
  }


  void addCloud(float re, float gr, float bl)
  {    
    if (flip == 1) 
      if (op < 8) 
        op += .01; // <= ability to change ( CONTROL HERE )
      else 
        flip = 0;
    else {
      if (op > 02) 
        op -= .01; // <= same as above 
      
      else
        flip = 1;
    } 
    
    rouge = re;
    vert = gr;
    bleu = bl;
    float p_width = random(0, width);
    float p_height = random(0, height);
    particles.add(new Cloud(p_width, p_height, 50, color(rouge, vert, bleu), op));

    for ( int j = 0; j < 1; j++) {
      float newX = p_width + random(-w, w);
      float newY = p_height + random (-w*0.5, w*0.25);
      float r = random(10);
      float newW = 50 - r; 
      if (newW < 1) { // not off screen! 
        newW = 1;
      }
      
      particles.add(new Cloud(newX, newY, newW, color(rouge, vert, bleu), op));
    }
  }
}
