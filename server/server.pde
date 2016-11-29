import kinect4WinSDK.*;
import java.nio.ByteBuffer;
import processing.net.*;

Server s; 
Client c;
String input;
int data[];

Kinect kinect;
ArrayList <SkeletonData> bodies;

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
  frameRate(60);
  background(255);
  size(640, 480);
  kinect = new Kinect(this);
  smooth();
  bodies = new ArrayList<SkeletonData>();
  stroke(0);
  frameRate(5); // Slow it down a little
  s = new Server(this, 12345);  // Start a simple server on a port
}

void draw() {
  background(0);
  if(bodies.size() > 0) {
    SkeletonData skeleton = bodies.get(0);
    drawSkeleton(skeleton);
    drawPosition(skeleton);
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
  
  // send data
  //s.write();
  //s.write(v.x + " " + v.y + "\n");
  //System.out.println(v.x + " " + v.y + "\n");
}

void drawPosition(SkeletonData _s) {
  noStroke();
  fill(0, 100, 255);
  String s1 = str(_s.dwTrackingID);
  text(s1, _s.position.x*width/2, _s.position.y*height/2);
}


void drawSkeleton(SkeletonData _s) {
  println(_s);
  // Body
  if(_s.skeletonPositionTrackingState[Kinect.NUI_SKELETON_POSITION_HAND_RIGHT] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    PVector rightHand = _s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_RIGHT];
    ellipse(rightHand.x * width, rightHand.y * height, 20, 20);
  }
  if(_s.skeletonPositionTrackingState[Kinect.NUI_SKELETON_POSITION_HAND_LEFT] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    PVector leftHand = _s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_LEFT];
    ellipse(leftHand.x * width, leftHand.y * height, 20, 20);
  }
}

void DrawBone(SkeletonData _s, int _j1, int _j2) 
{
  noFill();
  stroke(255, 255, 0);
  if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
    _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    line(_s.skeletonPositions[_j1].x*width, 
    _s.skeletonPositions[_j1].y*height, 
    _s.skeletonPositions[_j2].x*width, 
    _s.skeletonPositions[_j2].y*height);
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