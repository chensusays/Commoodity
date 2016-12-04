import kinect4WinSDK.*;
import java.nio.ByteBuffer;
import java.nio.BufferUnderflowException;
import processing.net.*;
import shiffman.box2d.Box2DProcessing;
import java.util.*;
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
List<Skeleton> bodies;
List<Skeleton> remoteSkeletons;
float maxd = 150;


ArrayList<Lin> ls;
float connectdist;
int state = 2;
boolean transition = false;
float nx = 0;
int currx = 0;
int curry = 0;
Box2DProcessing box2d;
Moon m;
Boundary b;
List<HandBouncer> mouseBouncers;
int starlinecounter;
ArrayList<Star> p1stars;
ArrayList<Star> p2stars;
boolean useClient = false;
boolean useServer = false;
boolean useKinect = true;
int maxStars = 50;

byte[] encodeSkeletons(List<Skeleton> skeletons) {
  int size = 4;
  for(SkeletonData skeleton : skeletons) {
    size += 4 * (3 * skeleton.skeletonPositions.length + 2);
  }
  ByteBuffer buffer = ByteBuffer.allocate(size);
  buffer.putInt(skeletons.size());
  for(SkeletonData skeleton : skeletons) {
    buffer.putInt(skeleton.dwTrackingID);
    buffer.putInt(skeleton.skeletonPositions.length);
    for(int i=0; i<skeleton.skeletonPositions.length; i++) {
      buffer.putFloat(skeleton.skeletonPositions[i].x);
      buffer.putFloat(skeleton.skeletonPositions[i].y);
    }
    for(int status : skeleton.skeletonPositionTrackingState) {
      buffer.putInt(status);
    }
  }
  return buffer.array();
}

List<Skeleton> decodeSkeletons(byte[] data) {
  ByteBuffer buffer = ByteBuffer.allocate(data.length);
  buffer.put(data);
  buffer.flip();
  int size = buffer.getInt();
  if(size < 0 || size > 10) return new ArrayList<Skeleton>();
  List<Skeleton> skeletons = new ArrayList<Skeleton>(size);
  for(int i=0; i<size; i++) {
    Skeleton skeleton = new Skeleton();
    skeleton.dwTrackingID = buffer.getInt();
    int numberOfJoints = buffer.getInt();
    skeleton.skeletonPositions = new PVector[numberOfJoints];
    for(int j=0; j<numberOfJoints; j++) {
      skeleton.skeletonPositions[j] = new PVector();
      skeleton.skeletonPositions[j].x = buffer.getFloat();
      skeleton.skeletonPositions[j].y = buffer.getFloat();
    }
    skeleton.skeletonPositionTrackingState = new int[numberOfJoints];
    for(int j=0; j<numberOfJoints; j++) {
      skeleton.skeletonPositionTrackingState[j] = buffer.getInt();
    }
    skeletons.add(skeleton);
  }
  return skeletons;
}


void setup() {
  mouseBouncers = new LinkedList<HandBouncer>();
  frameRate(60);
  background(255);
  size(640, 480);
  if(useKinect)
    kinect = new Kinect(this);
  smooth();
  bodies = new ArrayList<Skeleton>();
  remoteSkeletons = new ArrayList<Skeleton>();
  stroke(0);
  boolean connected = false;
  if(useServer)
    s = new Server(this, 12345);  // Start a simple server on a port
  while(!connected && useClient) {
    delay(1000);
    c = new Client(this, "127.0.0.1", 12345);
    delay(2000);
    connected = c.active();
  }
  background(0, 0, 70);
  connectdist = 80;
  ls = new ArrayList<Lin>();
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  state = 1;
  p1stars = new ArrayList<Star>();
  p2stars = new ArrayList<Star>();
  b = new Boundary(0, height/2, 10, height*3);
  b = new Boundary(width, height/2, 10, height*3);
  b = new Boundary(width/2, -height, width, 10);
  box2d.setGravity(0, -15);
    
}

void draw() {
  drawMoon();
  if(c != null && c.available() > 0) {
    try {
      List<Skeleton> newSkeletons = decodeSkeletons(c.readBytes());
      for(int i=0; i<remoteSkeletons.size(); i++) {
        boolean skeletonUpdated = false;
        for(int j=0; j<newSkeletons.size(); j++) {
          if(remoteSkeletons.get(i).dwTrackingID == newSkeletons.get(j).dwTrackingID) {
            skeletonUpdated = true;
            remoteSkeletons.get(i).skeletonPositions = newSkeletons.get(j).skeletonPositions;
            remoteSkeletons.get(i).skeletonPositionTrackingState = newSkeletons.get(j).skeletonPositionTrackingState;
            newSkeletons.remove(j);
          }
        }
        if(!skeletonUpdated) {
          remoteSkeletons.remove(i);
        }
      }
      remoteSkeletons.addAll(newSkeletons);
    } catch(BufferUnderflowException e) {}
  }
  
  if(state == 2) {
    for(Skeleton skeleton : remoteSkeletons) {
      skeleton.drawHands();
      skeleton.drawSkeleton(color(0, 255, 255));
    }
    for(Skeleton skeleton : bodies) {
      skeleton.drawHands();
      skeleton.drawSkeleton(color(255, 255, 0));
    }
  }
  if(useServer && bodies.size() > 0)
    s.write(encodeSkeletons(bodies));
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
          maxd-=2;
          if(maxd < 0){
            mouseBouncers[0] = new HandBouncer(width/2, height/2+200, 20);
          mouseBouncers[1] = new HandBouncer(width/2, height/2+200, 20);
              state = 1;
              transition = false;
          }
      }
      nx+=.02;
  } else if(state == 1){
  
      fill(255, 255, 169);
      ellipse(width/2, height/2-200, maxd, maxd);
      maxd++;
      if(maxd > 100){
          m = new Moon(width/2, height/2-200, maxd/2, false);
          state = 2;
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
      //the following checks for a change in y velocity of the moon and then draws a star if it's true;
      if(moonY1 < 0 && moonY2 >= 0){
          Vec2 coord = box2d.getBodyPixelCoord(m.body);
          p1stars.add(new Star(coord));
          if(p1stars.size() > maxStars) {
            p1stars.remove(0);
          }
          for(int i = 0; i < p1stars.size()-1; i++){
              Vec2 s1 = p1stars.get(i).loc;
              if(dist(coord.x, coord.y, s1.x, s1.y) < 80){
                  line(coord.x, coord.y, s1.x, s1.y);
  
              }
          }
      } else if(moonY1 >= 0 && moonY2 < 0){
          Vec2 coord = box2d.getBodyPixelCoord(m.body);
          p1stars.add(new Star(coord));
          if(p1stars.size() > maxStars) {
            p1stars.remove(0);
          }
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
        m = new Moon(width/2, height/2-200, maxd/2, false);
    }
    fill(255);
    textSize(20);
    text("connections: " + starlinecounter, width-200, 20);
  }
  
}

void drawPosition(SkeletonData _s) {
  noStroke();
  fill(0, 100, 255);
  String s1 = str(_s.dwTrackingID);
  text(s1, _s.position.x*width/2, _s.position.y*height/2);
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
    bodies.add(0, new Skeleton(_s));
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