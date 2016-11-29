import processing.net.*;
import org.openkinect.processing.*;

Server s; 
Client c;
String input;
int data[];

KinectTracker tracker;
Kinect kinect;

byte[] toByteArray(int[] intArray) {
  byte[] byteArray = new byte[intArray.length * 3];
  for(int i=0; i < intArray.length; i++) {
    int current = intArray[i];
    for(int j=0; j<3; j++) {
      byteArray[3 * i + j] = (byte) (current & 255);
      current >>>= 8;
    }
  }
  return byteArray;
}

int[] toIntArray(byte[] byteArray) {
  int[] intArray = new int[byteArray.length / 3];
  for(int i=0; i < intArray.length; i++) {
    intArray[i] = 0;
    for(int j=0; j<3; j++) {
      intArray[i] |= ((int) byteArray[3 * j + i]) << (8 * j);
     }
  }
  return intArray;
}

void setup() {
  frameRate(60);
  background(255);
  size(640, 480);
  kinect = new Kinect(this);
  tracker = new KinectTracker(640, 480);
  //background(204);
  stroke(0);
  frameRate(5); // Slow it down a little
  s = new Server(this, 12345);  // Start a simple server on a port
}

void draw() {
  // Show the image
  tracker.track();
  tracker.display();
  /*if (mousePressed == true) {
    // Draw our line
    stroke(255);
    line(pmouseX, pmouseY, mouseX, mouseY); 
    // Send mouse coords to other person
    s.write(pmouseX + " " + pmouseY + " " + mouseX + " " + mouseY + "\n");
  }*/
  
  PVector v = tracker.getLerpedPos();
  s.write(v.x + " " + v.y + "\n");
  System.out.println(v.x + " " + v.y + "\n");
  // Receive data from client
  /*c = s.available();
  if (c != null) {
    input = c.readString(); 
    input = input.substring(0, input.indexOf("\n"));  // Only up to the newline
    data = int(split(input, ' '));  // Split values into an array
    // Draw line using received coords
    stroke(0);
    line(data[0], data[1], data[2], data[3]); 
  }*/
}