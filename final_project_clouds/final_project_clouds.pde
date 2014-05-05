import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
ParticleSystem ps;
midi_to_pretty mtp;

int abs_midi;
float oct_midi;
float frequency;
int zero_crosses;

ArrayList cl;

PImage img;
int blurType=0;

float rouge = random(255);
float vert = random(255);
float bleu = random(255);

int fader = 10;

//SETUP
void setup() {
  background(0);
  size(screen.width, screen.height, P2D);
  frameRate(999);
  smooth();
  img=g.get();
  noStroke();
  cl = new ArrayList(); // defines cloud
  ps = new ParticleSystem(3, rouge, vert, bleu);
  mtp = new midi_to_pretty(0);
  oscP5 = new OscP5(this, 12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  noCursor();
}


void draw() {
  ps.run();
  //do blurring
  loadPixels(); //copy window contents -> pixels[]==g.pixels[]
  fastSmallShittyBlur(g, img
    , 15.0*pow(0.5, 2)
    , 15.0*pow(0.5, 2)
    ); //g=PImage of main window
  image(img, 0, 0); //draw results;
  //println(frameRate);
}



//OSC FUNCTIONS 
void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/midiNotes_and_freq") == true) {
    //println("check 1");
    if (msg.checkTypetag("ffii")) {
      oct_midi = msg.get(0).floatValue();
      frequency = msg.get(1).floatValue();
      abs_midi = msg.get(2).intValue();
      zero_crosses = msg.get(3).intValue();
      mtp.update(oct_midi, abs_midi);
      rouge = mtp.colours[0];
      vert = mtp.colours[1];
      bleu = mtp.colours[2];
      ps.addCloud(rouge, vert, bleu);
      //println(zero_crosses);
      //println(abs_midi + "\t" + oct_midi);
    }
  }
}

//NOTE FROM afb:: this blurring function was found on open processing, and was originally made by "dotlassie"
//i modified it to blur faster, and not to be mouse dependent.  the formula below i didn't change however


/*
Fast: 40 times faster than filter(BLUR,1);
Small: Available only in 1 pixel radius
Shitty: Rounding errors make image dark soon
What happens:
   11111100 11111100 11111100 11111100 = mask == FF-3 = FCFCFCFC
   AAAAAAAA RRRRRRRR GGGGGGGG BBBBBBBB = PImage.pixel[i]
   AAAAAA00 RRRRRR00 GGGGGG00 BBBBBB00 = masked pixel
AA AAAAAARR RRRRRRGG GGGGGGBB BBBBBB00 = sum of four masked pixel, alpha overflows, who cares
   00AAAAAA RRRRRRRR GGGGGGGG BBBBBBBB 00 = shift results to right -> broken alpha, good RGB (rounded down) averages
*/

/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/36882*@* */

void fastSmallShittyBlur(PImage a, PImage b, float hradius, float vradius ) { //a=src, b=dest img
  int pa[]=a.pixels;
  int pb[]=b.pixels;
  int h=a.height;
  int w=a.width;
  int rowStart, rowEnd, y, i;
  int rounding;
  int   hiradius=0, viradius=0;
  float hfradius=0, vfradius=0;

  // TODO: unrandomize, use frameCount if possible for less flicker
  hfradius = random(0, hradius);
  vfradius = random(0, vradius);
  hiradius += floor(hfradius) + ( hfradius%1 > random(0, 1) ? 1:0);
  viradius += floor(vfradius) + ( vfradius%1 > random(0, 1) ? 1:0);

  if ( viradius + hiradius <= 0 ) { 
    arrayCopy( pa, pb ); 
    return;
  }

  int rowStep = w * viradius;

  for ( y = viradius; y < h-viradius; ++y ) { //edge pixels ignored
    rowStart=y*w  +hiradius;
    rowEnd  =y*w+w-hiradius;
    rounding = ((y^frameCount)&1)==0 ? 0x00010101 : 0x00020202; // add +1.5 (average) to prevent darkening, use ? 0xC0010101 : 0xC0020202 to fix 100% alpha if necessary
    for ( i=rowStart; i<rowEnd; ++i ) {
      pb[i]=((
      ( ( pa[i - rowStep  ] & 0x00FCFCFC ) // sum of neighbours only, center pixel ignored
      + ( pa[i + rowStep  ] & 0x00FCFCFC )
        + ( pa[i - hiradius ] & 0x00FCFCFC )
        + ( pa[i + hiradius ] & 0x00FCFCFC )
        )>>2)
        //|0xFF000000 // set opacity to 100%, use this or the rounding value if necessary
      )
        +rounding;
      //pb[i]-=0x020202; // uncomment for glitch mode
    }
  }
}

