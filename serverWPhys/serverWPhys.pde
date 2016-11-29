import kinect4WinSDK.*;
import java.nio.ByteBuffer;
import processing.net.*;
import shiffman.box2d.Box2DProcessing;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

import java.util.ArrayList;

Server s; 
Client c;
String input;
int data[];

PVector[] lastVectors = null;
Kinect kinect;
ArrayList <SkeletonData> bodies;
float maxd = 150;


ArrayList<Lin> ls;
float connectdist;
int state = 0;
boolean transition = false;
float nx = 0;
int currx = 0;
int curry = 0;
Box2DProcessing box2d;
Moon m;
Boundary b;
HandBouncer [] mouseBouncers;
int starlinecounter;
ArrayList<Star> p1stars;
ArrayList<Star> p2stars;

byte[] toByteArray(float[] a) {
    ByteBuffer bb = ByteBuffer.allocate(4 * a.length);
    for(float f : a) {
        bb.putFloat(f);
    }
    return bb.array();
}

int[] toIntArray(byte[] byteArray) {
  int[] intArray = new int[byteArray.length / 4];
  for(int i=0; i < intArray.length; i++) {
    intArray[i] = 0;
    for(int j=0; j<4; j++) {
      intArray[i] |= ((int) byteArray[j + 4*i]) << (8 * j);
     }
  }
  return intArray;
}

void setup() {
  mouseBouncers = new HandBouncer[2];
  frameRate(60);
  background(255);
  size(640, 480);
  kinect = new Kinect(this);
  smooth();
  bodies = new ArrayList<SkeletonData>();
  stroke(0);
  boolean connected = false;
  s = new Server(this, 12345);  // Start a simple server on a port
  while(!connected) {
    delay(1000);
    c = new Client(this, "192.168.1.42", 8080);
    delay(2000);
    connected = c.active();
  }
  background(0, 0, 70);
  connectdist = 80;
  ls = new ArrayList<Lin>();
  frameRate(60);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  state = 0;
  p1stars = new ArrayList<Star>();
  p2stars = new ArrayList<Star>();
  b = new Boundary(0, height/2, 10, height*3);
  b = new Boundary(width, height/2, 10, height*3);
  b = new Boundary(width/2, -height, width, 10);
  //box2d.listenForCollisions();
  //custom gravity;

  box2d.setGravity(0, -15);
    
}

void draw() {
  drawMoon();
  
  if(c != null && c.available() > 0) {
    byte[] data = c.readBytes();
    ByteBuffer bb = ByteBuffer.allocate(data.length);
    bb.put(data);
    bb.flip();
    float[] floatData = new float[data.length / 4];
    for(int i=0; i<floatData.length; i++) {
      floatData[i] = bb.getFloat();
    }
    PVector[] vectors = new PVector[floatData.length / 2];
    for(int i=0; i<vectors.length; i++) {
      vectors[i] = new PVector();
      vectors[i].x = floatData[2 * i];
      vectors[i].y = floatData[2 * i + 1];
    }
    lastVectors = vectors;
    drawSkeleton(vectors);
  } else if(lastVectors != null) {
    drawSkeleton(lastVectors);
  }
  
  if(bodies.size() > 0) {
    SkeletonData skeleton = bodies.get(0);
    if(state == 2)
      drawHands(skeleton);
    float[] data = new float[skeleton.skeletonPositions.length * 2];
    for(int i=0; i<skeleton.skeletonPositions.length; i++) {
      if(skeleton.skeletonPositionTrackingState[i] == Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
        data[2 * i] = 0;
        data[2 * i + 1] = 0; 
      } else {
        //println("sending " + skeleton.skeletonPositions[i].x + ", " + skeleton.skeletonPositions[i].y);
        data[2 * i] = skeleton.skeletonPositions[i].x;
        data[2 * i + 1] = skeleton.skeletonPositions[i].y;
      }
    }
    s.write(toByteArray(data));
  }
}

