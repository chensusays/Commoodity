
import processing.net.*;
import kinect4WinSDK.*;
import java.nio.ByteBuffer;
import shiffman.box2d.Box2DProcessing;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

import java.util.ArrayList;



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
HandBouncer  mouseBouncer;
int starlinecounter;
ArrayList<Star> p1stars;
ArrayList<Star> p2stars;

final int speed = 15;

Client c;
boolean inProgress;
String input;
String data[];
float x, y;
float easing = 0.05;
Kinect kinect;
ArrayList <SkeletonData> bodies;

void setup() {
  inProgress = true;
  size(640, 480); 
  //frameRate(5); // Slow it down a little
  // Connect to the server’s IP address and port­
  c = new Client(this, "150.212.31.13", 12345); // Replace with your server’s IP and port
  noStroke();
} 

void draw() {
  /**if (c.available() > 0) {
    background(51);
    inProgress = true;
    input = c.readString(); 
    input = input.substring(0,input.indexOf("\n"));  // Only up to the newline
    data = split(input, ' ');  // Split values into an array
    float targetX = Float.parseFloat(data[0]);
    float dx = targetX - x;
    x += dx * easing;
    
    float targetY = Float.parseFloat(data[1]);
    float dy = targetY - y;
    y += dy * easing;
    ellipse(x, y, 30, 30);
  }**/
  if(c.available() > 0) {
    background(0);
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
    drawSkeleton(vectors);
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

void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    bodies.add(_s);
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