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
  //frameRate(5); // Slow it down a little
  c = new Client(this, "127.0.0.1", 8080);
  s = new Server(this, 12345);  // Start a simple server on a port
}

void draw() {
  background(0);
  
  if(c != null && c.available() > 0) {
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
  
  if(bodies.size() > 0) {
    SkeletonData skeleton = bodies.get(0);
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


void drawHands(SkeletonData _s) {
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