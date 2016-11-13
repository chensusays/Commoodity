#include <Adafruit_GFX.h>
#include <Adafruit_NeoMatrix.h>
#include <Adafruit_NeoPixel.h>

#define MAX_HEALTH = 8
#define BRIGHTNESS 35
#define RED matrix.Color(255, 0, 0)
#define WHITE matrix.Color(255, 255, 255)
#define OFF matrix.Color(0, 0, 0)

uint_32 health;
long time = 0; 
bool buttonPress = false;
int numPresses = 0;
int inPin = 2;         // the number of the input pin
int outPin = 13;       // the number of the output pin

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
      else if(j >= health) color = RED;
      else if(heart[i][j] == 1) color = WHITE;
      else color = OFF;
      matrix.drawPixel(i, j, color * BRIGHTNESS);
    }
  }
}

void setup() {
  // put your setup code here, to run once:
  pinMode(inPin, INPUT);
  digitalWrite(inPin, HIGH);   // turn on the built in pull-up resistor
  pinMode(outPin, OUTPUT);
  matrix.begin();
  matrix.setBrightness(BRIGHTNESS);
}

void loop() {
  // put your main code here, to run repeatedly:
  tilted = false
  buttonPress = digitalRead(2);
  if(tilted) {
    //start timer for health regen
  } else if(buttonPress) {
    health++;
    numPresses++;
    if (numPresses >= 5) {
      numPresses = 0;
      //reset
    }
    //increment health by one
    //increment numPresses by one

  } else {
    //wait for countdown to reach x time
    
  }
}
