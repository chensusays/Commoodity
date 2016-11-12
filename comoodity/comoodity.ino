#define MAX_HEALTH = 8

uint_32 health;
uint_32 initTime; 
bool buttonPress;
int numPresses;

void setup() {
  // put your setup code here, to run once:
  initTime = 0;
  numPresses = 0;
  buttonPress = false;
  
}

void loop() {
  // put your main code here, to run repeatedly:
  tilted = false
  if(tilted) {
    //start timer for health regen
  } else if(buttonPress) {
    //increment health by one
    //increment numPresses by one
  } else {
    //wait for countdown to reach x time
    
  }
}
