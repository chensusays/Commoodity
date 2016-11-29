import processing.net.*; 

final int speed = 15;

Client c;
boolean inProgress;
String input;
String data[];
float x, y;
float easing = 0.05;

void setup() {
  inProgress = true;
  size(640, 480); 
  //frameRate(5); // Slow it down a little
  // Connect to the server’s IP address and port­
  c = new Client(this, "127.0.0.1", 12345); // Replace with your server’s IP and port
  noStroke();
} 

void draw() {
  if (c.available() > 0) {
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
  }
}