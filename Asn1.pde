/* Asn1
 CSC 545
 2/11/2016
 
 DOCUMENTATION:
 Key Press:
   1: Display Original Image
   2: Display the Stretched Image
   3: Display the Equalized Image
   4: Reload Image from fName (also original image)
   h: Display original images histogram
   s: Display stretched images histogram
   e: Display equalized images histogram
   r: Display histogram of current image (if area is selected, this will be displayed in histogram)
  
  Initial load maybe slow. All images are mutated on application start. Images will then be
  toggled hidden/visible pending a key press. Selecting a portion of the image will first
  reset the image to its original state, then perform a stretch on the region.
   
 */
String fName = "CarnivoreLowContrast.bmp";
PImage img, origImg, stretchImg, equalizeImg;
PFont f;
int[] redVals = new int[256]; 
int[] greenVals = new int[256];
int[] blueVals = new int[256];
int[] redEq = new int[256];
int[] greenEq = new int[256];
int[] blueEq = new int[256];
int[] redStretch = new int[256];
int[] greenStretch = new int[256];
int[] blueStretch = new int[256];
int yval, xval;
Boolean isDrawingHistogram = false;
int startX, startY;

void setup() {
  size(400, 400);
  surface.setResizable(true);
  origImg = loadImage(fName);
  img = origImg;
  surface.setSize(img.width, img.height);

  fillArrays();
  stretchImg = stretch(origImg, redVals, greenVals, blueVals, 0, 0, img.width, img.height);
  equalizeImg = equalized(origImg);
  
  //Setup your font here
  f = createFont("Verdana", 48);
  textFont(f);
  fill(255, 255, 0);
  
  //Setup rectangle here
  noFill();
  stroke(255,0,0);
  rectMode(CORNERS);
}

void draw() {

  if (isDrawingHistogram)
  {
    drawHistogram(); 
    drawText();
    surface.setSize(768, 600);
  } 
  else
  {
    surface.setSize(img.width, img.height);
    image(img, 0, 0);
    if(mousePressed)
    {
      rect(startX, startY, mouseX, mouseY); 
    }
  }
}

void mousePressed()
{
   startX = mouseX;
   startY = mouseY;
   img = origImg; // display original image
}

void mouseReleased()
{
   int endX = mouseX, endY = mouseY;
   
   if(startX > mouseX)
   {
     endX = startX;
     startX = mouseX;
   }
   
   if(startY > mouseY)
   {
     endY = startY;
     startY = mouseY;
     
   }
   
   img = stretchArea(img, startX, startY, endX, endY);
}

PImage stretchArea(PImage img, int ax, int ay, int bx, int by)
{
  PImage target = img.get();
  
  redStretch = new int[256];
  greenStretch = new int[256];
  blueStretch = new int[256];
  
  // Fill array for only the area.
  for(int x = ax; x < bx; x++)
  {
    for(int y = ay; y < by; y++)
    {
       color c = target.get(x, y);

        int r = int(red(c));
        int g = int(green(c));
        int b = int(blue(c));
  
        redStretch[r] += 1;
  
        greenStretch[g] += 1;
  
        blueStretch[b] += 1;
    }
  }
  
  // Stretch
  target = stretch(target, redStretch, greenStretch, blueStretch, ax, ay, bx, by);
  
  return target;
}

PImage stretch(PImage img, int[] reds, int[] greens, int[] blues, int m, int n, int o, int p) {
  PImage target = img.get();

  int redMin = 0;
  int greenMin = 0;
  int blueMin = 0;

  int redMax = 255;
  int greenMax = 255;
  int blueMax = 255;

  Boolean foundRed = false, foundGreen = false, foundBlue = false;

  // Get min of each color.
  for (int i = 0; i < 255; i++)
  {
    if (reds[i] != 0 && !foundRed)
    {
      redMin = i - 1; 
      foundRed = true;
    }
    if (greens[i] != 0 && !foundGreen)
    {
      greenMin = i - 1; 
      foundGreen = true;
    }
    if (blues[i] != 0 && !foundBlue)
    {
      blueMin = i - 1; 
      foundBlue = true;
    }    
    if (foundRed && foundGreen && foundBlue)
      break;
  }

  foundRed = false; 
  foundGreen = false;
  foundBlue = false;
  // Get max of each color.
  for (int i = 255; i > 0; i--)
  {
    if (reds[i] != 0 && !foundRed)
    {
      redMax = i + 1; 
      foundRed = true;
    }
    if (greens[i] != 0 && !foundGreen)
    {
      greenMax = i + 1; 
      foundGreen = true;
    }
    if (blues[i] != 0 && !foundBlue)
    {
      blueMax = i + 1; 
      foundBlue = true;
    }
    if (foundRed && foundGreen && foundBlue)
      break;
  } 

  for (int x = m; x < o; x++)
  {
    for (int y = n; y < p; y++)
    {
      color c = img.get(x, y);

      float red = red(c);
      float green = green(c);
      float blue = blue(c);

      red = map(red, redMin, redMax, 0, 255);
      green = map(green, greenMin, greenMax, 0, 255);
      blue = map(blue, blueMin, blueMax, 0, 255);

      color c2 = color(red, green, blue);

      target.set(x, y, c2);
    }
  }

  return target;
}