void drawMoon() {
  fill(15, 0, 35, 20);
  noStroke();
  rectMode(CORNER);
  rect(0, 0, width, height);
  if(state == 0){
      if(!transition){
          currx = (int) map(noise(nx), 0, 1, -100, width+100);
          curry = (int) map(noise(0, nx), 0, 1, -100, height+100);
      } else {
          currx = (int) lerp(currx, width/2, .05f);
          curry = (int) lerp(curry, height/2, .05f);
      }
  
      stroke(255);
      if( ls.size() < 50 && maxd > 10){
          for(int i = 0; i < 10; i++){
              ls.add(new Lin(currx, curry));
          }
      }
      //Iterator<Lin> it = ls.iterator();
  
      for(int i = 0; i < ls.size();i++){
          Lin l = ls.get(i);
          l.display(currx, curry);
          for(int j = i+1; j < ls.size();j++){
              Lin l2 = ls.get(j);
              if(dist(l2.end.x, l2.end.y, l.end.x, l.end.y) < 30){
  
                  line(l2.end.x, l2.end.y, l.end.x, l.end.y);
              }
          }
  
          if(l.tooFar(currx, curry) || maxd < 2){
              ls.remove(l);
          }
  
      }
      if(transition){
          maxd-=.5;
          if(maxd < 0){
              state = 1;
              transition = false;
          }
      }
      nx+=.02;
  } else if(state == 1){
  
      fill(255, 255, 169);
      ellipse(width/2, height/2, maxd, maxd);
      maxd++;
      if(maxd > 100){
          m = new Moon(width/2, height/2, maxd/2, false);
          state = 2;
          mouseBouncers[0] = new HandBouncer(width/2, height/2+200, 20);
          mouseBouncers[1] = new HandBouncer(width/2, height/2+200, 20);
      }
  } else if (state == 2) {
      int starlinecounter = 0;
      for(int i = 0; i < p1stars.size();i++){
          p1stars.get(i).display();
          Vec2 v1 = p1stars.get(i).loc;
  
          for(int j = i+1; j < p1stars.size(); j++){
              Vec2 v2 = p1stars.get(j).loc;
              if(dist(v2.x, v2.y, v1.x, v1.y) < 80){
                  starlinecounter++;
                  line(v2.x, v2.y, v1.x, v1.y);
  
              }
  
          }
      }
      float moonY1 = m.body.getLinearVelocity().y;
      box2d.step();
      float moonY2 = m.body.getLinearVelocity().y;
      if(moonY1 < 0 && moonY2 >= 0){
          Vec2 coord = box2d.getBodyPixelCoord(m.body);
          p1stars.add(new Star(coord));
          for(int i = 0; i < p1stars.size()-1; i++){
              Vec2 s1 = p1stars.get(i).loc;
              if(dist(coord.x, coord.y, s1.x, s1.y) < 80){
                  line(coord.x, coord.y, s1.x, s1.y);
  
              }
          }
      } else if(moonY1 >= 0 && moonY2 < 0){
          Vec2 coord = box2d.getBodyPixelCoord(m.body);
          p1stars.add(new Star(coord));
          for(int i = 0; i < p1stars.size()-1; i++){
              Vec2 s1 = p1stars.get(i).loc;
              if(dist(coord.x, coord.y, s1.x, s1.y) < 80){
                  line(coord.x, coord.y, s1.x, s1.y);
  
              }
          }
  
      }
  
      //b.display();
      m.display();
    if(m.done()){
        m = new Moon(width/2, height/2, maxd/2, false);
    }
  }
  fill(255);
  textSize(20);
  text("connections: " + starlinecounter, width-200, 20);
}

void drawPosition(SkeletonData _s) {
  noStroke();
  fill(0, 100, 255);
  String s1 = str(_s.dwTrackingID);
  text(s1, _s.position.x*width/2, _s.position.y*height/2);
}


void drawHands(SkeletonData _s) {
  // Body
  if(_s.skeletonPositionTrackingState[Kinect.NUI_SKELETON_POSITION_HAND_RIGHT] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    PVector rightHand = _s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_RIGHT];
    mouseBouncers[0].display(rightHand.x * width, rightHand.y * height);
  }
  if(_s.skeletonPositionTrackingState[Kinect.NUI_SKELETON_POSITION_HAND_LEFT] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    PVector leftHand = _s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_LEFT];
    mouseBouncers[1].display(leftHand.x * width, leftHand.y * height);
  }
}

void appearEvent(SkeletonData _s) 
{
  if(state == 0 && !transition) {
    transition = true;
  }
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    bodies.add(_s);
  }
}

void drawSkeleton(PVector[] vectors) {
  // Body
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_HEAD, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
  Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
  Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_SPINE, 
  Kinect.NUI_SKELETON_POSITION_HIP_CENTER);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
  Kinect.NUI_SKELETON_POSITION_HIP_LEFT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
  Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
  Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);

  // Left Arm
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
  Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT, 
  Kinect.NUI_SKELETON_POSITION_WRIST_LEFT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
  Kinect.NUI_SKELETON_POSITION_HAND_LEFT);

  // Right Arm
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);

  // Left Leg
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
  Kinect.NUI_SKELETON_POSITION_KNEE_LEFT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_KNEE_LEFT, 
  Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT, 
  Kinect.NUI_SKELETON_POSITION_FOOT_LEFT);

  // Right Leg
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_HIP_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT);
  DrawBone(vectors, 
  Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_FOOT_RIGHT);
}

void DrawBone(PVector[] vectors, int _j1, int _j2) 
{
  if(_j1 >= vectors.length || _j2 >= vectors.length) {
    return;
  }
  noFill();
  stroke(255, 255, 0);
  if ((vectors[_j1].x != 0 || vectors[_j1].y != 0) && (vectors[_j2].x != 0 || vectors[_j2].y != 0)) {
    line(vectors[_j1].x*width, 
    vectors[_j1].y*height, 
    vectors[_j2].x*width, 
    vectors[_j2].y*height);
  }
}

void disappearEvent(SkeletonData _s) 
{
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.remove(i);
      }
    }
  }
}

void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.get(i).copy(_a);
        break;
      }
    }
  }
}