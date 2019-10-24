import processing.sound.*;

//Game status
float gameStatus = 0;
int score = 0;

//Sounds
SoundFile bgm;
SoundFile swing;
SoundFile kill;


//avatar Vars
PVector avatarPos = new PVector(230,230);
PVector avatarSpeed = new PVector();
float maxAcc = 2;
PImage[] run = new PImage[4];
PImage[] shot = new PImage[4];
char avatarFacing = 'U';
boolean avatarShooting = false;

//enemy Vars
PVector[] enemyPos = new PVector[10];
PVector[] startingPos = new PVector[12];
boolean[] enemyIsAlive = new boolean[10];
float enemySpeed = 0.8;
PImage swat = new PImage();
ArrayList<PVector> deads = new ArrayList<PVector>();
ArrayList<PImage> bloods = new ArrayList<PImage>();
PImage[] blood = new PImage[9];

//bullet Vars
PVector[] bulletPos = new PVector[20];
boolean[] bulletIsActive = new boolean[20];
char[] bulletFace = new char[20]; //"U","D","L","R"
float bulletSpeed = 6;
PImage shuriken = new PImage();
//Font
PFont font;

//Backgrounds
PImage bg0 = new PImage();
PImage bg1 = new PImage();
PImage bg2 = new PImage();
//All backgrounds are from Stock Photos(TM).

void setup(){
  font = loadFont("midterm.vlw");
  textFont(font);
  smooth();
  enemy_init();
  size(500,500);
  background(255,255,255);
  frameRate(60);
  //load backgrounds
  bg0 = loadImage("ninja-background.jpg");
  bg1 = loadImage("bg-flower.png");
  bg2 = loadImage("bg-sun.png");
  bg0.resize(500,500);
  bg1.resize(500,500);
  bg2.resize(500,500);
  //load music
  bgm = new SoundFile(this,"bgm.wav");
  swing = new SoundFile(this,"swing.mp3");
  kill = new SoundFile(this,"kill.mp3");
  
  //load bullets
  shuriken = loadImage("shuriken.png");
  shuriken.resize(16,16);
  //load avatar
  for(int i=0;i<4;i++){
    run[i] = loadImage("ninja-run-"+i+".png");
    run[i].resize(60,60);
  }
  for(int i=0;i<4;i++){
    shot[i] = loadImage("ninja-shoot-"+i+".png");
    shot[i].resize(60,60);
  }
  for(int i=0;i<9;i++){
    blood[i] = loadImage("blood-splash-"+i+".png");
    blood[i].resize(40,0);
  }
  //load enemy
  swat = loadImage("swat-walk-0.png");
  swat.resize(60,60);
}

void enemy_init(){
  //initial enemy position
  for(int i=1;i<=3;i++){
    startingPos[i-1] = new PVector(125*i,0);
  }
  for(int i=1;i<=3;i++){
    startingPos[i+2] = new PVector(125*i,500);
  }
  for(int i=1;i<=3;i++){
    startingPos[i+5] = new PVector(0,125*i);
  }
  for(int i=1;i<=3;i++){
    startingPos[i+8] = new PVector(500,125*i);
  }
  for(int i=0;i<enemyIsAlive.length;i++){
    enemyIsAlive[i] = true;
    enemyPos[i] = new PVector(startingPos[i].x,startingPos[i].y);
  }
  
  //initial bullet
  for(int i=0;i<bulletIsActive.length;i++){
    bulletIsActive[i] = false;
  }
}

