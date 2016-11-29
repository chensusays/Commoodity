// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import java.util.Iterator;
import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import java.util.*;

final int interval = 8;

Box2DProcessing box2d;

List<Jax> jxs;
int frame;
// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;
PVector lastMouse;
PVector lastTrack;

void setup() {
  frameRate(60);
  background(255);
  //size(640, 480);
  fullScreen();
  lastMouse = new PVector();
  lastTrack = new PVector();
  
  kinect = new Kinect(this);
  tracker = new KinectTracker(1600, 900);
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.listenForCollisions();
  box2d.setGravity(0, -5);
  jxs = new LinkedList<Jax>();
  
}

void draw() {
  fill(0, 20);
  noStroke();
  rectMode(CORNER);
  rect(0, 0, width, height);
  box2d.step();
  
  if(mousePressed && frame % interval == 0){
    PVector vel = new PVector(mouseX - lastMouse.x, lastMouse.y - mouseY);
    //vel.limit(4);
    
    jxs.add(new Jax(mouseX, mouseY, random(3, 10), 255, 255, 0, 255, vel));
  }
  lastMouse = new PVector(mouseX, mouseY);
  // Show the image
  tracker.display();
  fill(100, 250, 50, 200);
  noStroke();
  fill(0);
  PVector v = new PVector(width/2, height/2);
  if(tracker.track()) {
    v = tracker.getLerpedPos();
    PVector vel = new PVector(v.x - lastTrack.x, lastTrack.y - v.y );
    //vel.limit(4);
    
    if(frame % interval == 0)
      jxs.add(new Jax(v.x, v.y, random(3, 10), vel));
  }
  lastTrack = v;
  
  for(int i = jxs.size()-1; i >= 0; i--){
    Jax jx = jxs.get(i);
    jx.display();
    if(jx.done()){
      jxs.remove(i);
    }
  }
  frame++;
}

void mousePressed(){
  PVector vel = new PVector(mouseX - lastMouse.x, lastMouse.y - mouseY);
  //vel.limit(4);
  lastMouse = new PVector(mouseX, mouseY);
  jxs.add(new Jax(mouseX, mouseY, random(3, 10), 255, 255, 0, 255, vel));
}

// Adjust the threshold with key presses
void keyPressed() {
  int t = tracker.getThreshold();
  
  if (key == CODED) {
    if (keyCode == LEFT) {
      t+=5;
      tracker.setThreshold(t);
    } else if (keyCode == RIGHT) {
      t-=5;
      tracker.setThreshold(t);
    } else if(keyCode == UP) {
      float currentTilt = kinect.getTilt();
      kinect.setTilt(currentTilt + 1);
    } else if(keyCode == DOWN) {
      float currentTilt = kinect.getTilt();
      kinect.setTilt(currentTilt - 1);
    }
  }
  if(key == 's'){
     saveFrame("kinect" + random(1000)+ ".png"); 
  }
}