//Video Kaleidoscope
//sjbrenner.com

import processing.video.*;

Capture video;
PImage upImg;
PImage downImg;
PGraphics upImgMask;
PGraphics downImgMask;
boolean first = true;
int sourceWidth;
int sourceHeight;
int blockHeight;
int blockWidth;
int cellSpace;
int totalBlockPixels;
int rows;
int cols;
float TWO_PI_OVER_3 = TWO_PI/3;

void setup() {
  size(1000,1000);
  background(0);
  
  sourceWidth = 640;
  sourceHeight = 480;
  
  blockHeight = 73;
  blockWidth = 84;
  totalBlockPixels = blockWidth * blockHeight;
  
  upImg = createImage(blockWidth, blockHeight, RGB);
  downImg = createImage(blockWidth, blockHeight, RGB);
  
  upImg.loadPixels();
  downImg.loadPixels();
  
  upImgMask = createGraphics(blockWidth, blockHeight, JAVA2D);
  downImgMask = createGraphics(blockWidth, blockHeight, JAVA2D);
  
  cellSpace = floor(blockWidth + (blockWidth * cos(PI/3)));
  
  cols = ceil(width / cellSpace) + 2;
  rows = ceil(height / (blockHeight * 2)) + 2;
  
  video = new Capture(this, sourceWidth, sourceHeight, 30);
}

void draw() {
  background(0);
  
  if(first) {
    initMasks();
    first = false;
  }
  
  if(video.available()) {
    generateSourceImages();
    updateMasks();
  }
  
  for(int i = -1; i < cols; i++) {
    for(int j = -1; j < rows; j++) {
      drawHexagonPattern(i * cellSpace, (j * blockHeight * 2) + ((i%2 == 0) ? blockHeight : 0));
    }
  }
}

void generateSourceImages() {
  video.read();
  video.loadPixels();

  int initXPos = floor(map(mouseX, 0, width, 0, sourceWidth - blockWidth));
  int initYPos = floor(map(mouseY, 0, height, 0, sourceHeight - blockHeight));
  int count = 0;
  
  for(int j = 0; j < blockHeight; j++) {
    for(int i = 0; i < blockWidth; i++) {
      int targetX = initXPos + i;
      int targetY = initYPos + j;
      
      color sourcePixel = video.pixels[targetY * sourceWidth + targetX];
      
      upImg.pixels[count] = sourcePixel;
      
      //this code is wrong, not making a mirrored image
      downImg.pixels[((blockHeight - j - 1) * blockWidth) + i] = sourcePixel;
      
      upImg.updatePixels();
      downImg.updatePixels();
      
      count++;
    }
  }
}

void updateMasks() { 
  upImg.mask(upImgMask);
  downImg.mask(downImgMask);
}

void drawHexagonPattern(int offsetX, int offsetY) {
  PImage img;
  
  pushMatrix();
  translate(offsetX + blockWidth, offsetY + blockHeight);
  
  for(int i=0; i<6; i++) {        
    int drawXOffset = -blockWidth;
    int drawYOffset = -blockHeight;
  
    if(i%2==0) {
      img = downImg;
      drawYOffset = 0;
    } else {
      img = upImg;
    }
   
    image(img, drawXOffset, drawYOffset);
    
    if(i%2==1)
      rotate(TWO_PI_OVER_3);
  }
  
  popMatrix();
}

void initMasks() {
    upImgMask.beginDraw();
    upImgMask.smooth();
    upImgMask.background(0);
    upImgMask.fill(255);
    upImgMask.beginShape();
    upImgMask.vertex(0, blockHeight);
    upImgMask.vertex(blockWidth/2, 0);
    upImgMask.vertex(blockWidth, blockHeight);
    upImgMask.endShape(CLOSE);
    upImgMask.endDraw();
    
    downImgMask.beginDraw();
    downImgMask.smooth();
    downImgMask.background(0);
    downImgMask.fill(255);
    downImgMask.beginShape();
    downImgMask.vertex(0, 0);
    downImgMask.vertex(blockWidth/2, blockHeight);
    downImgMask.vertex(blockWidth, 0);
    downImgMask.endShape(CLOSE);
    downImgMask.endDraw();
}

void mousePressed()
{
  save("kaleido_"+ year() + "-" + month() + "-" + day() + "-" + hour() + minute() + second() +".jpg");
}
