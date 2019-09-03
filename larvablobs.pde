import processing.video.*;
import blobDetection.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
Minim minim;
AudioOutput out;
Capture cam;
BlobDetection theBlobDetection;
AudioPlayer rain;
AudioPlayer bird;
AudioPlayer colony; 
AudioPlayer mang;
boolean debug = false;
int topRight = 0;
int topLeft = 0;
int bottomLeft = 0;
int bottomRight = 0;
PImage img;
boolean newFrame=false;
float threshold = 0.1;
int creatureCount = 0;
void setup() {
  minim = new Minim(this);
  out = minim.getLineOut();  
  rain = minim.loadFile("rain.mp3", 2048);
  //bird = minim.loadFile("bird.mp3", 2048);
  colony = minim.loadFile("colony31.mp3", 2048);
  mang = minim.loadFile("mangfield.mp3", 2048);
  size(1240, 720);
  String[] cameras = Capture.list();
  cam = new Capture(this, cameras[1]);
  cam.start();
  img = new PImage(80, 60); 
  theBlobDetection = new BlobDetection(img.width, img.height);
  theBlobDetection.setPosDiscrimination(false);
  playIntro();
  rain.loop();
  colony.loop();
  mang.loop();
  //bird.loop();
}
void draw(){
  checkCorner();
  play();
  readFrame();
  blobCalibrate();
}
void play() {
  rain.shiftGain(rain.getGain(), map(bottomLeft, 0, 10, -80, 6), 500);
  colony.shiftGain(colony.getGain(), map(topLeft, 0, 10, -80, 6), 500);
  mang.shiftGain(mang.getGain(), map(bottomRight, 0, 10, -80, 6), 500);

  if (topRight > 1) {
    if (second()%2==0) {
      out.playNote( 6.0, 329.63);
    } else {
      out.playNote( 3.0, 1.9, "E3" );
    }
  }

}
void blobCalibrate() {
  theBlobDetection.setThreshold(threshold);
}
void keyPressed() { 
  out.playNote( "G5" );
  out.playNote( 987.77 );
  if (keyCode==UP) { 
    threshold+=0.01;
  } else if (keyCode==DOWN) {
    threshold-=0.01;
  }
}
// BLOB THINGS
void captureEvent(Capture cam) {
  cam.read();
  newFrame = true;
}
void readFrame() {
  if (newFrame)
  {
    newFrame=false;
    image(cam, 0, 0, width, height);
    img.copy(cam, 0, 0, cam.width, cam.height, 
      0, 0, img.width, img.height);
    theBlobDetection.computeBlobs(img.pixels);
    drawBlobsAndEdges(true, true);
  }
}
void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges)
{
  noFill();
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    b=theBlobDetection.getBlob(n);
    if (b!=null)
    {
      // Edges
      if (drawEdges)
      {
        strokeWeight(3);
        stroke(0, 255, 0);
        for (int m=0; m<b.getEdgeNb(); m++)
        {
          eA = b.getEdgeVertexA(m);
          eB = b.getEdgeVertexB(m);
          if (eA !=null && eB !=null)
            line(
              eA.x*width, eA.y*height, 
              eB.x*width, eB.y*height
              );
        }
      }

      // Blobs
      if (drawBlobs)
      {
        strokeWeight(1);
        stroke(255, 0, 0);
        rect(
          b.xMin*width, b.yMin*height, 
          b.w*width, b.h*height
          );
        if (debug) {
          println("width is: "+ b.w*width+" the height is: "+ b.h*height);
        }
      }
    }
  }
}
// END BLOB 
// AUDIO
void playIntro() {
  out.setTempo( 80 );
  out.playNote( 0.0, 0.9, 97.99 );
  out.playNote( 1.0, 0.9, 123.47 );
  out.playNote( 2.0, 2.9, "C3" );
  out.playNote( 4.0, 0.9, "G3" );
  out.playNote( 5.0, "" );
  out.playNote( 7.0, "G4" );
  out.setNoteOffset( 8.1 );
}
// END AUDIO
// TIMER
void checkCorner() {
  Blob b;
  topLeft = 0;
  topRight = 0;
  bottomLeft = 0;
  bottomRight = 0;

  for (int n=0; n<theBlobDetection.getBlobNb(); n++)
  {
    b=theBlobDetection.getBlob(n);
    if ( b.xMin*width < width/2 && b.yMin*height > height/2) {
      bottomLeft++;
    }
    if ( b.xMin*width > width/2 && b.yMin*height > height/2) {
      bottomRight++;
    }
    if ( b.xMin*width < width/2 && b.yMin*height < height/2) {
      topRight++;
    }
    if ( b.xMin*width < width/2 && b.yMin*height > height/2) {
      topLeft++;
    }
  }
}

void debug() {
  //println(theBlobDetection.getBlobNb());
  println("Bottom left is: "+bottomLeft);
  println("Bottom Right is: "+bottomRight);
  println("Top left is: "+topLeft);
  println("Top Right is: "+topRight);
}