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

final int interval = 8;

Box2DProcessing box2d;

ArrayList<Jax> jxs;
int frame;
// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;


void setup() {
  frameRate(60);
  background(255);
  //size(640, 480);
  fullScreen();
  kinect = new Kinect(this);
  tracker = new KinectTracker(width, height);
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.listenForCollisions();
  box2d.setGravity(0, -10);
  jxs = new ArrayList<Jax>();
}

void draw() {
  fill(0, 20);
  noStroke();
  rectMode(CORNER);
  rect(0, 0, width, height);
  box2d.step();
  
  if(mousePressed && frame % interval == 0){
    jxs.add(new Jax(mouseX, mouseY, random(3, 10), 255, 255, 0, 255));
  }
  // Show the image
  tracker.display();
  fill(100, 250, 50, 200);
  noStroke();
  fill(0);

  if(tracker.track()) {
    PVector v = tracker.getLerpedPos();
    if(frame % interval == 0)
      jxs.add(new Jax(v.x, v.y, random(3, 10)));
  }
  
  for(int i = jxs.size()-1; i >= 0; i--){
    Jax jx = jxs.get(i);
    jx.display();
    //Particles that leave the screen we delete
    //need to be deleted from the list and the world
    if(jx.done()){
      jxs.remove(i);
    }
  }
    
  frame++;
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
}