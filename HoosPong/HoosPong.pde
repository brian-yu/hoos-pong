// This code is based on eprittinen's instructable code: https://www.instructables.com/Pong-With-Processing/

import processing.serial.*;
Serial myPort;

// Ball and paddle as global objects
Ball ball; 
Paddle paddle;
Paddle secondPaddle;

// Game properties
//int score = 0;          
//int life = 3;           // How many times one can play

//int player2Life = 3;
//int player2Score = 0;

Player player1;
Player player2;

int wallThickness = 20; // Thickness of the left wall
int wallOpacity = 100;  // Used for animation
boolean isGameOn = true;

boolean isMouseMode = false;  // Make this true to use mouse to move the paddle

String myString = null;
float force = 0;
float prevForce = 0;
float up = 0;
float down = 0;
int lf = 10;    // Linefeed in ASCII


void setup() {
  size(800, 600);
  ball = new Ball(width/2, height/2, 30); //create a new ball to the center of the window
  ball.speedX = 5; // Giving the ball speed in x-axis
  ball.speedY = random(-3, 3); // Giving the ball speed in y-axis
  paddle = new Paddle(width-15, height/2, 30, 200);
  secondPaddle = new Paddle(15, height/2, 30, 200);
  
  player1 = new Player(3, paddle);
  player2 = new Player(3, secondPaddle);

  // Serial Connection
  println(Serial.list());  // prints serial port list
  String portName = Serial.list()[3];  // first port from the list. Make sure to have the right serial port
  myPort = new Serial(this, portName, 115200);  // opening the serial port
}

void draw() {
  background(35, 45, 75); //clear canvas

  if (isGameOn)
  {
    //if (wallOpacity > 100) 
    //  wallOpacity = wallOpacity - 5;  

    //color wallColor = color(255, 255, 255, wallOpacity);
    //fill(wallColor);
    //rect(0, 0, wallThickness, height);

    ball.display(); // Draw the ball to the window
    ball.move();    //calculate a new location for the ball
    ball.display(); // Draw the ball on the window
    
    while (myPort.available() > 0) {
      myString = myPort.readStringUntil(lf);
      if (myString != null) {
        
        float[] nums = float(split(myString, ','));
        if (nums.length == 3) {
          prevForce = force;
          force = nums[0];
          up = nums[1];
          down = nums[2];
        }
      }
    }
    //println(force - prevForce);
    //paddle.speedY = (force - prevForce) / 1023;
    
    if (force == 0) {
      paddle.speedY = -10;
    } else {
      paddle.speedY = force / 1023 * 10;
    }
    
    secondPaddle.speedY = down * 10 - up * 10;

    // If paddle is controlled with Mouse
    if (isMouseMode)
      paddle.y = mouseY;
    else // Otherwise, just move the paddle using the paddle speed value   
      paddle.move();
     
    secondPaddle.move();

    paddle.display();
    secondPaddle.display();


    // If the ball's x position is greater than the window width, the player loses a life
    if (ball.right() > width) {   
      player1.dead(ball);
    }
    
    if (ball.left() <= 0) {   
      player2.dead(ball);
    }


    // If the ball hits the ceiling or the floor, it gets bounced. 
    if (ball.bottom() > height) {
      ball.speedY = -ball.speedY;
    }
    if (ball.top() < 0) {
      ball.speedY = -ball.speedY;
    }

    // If the ball hits the wall, it bounces, and the score increases. 
    //if ( ball.left() < wallThickness) {
    //  ball.speedX = -ball.speedX;      
    //  hitWall();
    //}

    // If the ball hits the paddle, it gets bounced.
    if ( ball.right() > paddle.left() && ball.y > paddle.top() && ball.y < paddle.bottom()) {
      ball.speedX = -ball.speedX;
      ball.speedY = map(ball.y - paddle.y, -paddle.h/2, paddle.h/2, -10, 10);
      player1.hit();
    }   
    
    if ( ball.left() < secondPaddle.right() && ball.y > secondPaddle.top() && ball.y < secondPaddle.bottom()) {
      ball.speedX = -ball.speedX;
      ball.speedY = map(ball.y - secondPaddle.y, -secondPaddle.h/2, secondPaddle.h/2, -10, 10);
      player2.hit();
    }   

    textSize(40);
    textAlign(CENTER);
    text("P1 score: " + player1.score, width/2 + 150, 50);
    text("P2 score: " + player2.score, width/2 - 150, 50);
    textSize(20);
    text("P1 lives: " + player1.lives, width/2 + 150, 100);
    text("P2 lives: " + player2.lives, width/2 - 150, 100);
  } else {
    textSize(60);
    textAlign(CENTER);
    String text = (player1.lives == 0) ? "Player 2 won!" : "Player 1 won!";
    text(text, width/2, height/2 - 50);
    textSize(40);
    text("P1 score: " + player1.score, width/2, height/2 + 30);
    text("P2 score: " + player2.score, width/2, height/2 + 80);
    text("To restart, hit SPACE", width/2, height/2 + 130);
  }
}

