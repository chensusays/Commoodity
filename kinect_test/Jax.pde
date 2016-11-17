class Jax{
  
  float size;
  int red, green, blue, alpha;
  Body b;
  
  Jax(float x, float y, float sz){
    this(x, y, sz, 255, 255, 255, 255);
  }
  
  Jax(float x, float y, float sz, int red, int green, int blue, int alpha){
    this.red = red;
    this.green = green;
    this.blue = blue;
    this.alpha = alpha;
    size = sz;
    
    Vec2 loc = new Vec2(x,y);
    
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(loc));
    b = box2d.createBody(bd);
    
    CircleShape  cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(size);
    
    Vec2[] vert1 = new Vec2[3];
    vert1[0] = box2d.vectorPixelsToWorld(new Vec2(size*2*cos(0), size*2*sin(0)));
    vert1[1] = box2d.vectorPixelsToWorld(new Vec2(0, size));
    vert1[2] = box2d.vectorPixelsToWorld(new Vec2(0, -size));
    PolygonShape tri1= new PolygonShape();
    tri1.set(vert1, vert1.length);
    
    Vec2[] vert2 = new Vec2[3];
    vert2[0] = box2d.vectorPixelsToWorld(new Vec2(size*2*cos(PI/2), size*2*sin(PI/2)));
    vert2[1] = box2d.vectorPixelsToWorld(new Vec2(-size, 0));
    vert2[2] = box2d.vectorPixelsToWorld(new Vec2(size, 0));
    PolygonShape tri2= new PolygonShape();
    tri2.set(vert2, vert2.length);
    
    Vec2[] vert3 = new Vec2[3];
    vert3[0] = box2d.vectorPixelsToWorld(new Vec2(size*2*cos(PI), size*2*sin(PI)));
    vert3[1] = box2d.vectorPixelsToWorld(new Vec2(0, -size));
    vert3[2] = box2d.vectorPixelsToWorld(new Vec2(0, size));
    PolygonShape tri3= new PolygonShape();
    tri3.set(vert3, vert3.length);
    
    Vec2[] vert4 = new Vec2[3];
    vert4[0] = box2d.vectorPixelsToWorld(new Vec2(size*2*cos(3*PI/2), size*2*sin(3*PI/2)));
    vert4[1] = box2d.vectorPixelsToWorld(new Vec2(size, 0));
    vert4[2] = box2d.vectorPixelsToWorld(new Vec2(-size, 0));
    PolygonShape tri4= new PolygonShape();
    tri4.set(vert4, vert4.length);
    
    b.createFixture(cs, 1.0);
    b.createFixture(tri1, 1.0);
    b.createFixture(tri2, 1.0);
    b.createFixture(tri3, 1.0);
    b.createFixture(tri4, 1.0);
    
    b.setAngularVelocity(random(-200, 200));
    
  }
  
  void killBody(){
    box2d.destroyBody(b);
  }
  //particle ready for deletion?
  boolean done(){
    //screen position of particle
    Vec2 pos = box2d.getBodyPixelCoord(b);
    //is it off the bottom of the screen?
    if(pos.y > height){
      killBody();
      return true;
    }
    return false;
  }
  
  void display(){
    Vec2 pos = box2d.getBodyPixelCoord(b);
    float a = b.getAngle();
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(red, green, blue, alpha);
    noStroke();
    for(float i = 0; i <=TWO_PI; i+=PI/2){
      pushMatrix();
      rotate(i);
      triangle(size*2, 0, 0, size, 0, -size);
      popMatrix();
    }
    popMatrix();
  }
}
      
      
    