void shoot(PVector Pos){
  if(frameCount%15==0 && keyPressed){
    if(keyCode == UP){
      swing.play();
      int i = 0;
      while(bulletIsActive[i] && i<19){
        i++;
      }
      bulletIsActive[i] = true;
      bulletPos[i] = new PVector(Pos.x-8,Pos.y-8);
      bulletFace[i] = 'U';
      avatarFacing = 'U';
      avatarShooting = true;
    }else if(keyCode == DOWN){
      swing.play();
      int i = 0;
      while(bulletIsActive[i] && i<19){
        i++;
      }
      bulletIsActive[i] = true;
      bulletPos[i] = new PVector(Pos.x-8,Pos.y-8);
      bulletFace[i] = 'D';
      avatarFacing = 'D';
      avatarShooting = true;
    }else if(keyCode == LEFT){
      swing.play();
      int i = 0;
      while(bulletIsActive[i] && i<19){
        i++;
      }
      bulletIsActive[i] = true;
      bulletPos[i] = new PVector(Pos.x-8,Pos.y-8);
      bulletFace[i] = 'L';
      avatarFacing = 'L';
      avatarShooting = true;
    }else if(keyCode == RIGHT){
      swing.play();
      int i = 0;
      while(bulletIsActive[i] && i<19){
        i++;
      }
      bulletIsActive[i] = true;
      bulletPos[i] = new PVector(Pos.x-8,Pos.y-8);
      bulletFace[i] = 'R';
      avatarFacing = 'R';
      avatarShooting = true;
    }else{
      avatarShooting = false;
    }
  }
}