// handles key press events
void keyPressed() {
  if (keyCode == UP) {
    paddle.speedY=-3;
  }
  if (keyCode == DOWN) {
    paddle.speedY=3;
  }
  if (key == ' ') {
    player1.reset();
    player2.reset();
    isGameOn = true;
  }
}

// handles key release events
void keyReleased() {
  if (keyCode == UP) {
    paddle.speedY=0;
  }
  if (keyCode == DOWN) {
    paddle.speedY=0;
  }
}

//void hitWall() {
//  score++;
//  wallOpacity = 255;
//}

//void dead() {
//  if (life>1) {
//    life --;
//    ball.x = width/2;
//    ball.y = height/2;
//  } else
//    isGameOn=false;
//}

void endGame() {
  isGameOn = false;
}

class Player {
  int maxLives;
  int lives;
  int score;
  Paddle paddle;
  
  Player(int lives, Paddle paddle) {
    this.lives = lives;
    this.maxLives = lives;
    this.score = 0;
    this.paddle = paddle;
  }
  
  void dead(Ball ball) {
    lives--;
    if (lives > 0) {
      ball.x = width/2;
      ball.y = height/2;
    } else {
      isGameOn=false;
    }
  }
  
  void hit() {
    score++;
  }
  
  void reset() {
    score = 0;
    lives = maxLives;
  }
}

class Ball {
  float x;
  float y;
  float speedX;
  float speedY;
  float diameter;
  color c;

  // Constructor method
  Ball(float tempX, float tempY, float tempDiameter) {
    x = tempX;
    y = tempY;
    diameter = tempDiameter;
    speedX = 0;
    speedY = 0;
    c = color(229, 114, 0);
  }

  void move() {
    // Add speed to location
    y = y + speedY;
    x = x + speedX;
  }

  void display() {
    fill(c); //set the drawing color
    ellipse(x, y, diameter, diameter); //draw a circle
  }

  //functions to help with collision detection
  float left() {
    return x-diameter/2;
  }
  float right() {
    return x+diameter/2;
  }
  float top() {
    return y-diameter/2;
  }
  float bottom() {
    return y+diameter/2;
  }
}


class Paddle {

  float x;
  float y;
  float w;
  float h;
  float speedY;
  float speedX;
  color c;

  Paddle(float tempX, float tempY, float tempW, float tempH) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    speedY = 0;
    speedX = 0;
    c=(255);
  }

  void move() {
    y += speedY;
    x += speedX;    

    if (paddle.top() < 0) {
      paddle.y = paddle.h/2;
    }
    if (paddle.bottom() > height) {
      paddle.y = height-paddle.h/2;
    }
  }

  void display() {
    fill(c);
    rect(x-w/2, y-h/2, w, h);
  } 

  //helper functions
  float left() {
    return x-w/2;
  }
  float right() {
    return x+w/2;
  }
  float top() {
    return y-h/2;
  }
  float bottom() {
    return y+h/2;
  }
}