PImage equalized(PImage img) {
  PImage target = createImage(img.width, img.height, ARGB);

  float totalPixels = img.height * img.width;

  fillArrays();

  for (int i = 1; i < 255; i++)
  {
    redEq[i] = redEq[i-1] + redVals[i];
    greenEq[i] = greenEq[i-1] +  greenVals[i];
    blueEq[i] = blueEq[i-1] +  blueVals[i];
  }

  float multiplier = (255/totalPixels);

  for (int x = 0; x < img.width; x++)
  {
    for (int y = 0; y < img.height; y++)
    {
      color c = img.get(x, y);

      float r = red(c);
      float g = green(c);
      float b = blue(c);     

      int finR = int(redEq[int(r)] * multiplier);
      int finG = int(greenEq[int(g)] * multiplier);
      int finB = int(blueEq[int(b)] * multiplier);

      target.set(x, y, color(finR, finG, finB));
    }
  }
  
  return target;
}

void original() {
  img = origImg;
}

void fillArrays() {
  //println("Begin filling arrays");
  redVals = new int[256]; 
  greenVals = new int[256];
  blueVals = new int[256];

  // Initialize all arrays to 0.
  for (int i = 0; i < 255; i++)
  { // Initialize to 0
    redVals[i] = 0;
    greenVals[i] = 0;
    blueVals[i] = 0;
  }

  for (int x = 0; x < img.width; x++)
  {
    for (int y = 0; y < img.height; y++)
    {
      color c = img.get(x, y);

      int r = int(red(c));
      int g = int(green(c));
      int b = int(blue(c));

      redVals[r] += 1;

      greenVals[g] += 1;

      blueVals[b] += 1;
    }
  }
}

void drawHistogram() {
  //println("Drawing histogram");

  fillArrays();

  surface.setSize(768, 600);
  //img2 = createImage(width, height, RGB);
  background(0);  

  // Get max value of all of the arrays (for mapping). 
  int maxValue = 0;
  for (int i = 0; i < 255; i++)
  {
    if (redVals[i] > maxValue)
    {
      maxValue = redVals[i];
    }
    if (greenVals[i] > maxValue)
    {
      maxValue = greenVals[i];
    }
    if (blueVals[i] > maxValue)
    {
      maxValue = blueVals[i];
    }
  }

  //Red 
  stroke(255, 0, 0);  
  for (int i = 0; i < redVals.length; i++) {
    yval = redVals[i];
    xval = i;

    // map the yval to stay in range.
    yval = int(map(yval, 0, maxValue, 0, height/2));

    line(xval, height, xval, height - yval);
  }
  //Green
  stroke(0, 255, 0);
  for (int i = 0; i < greenVals.length; i++) {
    yval = greenVals[i];
    xval = i + (width/3);

    // map the yval to stay in range.
    yval = int(map(yval, 0, maxValue, 0, height/2));

    line(xval, height, xval, height - yval);
  }

  //Blue
  stroke(0, 0, 255);
  for (int i = 0; i < blueVals.length; i++) {
    yval = blueVals[i];
    xval = i + (2*width/3);

    // map the yval to stay in range.
    yval = int(map(yval, 0, maxValue, 0, height/2));

    line(xval, height, xval, height - yval);
  }
}

void drawText()
{
  //Write histogram bin value & count
  if (mouseX >= 0 && mouseX < width/3) {
    xval = mouseX;
    text("x: " + xval + "; y: " + redVals[xval], 10, 50);
  } else if (mouseX >= width/3 && mouseX < (2*width)/3) {
    xval = mouseX - width/3;
    text("x: " + xval + "; y: " + greenVals[xval], 10, 50);
  } else if (mouseX >= (2*width)/3 && mouseX < width) {
    xval = mouseX - (2*width/3);
    text("x: " + xval + "; y: " + blueVals[xval], 10, 50);
  } 
}

void keyPressed() {
  if (key == '1') 
  {  //Display original image
    isDrawingHistogram = false;   
    img = origImg;
  } 
  else if (key == '2')
  {  //Display stretched image
    isDrawingHistogram = false;
    img = stretchImg;
  } 
  else if (key == '3')
  {  //Display equalized image
    isDrawingHistogram = false;    
    img = equalizeImg;
  } 
  else if (key == 'h' || key == 'H')
  {  //Display original histogram
    isDrawingHistogram = true;
    img = origImg;
  } 
  else if (key == 's' || key == 'S')
  {  //Display stretched histogram
    isDrawingHistogram = true;
    img = stretchImg;
  } 
  else if (key == 'e' || key == 'E')
  {  //Display equalized histogram
    isDrawingHistogram = true;
    img = equalizeImg;
  } 
  else if (key == 'r' || key == 'R')
  {  //Display equalized histogram
    isDrawingHistogram = true;
    
  } 
  else if (key == '4')
  {
    img = loadImage(fName);
    image(img, 0, 0);
  } 
  else if (key == '5')
  {
    isDrawingHistogram = false;
    for (int x = 0; x < img.width; x++)
    {
      for (int y = 0; y < img.height; y++)
      {
        img.set(x, y, color(0, 0, 0));
      }
    }
    image(img, 0, 0);
  }
}