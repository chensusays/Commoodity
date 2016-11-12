#define MAX_HEALTH = 8

uint_32 health;
long time = 0; 
bool buttonPress = false;
int numPresses = 0;
int inPin = 2;         // the number of the input pin
int outPin = 13;       // the number of the output pin
 
void setup() {
  // put your setup code here, to run once:
  pinMode(inPin, INPUT);
  digitalWrite(inPin, HIGH);   // turn on the built in pull-up resistor
  pinMode(outPin, OUTPUT);
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