void draw(){
  background(255,255,255);
  //Status:0 - Starting Page
  if(gameStatus == 0){
    bgm.loop();
    background(bg0);
    fill(0,0,0);
    textSize(50);
    text("The Last NINJA",50,240);
    textSize(25);
    text("Press 'I' to see the intro!",90,285);
    fill(255,255,255);
    score = 0;
    if(keyPressed && key == 'i'){
      gameStatus = 0.5;
    }
  }
  //Status:0.5 - intro
  else if(gameStatus == 0.5){
    background(bg0);
    fill(0,0,0);
    textSize(25);
    text("Press 'WASD' to move",100,180);
    text("Press arrow keys to shoot",70,220);
    text("Keep shooting so you won't die",50,260);
    text("Press 'E' to start the game",70,300);
    fill(255,255,255);
    score = 0;
    if(keyPressed && key == 'e'){
      deads = new ArrayList<PVector>();
      bloods = new ArrayList<PImage>();
      enemy_init();
      avatarPos = new PVector(230,230);
      gameStatus = 1;
    }
  }
  
  //Status:1 - Gaming
  
  else if(gameStatus == 1){  
    background(bg1);
    //blood sheds
    for (int i = 0;i<deads.size();i++){
      image(bloods.get(i),deads.get(i).x,deads.get(i).y);
    }
    //Avatar
    if(avatarPos.x>=480){
      avatarPos.x = 0;
    }else if(avatarPos.x<=0){
      avatarPos.x = 480;
    }
    if(avatarPos.y>=480){
      avatarPos.y = 0;
    }else if(avatarPos.y<=0){
      avatarPos.y = 480;
    }
    avatarPos.add(avatarSpeed);
    shoot(avatarPos);
    if(avatarShooting){
      if(avatarFacing == 'U'){
        image(shot[0],avatarPos.x-30,avatarPos.y-30);
      }else if(avatarFacing == 'D'){
        image(shot[1],avatarPos.x-30,avatarPos.y-30);
      }else if(avatarFacing == 'R'){
        image(shot[2],avatarPos.x-30,avatarPos.y-30);
      }else if(avatarFacing == 'L'){
        image(shot[3],avatarPos.x-30,avatarPos.y-30);
      }
    }else{
      if(avatarFacing == 'U'){
        image(run[0],avatarPos.x-30,avatarPos.y-30);
      }else if(avatarFacing == 'D'){
        image(run[1],avatarPos.x-30,avatarPos.y-30);
      }else if(avatarFacing == 'R'){
        image(run[2],avatarPos.x-30,avatarPos.y-30);
      }else if(avatarFacing == 'L'){
        image(run[3],avatarPos.x-30,avatarPos.y-30);
      }
    }
    
    //Bullet
    for(int i=0;i<bulletPos.length;i++){
      if(bulletIsActive[i]){
        //check collision
        for(int j=0;j<enemyPos.length;j++){
          if(collide(20,enemyPos[j],16,bulletPos[i])){
            kill.play();
            enemyIsAlive[j] = false;
            bulletIsActive[i] = false;
            score += 1;
            deads.add(new PVector(enemyPos[j].x-10,enemyPos[j].y-10));
            bloods.add(blood[int(random(0,9))]);
          }
        }
        if(bulletFace[i] == 'U'){
          image(shuriken,bulletPos[i].x,bulletPos[i].y);
          if(bulletPos[i].y>=0){
            bulletPos[i].y-=bulletSpeed;
          }else{
            bulletIsActive[i] = false;
          }
        }else if(bulletFace[i] == 'D'){
          image(shuriken,bulletPos[i].x,bulletPos[i].y);
          if(bulletPos[i].y<=500){
            bulletPos[i].y+=bulletSpeed;
          }else{
            bulletIsActive[i] = false;
          }
        }else if(bulletFace[i] == 'L'){
          image(shuriken,bulletPos[i].x,bulletPos[i].y);
          if(bulletPos[i].x>=0){
            bulletPos[i].x-=bulletSpeed;
          }else{
            bulletIsActive[i] = false;
          }
        }else if(bulletFace[i] == 'R'){
          image(shuriken,bulletPos[i].x,bulletPos[i].y);
          if(bulletPos[i].x<=500){
            bulletPos[i].x+=bulletSpeed;
          }else{
            bulletIsActive[i] = false;
          }
        }
      }
    }
    //Enemy
    for(int i=0;i<enemyPos.length;i++){
      if(enemyIsAlive[i]){
        //check if hit avatar
        if(collide(20,enemyPos[i],20,avatarPos)){
          gameStatus = 2;
        }
        float angle = atan2(avatarPos.y-enemyPos[i].y, avatarPos.x-enemyPos[i].x);
        //rotate sprite(???)
        pushMatrix();
        translate(enemyPos[i].x,enemyPos[i].y);
        rotate(angle+HALF_PI);
        image(swat,-30,-30);
        popMatrix();
        enemyPos[i].x = cos(angle) * enemySpeed + enemyPos[i].x;
        enemyPos[i].y = sin(angle) * enemySpeed + enemyPos[i].y;
        
        
      }else{
        int temp = int(random(0,12));
        enemyPos[i] = new PVector(startingPos[temp].x,startingPos[temp].y);
        enemyIsAlive[i] = true;
      }
    }
    //Score
    fill(0,0,0);
    textSize(20);
    text(score+" Kiru",20,20);
    fill(255,255,255);
  }
  
  //Status:2 - Game Over
  else if(gameStatus == 2){
    background(bg2);
    fill(0,0,0);
    textSize(40);
    text("Game Over!",140,200);
    textSize(30);
    text("your score is: "+score,130,240);
    textSize(20);
    text("Press 'E' to restart!",140,400);
    text("Press 'R' return to the main menu!",70,420);
    fill(255,255,255);
    if(keyPressed){
      if(key=='e'){
        enemy_init();
        deads = new ArrayList<PVector>();
        bloods = new ArrayList<PImage>();
        avatarPos = new PVector(230,230);
        gameStatus = 1;
        score = 0;
      }else if(key == 'r'){
        gameStatus = 0;
      }
    }
  }
}
void keyPressed() {
    if (key == 'w'){ 
      avatarFacing = 'U';
      if(avatarPos.y>=0){
         avatarSpeed.y = -maxAcc;
      }else{
         avatarSpeed.y = 0;
      }
    }
    if (key == 's'){ 
      avatarFacing = 'D';
      if(avatarPos.y<=480){
         avatarSpeed.y = maxAcc;
      }else{
         avatarSpeed.y = 0;
      } 
    }
    if (key == 'a'){
      avatarFacing = 'L';
      if(avatarPos.x>=0){
         avatarSpeed.x = -maxAcc;
      }else{
         avatarSpeed.x = 0;
      }
    }
    if (key == 'd'){
      avatarFacing = 'R';
      if(avatarPos.x<=480){
         avatarSpeed.x = maxAcc;
      }else{
         avatarSpeed.x = 0;
      } 
    }
  
}
 
void keyReleased() {
  if (key == 'w' || key == 's')    { avatarSpeed.y = 0; }
  if (key == 'a' || key == 'd') { avatarSpeed.x = 0; }
}

boolean collide(int Size1,PVector Pos1,int Size2,PVector Pos2){
  if((Pos1.x+Size1>=Pos2.x && Pos1.x<=Pos2.x+Size2)&&(Pos1.y+Size1>=Pos2.y &&  Pos1.y<=Pos2.y+Size2)){
    return true;
  }else{
    return false;
  }
}
