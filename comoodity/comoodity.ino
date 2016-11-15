#include <Adafruit_GFX.h>
#include <Adafruit_NeoMatrix.h>
#include <Adafruit_NeoPixel.h>
#include <TimeLib.h>

#define MAX_HEALTH  8
#define TIME_THRESHOLD 10000
#define BRIGHTNESS 35
#define RED matrix.Color(255, 0, 0)
#define WHITE matrix.Color(255, 255, 255)
#define OFF matrix.Color(0, 0, 0)

int health;
unsigned long epoch;
unsigned long last_time;
unsigned long last_time_tilted;
bool buttonPress = false;
bool tilted = false;
int numPresses = 0;
int tiltInPin = 10;         // the number of the tilt sensor's input pin
int buttonInPin = 9;        // the number of the button pin
int outPin = 12;       // the number of the output pin

Adafruit_NeoMatrix matrix = Adafruit_NeoMatrix(8, 8, outPin,
      NEO_MATRIX_TOP     + NEO_MATRIX_RIGHT +
      NEO_MATRIX_COLUMNS + NEO_MATRIX_PROGRESSIVE,
      NEO_GRB            + NEO_KHZ800);

// basic heart outline. Heart border is 1 and inside is 2
const byte heart[8][8] = {
  {0, 0, 0, 0, 0, 0, 0, 0},
  {0, 1, 1, 0, 0, 1, 1, 0},
  {1, 2, 2, 1, 1, 2, 2, 1},
  {1, 2, 2, 2, 2, 2, 2, 1},
  {1, 2, 2, 2, 2, 2, 2, 1},
  {0, 1, 2, 2, 2, 2, 1, 0},
  {0, 0, 1, 2, 2, 1, 0, 0},
  {0, 0, 0, 1, 1, 0, 0, 0},
};

void display_health(int health) {
  for(int i=0; i<8; i++){
    for(int j=0; j<8; j++) {
      uint16_t color;
      if(heart[i][j] == 0) color = OFF;
      else if(j < health) color = RED;
      else if(heart[i][j] == 1) color = WHITE;
      else color = OFF;
      matrix.drawPixel(i, 7-j, color * BRIGHTNESS);
    }
  }
  matrix.show();
}

void setup() {
  // put your setup code here, to run once:
  pinMode(tiltInPin, INPUT);
  pinMode(buttonInPin, INPUT);
  epoch = millis();
  last_time = epoch;
  last_time_tilted = 0;
  health = MAX_HEALTH;
  matrix.begin();
  matrix.setBrightness(BRIGHTNESS);
}

void loop() {
  // put your main code here, to run repeatedly:
  display_health(health);
  unsigned long cur_time = millis();
  tilted = digitalRead(tiltInPin);
  buttonPress = digitalRead(buttonInPin);
  
  if(tilted) {
    //start timer for health regen
    unsigned long tilted_now = millis();

    unsigned long dur = tilted_now - last_time_tilted;
    if(dur > TIME_THRESHOLD) {
      health = health + 1 >= MAX_HEALTH ? MAX_HEALTH : health + 1;
      last_time_tilted = tilted_now;
      display_health(health);
    }
  }  else if(buttonPress) {
    if(numPresses <= 8) {
        health = health + 1 >= MAX_HEALTH ? MAX_HEALTH : health + 1;     //increment health by one
        numPresses++; //increment numPresses by one
        delay(200);
    }
  } else {
    //wait for countdown to reach x time
    cur_time = millis();
    unsigned long dur = cur_time - last_time;

    if(dur >= TIME_THRESHOLD) {
      health = health - 1 <= 0 ? 0 : health - 1;
      last_time = cur_time;
    }
  }
}
