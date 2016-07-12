/*
* AsteroidAttack
* 
* You will create a retro style space
* shooter game, and learn about how to use classes and functions. In the end you will be able to
* tweak values and rewrite the program to redesign the game so it suits your taste.
*
* (c) 2013-2016 Arduino LLC.
*/

import processing.serial.*;

//Arraylists where we can put our objects
ArrayList<Star> starArr = new ArrayList<Star>(); // Array of stars
ArrayList<Shot> shotArr = new ArrayList<Shot>(); // Array of shots
ArrayList<Asteroid> asteroidArr = new ArrayList<Asteroid>(); // Array of asteroids

// Serial communication
Serial myPort; // Serial port variable
int newLine = 13; // New line character in ASCII
float angleVal; // Stores the incoming angle value
int buttonState; // Stores the incoming button state
String message; // String that stores all incoming data

String [] valArray = new String [2]; // Array to store all incoming values

// Star variables
float nbrOfStars=40; // Number of stars
float starVal; // Used as star counter

//Shot variables
float shotX; // Shot x position
float shotY; // Shot y position
float shotSize; // Shot size

//Asteroid variables
float asteroidX; // Asteroid position x
float asteroidY; // Asteroid position y
float asteroidSize; // Asteroid size
float asteroidSpeed=2; // Asteroid speed
float asteroidMinSize=30; // Min size for random method
float asteroidMaxSize=80; // Max size for random method

// Timer variables
float timeSinceStart; // Time since start

float shotTimer; // Shot timer
float lastShotCheck; // Recording last check
float shotInterval=100; // The interval between shots, in milliseconds

float asteroidTimer; // Asteroid timer
float lastAsteroidCheck; // Recording last check
float asteroidInterval=1000; // The interval between asteroids, in milliseconds

//player variables
float playerWidth=100; // Width of the player
float playerHeight=20; // Height of the player
float playerX; // Player x position
float playerY; // Player y position
float posVar=0; 

void setup()
{
  size(800, 600);
  smooth();
  fill(180);
  noStroke();

  // List all the available serial ports
  println(Serial.list());

  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[2], 9600); 

  // We write an 's' to receive data from Arduino
  myPort.write("s"); 

  // Create stars
  while (starVal<nbrOfStars) {
    createNewStar();
    starVal++;
  }
}

void draw()
{
  // We read the incoming serial message
  serialEvent();  

  // We update the visuals
  updateVisuals(); 

  // We want the following changes to apply to the same matrix only
  pushMatrix();

  // Update player position
  playerPos();

  // Update player rotation
  playerRotation(); 

  // Draw the player
  drawPlayer();
  popMatrix();

  // We make sure to check if any shot hit any asteroid every frame
  checkHits();

  gameController();
} 

void serialEvent() {
  message = myPort.readStringUntil(newLine); // Read from port until new line (ASCII code 13)
  if (message != null) {
    valArray = split(message, ","); // Split message by commas and store in String array 
    angleVal = float(valArray[0]); // Convert to float angeVal
    buttonState = int(valArray[1]); // Convert to int buttonState

    myPort.write("s"); // Write an "s" to receive more data from the board
  }
}

void playerPos() {

  // Add position every frame
  posVar+=angleVal;

  // Center player position in window
  playerX=width/2+posVar;
  playerY=height-100;

  // Limit the X coordinates
  if (playerX <= 0) {
    playerX = 0;
  }
  if (playerX > width) {  
    playerX = width;
  }
  translate(playerX, playerY);
}

void playerRotation() {
  //We add the current
  rotate(radians(angleVal));
}

void drawPlayer() {

  rectMode(CENTER);
  fill(200);

  // Draw the player
  rect(0, 0, playerWidth, playerHeight);
}

void updateVisuals() {

  background(40);

  createStars();
  createShots();
  createAsteroids();
}

void createNewStar() {
  // We add a new star to the star array
  starArr.add(new Star(random(0, width), random(0, height), random(1, 4)));
}

void createStars() {

  translate(0, 0);

  // A for loop that loops through all stars
  for (int i=0; i<starArr.size(); i++) {
    //We create a local instance of the star object
    Star star = starArr.get(i);
    star.move(angleVal);
    star.display();
  }
}

void newShot() {
  // We add a new shot to the shot array
  shotArr.add(new Shot(playerX, playerY));
}

void createShots() {

  translate(0, 0);
  // A for loop that loops through all shots
  for (int j=0; j<shotArr.size(); j++) {

    Shot shot = shotArr.get(j);
    shot.show();
  }
}

void newAsteroid() {

  // We assign the Asteroid a random x position based on zero and full window width 
  float asteroidXPos= random(0, width);

  // We assign the Asteroid a random size based on our min and max values
  float asteroidSize= random(asteroidMinSize, asteroidMaxSize);

  // We add a new asteroid to the asteroid array
  asteroidArr.add(new Asteroid(asteroidXPos, asteroidSpeed, asteroidSize));
}

void createAsteroids() {

  translate(0, 0);
  // A for loop that loops through all asteroids
  for (int k=0; k<asteroidArr.size(); k++) {

    Asteroid asteroid = asteroidArr.get(k);
    asteroid.visualize();
  }
}

void checkHits() {

  // We loop through all shots we have created
  for (int l=0; l<shotArr.size(); l++) {

    // We want to compare each shot with all existing asteroids
    for (int m=0; m<asteroidArr.size(); m++) {

      // We declare a variable to access one shot object of the Class Shot at a time
      Shot shot = shotArr.get(l);

      // We call the functions in the Shot class to return variables for position and size
      shotX=shot.getXPos();
      shotY=shot.getYPos();
      shotSize=shot.getSize();

      // We declare a variable to access one asteroid object of the Class Asteroid at a time
      Asteroid asteroid = asteroidArr.get(m);

      // We call the functions in the Asteroid class to return variables for position and size
      asteroidX=asteroid.getXPos();
      asteroidY=asteroid.getYPos();
      asteroidSize=asteroid.getSize();

      // We check the boundaries using nestled if statements, just like in "Catch the Apple"
      if (asteroidY+asteroidSize>shotY&&asteroidY<shotY+shotSize) {
        if (asteroidX+asteroidSize>shotX&&asteroidX<shotX+shotSize) {

          // Once we know an asteroid has been hit, we set the function asteroidHit() to "true"
          asteroid.asteroidHit(true);

          // We remove the asteroid from the array
          asteroidArr.remove(m);
        } else {
          asteroid.asteroidHit(false);
        }
      }
    }
  }
}

void gameController() {

  // If the button is pressed and the shotTimer variable has reached the interval
  if (buttonState==1&&shotTimer>shotInterval) {
    newShot(); // We add a new shot
    lastShotCheck=timeSinceStart; // We save the current time since start
  } else {
    shotTimer=0; // The timer is reset
  }

  // If the asteroidTimer variable has reached the interval
  if (asteroidTimer>asteroidInterval) {
    newAsteroid(); // We add a new asteroid
    lastAsteroidCheck=timeSinceStart; // We save the current time since start
  } else {
    asteroidTimer=0; // The timer is reset
  }

  timeSinceStart=millis(); // Assign current time
  shotTimer=timeSinceStart-lastShotCheck; // Assign time since last shot
  asteroidTimer=timeSinceStart-lastAsteroidCheck; // Assign time since last asteroid
}