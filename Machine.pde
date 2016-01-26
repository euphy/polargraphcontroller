/**
  Polargraph controller
  Copyright Sandy Noble 2015.

  This file is part of Polargraph Controller.

  Polargraph Controller is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Polargraph Controller is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Polargraph Controller.  If not, see <http://www.gnu.org/licenses/>.
    
  Requires the excellent ControlP5 GUI library available from http://www.sojamo.de/libraries/controlP5/.
  Requires the excellent Geomerative library available from http://www.ricardmarxer.com/geomerative/.
  
  This is an application for controlling a polargraph machine, communicating using ASCII command language over a serial link.

  sandy.noble@gmail.com
  http://www.polargraph.co.uk/
  https://github.com/euphy/polargraphcontroller
*/
/**
*
*
*
*/
class Machine
{
  protected PVector machineSize = new PVector(4000,6000);

  protected Rectangle page = new Rectangle(1000,1000,2000,3000);
  protected Rectangle imageFrame = new Rectangle(1500,1500,1000,1000);
  protected Rectangle pictureFrame = new Rectangle(1600,1600,800,800);

  protected Float stepsPerRev = 200.0;
  protected Float mmPerRev = 95.0;
  
  protected Float mmPerStep = null;
  protected Float stepsPerMM = null;
  protected Float maxLength = null;
  protected Float gridSize = 100.0;
  protected List<Float> gridLinePositions = null;
  
  protected PImage imageBitmap = null;
  protected String imageFilename = null;
  
  
  public Machine(Integer width, Integer height, Float stepsPerRev, Float mmPerRev)
  {
    this.setSize(width, height);
    this.setStepsPerRev(stepsPerRev);
    this.setMMPerRev(mmPerRev);
  }
  
  public void setSize(Integer width, Integer height)
  {
    PVector s = new PVector(width, height);
    this.machineSize = s;
    maxLength = null;
  }
  public PVector getSize()
  {
    return this.machineSize;
  }
  public Float getMaxLength()
  {
    if (maxLength == null)
    {
      maxLength = dist(0,0, getWidth(), getHeight());
    }
    return maxLength;
  }
  
  public void setPage(Rectangle r)
  {
    this.page = r;
  }
  public Rectangle getPage()
  {
    return this.page;
  }
  public float getPageCentrePosition(float pageWidth)
  {
    return (getWidth()- pageWidth/2)/2;
  }

  public void setImageFrame(Rectangle r)
  {
    this.imageFrame = r;
  }

  public Rectangle getImageFrame()
  {
    return this.imageFrame;
  }

  public void setPictureFrame(Rectangle r)
  {  
    this.pictureFrame = r;
  }
  public Rectangle getPictureFrame()
  {
    return this.pictureFrame;
  }
    
  public Integer getWidth()
  {
    return int(this.machineSize.x);
  }
  public Integer getHeight()
  {
    return int(this.machineSize.y);
  }
  
  public void setStepsPerRev(Float s)
  {
    this.stepsPerRev = s;
  }
  public Float getStepsPerRev()
  {
    mmPerStep = null;
    stepsPerMM = null;
    return this.stepsPerRev;
  }
  public void setMMPerRev(Float d)
  {
    mmPerStep = null;
    stepsPerMM = null;
    this.mmPerRev = d;
  }
  public Float getMMPerRev()
  {
    return this.mmPerRev;
  }
  public Float getMMPerStep()
  {
    if (mmPerStep == null)
    {
      mmPerStep = mmPerRev / stepsPerRev;
    }
    return mmPerStep;
  }
  public Float getStepsPerMM()
  {
    if (stepsPerMM == null)
    {
      stepsPerMM = stepsPerRev / mmPerRev;
    }
    return stepsPerMM;
  }
  
  public int inSteps(int inMM) 
  {
    double steps = inMM * getStepsPerMM();
    steps += 0.5;
    int stepsInt = (int) steps;
    return stepsInt;
  }
  
  public int inSteps(float inMM) 
  {
    double steps = inMM * getStepsPerMM();
    steps += 0.5;
    int stepsInt = (int) steps;
    return stepsInt;
  }
  
  public PVector inSteps(PVector mm)
  {
    PVector steps = new PVector(inSteps(mm.x), inSteps(mm.y));
    return steps;
  }
  
  public int inMM(float steps) 
  {
    double mm = steps / getStepsPerMM();
    mm += 0.5;
    int mmInt = (int) mm;
    return mmInt;
  }
  
  public PVector inMM (PVector steps)
  {
    PVector mm = new PVector(inMM(steps.x), inMM(steps.y));
    return mm;
  }
  
  float getPixelBrightness(PVector pos, float dim, float scalingFactor)
  {
    float averageBrightness = 255.0;
    
    if (getImageFrame().surrounds(pos))
    {
      // offset it by image position to get position over image
      PVector offsetPos = PVector.sub(pos, getImageFrame().getPosition());
      int originX = (int) offsetPos.x;
      int originY = (int) offsetPos.y;
      
      PImage extractedPixels = null;

      extractedPixels = getImage().get(int(originX*scalingFactor), int(originY*scalingFactor), 1, 1);
      extractedPixels.loadPixels();
      
      if (dim >= 2)
      {
        int halfDim = (int)dim / (int)2.0;
        
        // restrict the sample area from going off the top/left edge of the image
        float startX = originX - halfDim;
        float startY = originY - halfDim;
        
        if (startX < 0)
          startX = 0;
          
        if (startY < 0)
          startY = 0;
  
        // and do the same for the bottom / right edges
        float endX = originX+halfDim;
        float endY = originY+halfDim;
        
        if (endX > getImageFrame().getWidth())
          endX = getImageFrame().getWidth();
          
        if (endY > getImageFrame().getHeight())
          endY = getImageFrame().getHeight();
  
        // now convert end coordinates to width/height
        float dimWidth = (endX - startX)*scalingFactor;
        float dimHeight = (endY - startY)*scalingFactor;
        
        dimWidth = (dimWidth < 1.0) ? 1.0 : dimWidth;
        dimHeight = (dimHeight < 1.0) ? 1.0 : dimHeight;
        startX = int(startX*scalingFactor);
        startY = int(startY*scalingFactor);
        
        // get the block of pixels
        extractedPixels = getImage().get(int(startX), int(startY), int(dimWidth+0.5), int(dimHeight+0.5));
        extractedPixels.loadPixels();
      }

      // going to go through them and total the brightnesses
      int numberOfPixels = extractedPixels.pixels.length;
      float totalPixelBrightness = 0;
      for (int i = 0; i < numberOfPixels; i++)
      {
        color p = extractedPixels.pixels[i];
        float r = brightness(p);
        totalPixelBrightness += r;
      }
      
      // and get an average brightness for all of these pixels.
      averageBrightness = totalPixelBrightness / numberOfPixels;
    }
    
    return averageBrightness;
  }

  color getPixelAtMachineCoords(PVector pos, float scalingFactor)
  {
    if (getImageFrame().surrounds(pos))
    {
      // offset it by image position to get position over image
      PVector offsetPos = PVector.sub(pos, getImageFrame().getPosition());
      int originX = (int) offsetPos.x;
      int originY = (int) offsetPos.y;
      
      PImage centrePixel = null;

      centrePixel = getImage().get(int(originX*scalingFactor), int(originY*scalingFactor), 1, 1);
      centrePixel.loadPixels();
      
      color col = centrePixel.pixels[0];
      return col;
    }
    else 
    {
      return 0;
    }
  }

  boolean isChromaKey(PVector pos, float scalingFactor)
  {
    if (getImageFrame().surrounds(pos))
    {
      color col = getPixelAtMachineCoords(pos, scalingFactor);

      // get pixels from the vector coords
      if (col == chromaKeyColour)
      {
//        println("is chroma key " + red(col) + ", "+green(col)+","+blue(col));
        return true;
      }
      else
      {
//        println("isn't chroma key " + red(col) + ", "+green(col)+","+blue(col));
        return false;
      }
    }
    else return false;
  }
    
  public PVector asNativeCoords(PVector cartCoords)
  {
    return asNativeCoords(cartCoords.x, cartCoords.y);
  }
  public PVector asNativeCoords(float cartX, float cartY)
  {
    float distA = dist(0,0,cartX, cartY);
    float distB = dist(getWidth(),0,cartX, cartY);
    PVector pgCoords = new PVector(distA, distB);
    return pgCoords;
  }
  
  
  public PVector asCartesianCoords(PVector pgCoords)
  {
    float calcX = int((pow(getWidth(), 2) - pow(pgCoords.y, 2) + pow(pgCoords.x, 2)) / (getWidth()*2));
    float calcY = int(sqrt(pow(pgCoords.x,2)-pow(calcX,2)));
    PVector vect = new PVector(calcX, calcY);
    return vect;
  }
  
  public Integer convertSizePreset(String preset)
  {
    Integer result = A3_SHORT;
    if (preset.equalsIgnoreCase(PRESET_A3_SHORT))
      result = A3_SHORT;
    else if (preset.equalsIgnoreCase(PRESET_A3_LONG))
      result = A3_LONG;
    else if (preset.equalsIgnoreCase(PRESET_A2_SHORT))
      result = A2_SHORT;
    else if (preset.equalsIgnoreCase(PRESET_A2_LONG))
      result = A2_LONG;
    else if (preset.equalsIgnoreCase(PRESET_A2_IMP_SHORT))
      result = A2_IMP_SHORT;
    else if (preset.equalsIgnoreCase(PRESET_A2_IMP_LONG))
      result = A2_IMP_LONG;
    else if (preset.equalsIgnoreCase(PRESET_A1_SHORT))
      result = A1_SHORT;
    else if (preset.equalsIgnoreCase(PRESET_A1_LONG))
      result = A1_LONG;
    else
    {
      try
      {
        result = Integer.parseInt(preset);
      }
      catch (NumberFormatException nfe)
      {
        result = A3_SHORT;
      }
    }
    return result;
  }
  
  public void loadDefinitionFromProperties(Properties props)
  {
    // get these first because they are important to convert the rest of them
    setStepsPerRev(getFloatProperty("machine.motors.stepsPerRev", 200.0));
    setMMPerRev(getFloatProperty("machine.motors.mmPerRev", 95.0));
    
    // now stepsPerMM and mmPerStep should have been calculated. It's safe to get the rest.
   
    // machine size
    setSize(inSteps(getIntProperty("machine.width", 600)), inSteps(getIntProperty("machine.height", 800)));
    
    // page size
    String pageWidth = getStringProperty("controller.page.width", PRESET_A3_SHORT);
    float pw = convertSizePreset(pageWidth);
    String pageHeight = getStringProperty("controller.page.height", PRESET_A3_LONG);
    float ph = convertSizePreset(pageHeight);
    PVector pageSize = new PVector(pw, ph);

    // page position
    String pos = getStringProperty("controller.page.position.x", "CENTRE");
    float px = 0.0;
    println("machine size: " + getSize().x + ", " + inSteps(pageSize.x));
    if (pos.equalsIgnoreCase("CENTRE")) {
      px = inMM((getSize().x - pageSize.x) / 2.0);
    }
    else {
      px = getFloatProperty("controller.page.position.x", (int) getDisplayMachine().getPageCentrePosition(pageSize.x));
    }
      
    float py = getFloatProperty("controller.page.position.y", 120);
      
    PVector pagePos = new PVector(px, py);
    Rectangle page = new Rectangle(inSteps(pagePos), inSteps(pageSize));
    setPage(page);

    // bitmap
    setImageFilename(getStringProperty("controller.image.filename", ""));
    loadImageFromFilename(imageFilename);
  
    // image position
    Float offsetX = getFloatProperty("controller.image.position.x", 0.0);
    Float offsetY = getFloatProperty("controller.image.position.y", 0.0);
    PVector imagePos = new PVector(offsetX, offsetY);
//    println("image pos: " + imagePos);
    
    // image size
    Float imageWidth = getFloatProperty("controller.image.width", 500);
    Float imageHeight = getFloatProperty("controller.image.height", 0);
    if (imageHeight == 0) //  default was set
    {
      println("Image height not supplied - creating default.");
      if (getImage() != null)
      {
        float scaling = imageWidth / getImage().width;
        imageHeight = getImage().height * scaling;
      }
      else
        imageHeight = 500.0;
    }
    PVector imageSize = new PVector(imageWidth, imageHeight);
    
    Rectangle imageFrame = new Rectangle(inSteps(imagePos), inSteps(imageSize));
    setImageFrame(imageFrame);

    // picture frame size
    PVector frameSize = new PVector(getIntProperty("controller.pictureframe.width", 200), getIntProperty("controller.pictureframe.height", 200));
    PVector framePos = new PVector(getIntProperty("controller.pictureframe.position.x", 200), getIntProperty("controller.pictureframe.position.y", 200));
    Rectangle frame = new Rectangle(inSteps(framePos), inSteps(frameSize));
    setPictureFrame(frame);
    
    // penlift positions
    penLiftDownPosition = getIntProperty("machine.penlift.down", 90);
    penLiftUpPosition = getIntProperty("machine.penlift.up", 180);
  }
  
  
  public Properties loadDefinitionIntoProperties(Properties props)
  {
    // Put keys into properties file:
    props.setProperty("machine.motors.stepsPerRev", getStepsPerRev().toString());
    props.setProperty("machine.motors.mmPerRev", getMMPerRev().toString());

    // machine width
    props.setProperty("machine.width", Integer.toString((int) inMM(getWidth())));
    // machine.height
    props.setProperty("machine.height", Integer.toString((int) inMM(getHeight())));

    // image filename
    props.setProperty("controller.image.filename", (getImageFilename() == null) ? "" : getImageFilename());

    // image position
    float imagePosX = 0.0;
    float imagePosY = 0.0;
    float imageWidth = 0.0;
    float imageHeight = 0.0;
    if (getImageFrame() != null)
    {
      imagePosX = getImageFrame().getLeft();
      imagePosY = getImageFrame().getTop();
      imageWidth = getImageFrame().getWidth();
      imageHeight = getImageFrame().getHeight();
    }
    props.setProperty("controller.image.position.x", Integer.toString((int) inMM(imagePosX)));
    props.setProperty("controller.image.position.y", Integer.toString((int) inMM(imagePosY)));

    // image size
    props.setProperty("controller.image.width", Integer.toString((int) inMM(imageWidth)));
    props.setProperty("controller.image.height", Integer.toString((int) inMM(imageHeight)));

    // page size
    // page position
    float pageSizeX = 0.0;
    float pageSizeY = 0.0;
    float pagePosX = 0.0;
    float pagePosY = 0.0;
    if (getPage() != null)
    {
      pageSizeX = getPage().getWidth();
      pageSizeY = getPage().getHeight();
      pagePosX = getPage().getLeft();
      pagePosY = getPage().getTop();
    }
    props.setProperty("controller.page.width", Integer.toString((int) inMM(pageSizeX)));
    props.setProperty("controller.page.height", Integer.toString((int) inMM(pageSizeY)));
    props.setProperty("controller.page.position.x", Integer.toString((int) inMM(pagePosX)));
    props.setProperty("controller.page.position.y", Integer.toString((int) inMM(pagePosY)));

    // picture frame size
    float frameSizeX = 0.0;
    float frameSizeY = 0.0;
    float framePosX = 0.0;
    float framePosY = 0.0;
    if (getPictureFrame() != null)
    {
      frameSizeX = getPictureFrame().getWidth();
      frameSizeY = getPictureFrame().getHeight();
      framePosX = getPictureFrame().getLeft();
      framePosY = getPictureFrame().getTop();
    }
    props.setProperty("controller.pictureframe.width", Integer.toString((int) inMM(frameSizeX)));
    props.setProperty("controller.pictureframe.height", Integer.toString((int) inMM(frameSizeY)));
    
    // picture frame position
    props.setProperty("controller.pictureframe.position.x", Integer.toString((int) inMM(framePosX)));
    props.setProperty("controller.pictureframe.position.y", Integer.toString((int) inMM(framePosY)));
    
    props.setProperty("machine.penlift.down", Integer.toString((int) penLiftDownPosition));
    props.setProperty("machine.penlift.up", Integer.toString((int) penLiftUpPosition));

//    println("framesize: " + inMM(frameSizeX));
    
    return props;
  }

  protected void loadImageFromFilename(String filename)
  {
    if (filename != null && !"".equals(filename))
    {
      // check for format etc here
      println("loading from filename: " + filename);
      try
      {
        this.imageBitmap = loadImage(filename);
        this.imageFilename = filename;
        trace_initTrace(this.imageBitmap);
      }
      catch (Exception e)
      {
        println("Image failed to load: " + e.getMessage());
        this.imageBitmap = null;
      }
      
    }
    else
    {
      this.imageBitmap = null;
      this.imageFilename = null;
    }
  }

  public void sizeImageFrameToImageAspectRatio()
  {
    float scaling = getImageFrame().getWidth() / getImage().width;
    float frameHeight = getImage().height * scaling;
    getImageFrame().getSize().y = frameHeight;
  }
  
  public void setImage(PImage b)
  {
    this.imageBitmap = b;
  }
  public void setImageFilename(String filename)
  {
    this.loadImageFromFilename(filename);
  }
  public String getImageFilename()
  {
    return this.imageFilename;
  }
  public PImage getImage()
  {
    return this.imageBitmap;
  }
  
  public boolean imageIsReady()
  {
    if (imageBitmapIsLoaded())
      return true;
    else
      return false;
  }
  
  public boolean imageBitmapIsLoaded()
  {
    if (getImage() != null)
      return true;
    else
      return false;
  }    

  
  protected void setGridSize(float gridSize)
  {
    this.gridSize = gridSize;
    this.gridLinePositions = generateGridLinePositions(gridSize);
  }
  
  /**
    This takes in an area defined in cartesian steps,
    and returns a set of pixels that are included
    in that area.  Coordinates are specified 
    in cartesian steps.  The pixels are worked out 
    based on the gridsize parameter. d*/
  Set<PVector> getPixelsPositionsFromArea(PVector p, PVector s, float gridSize, float sampleSize)
  {
    
    // work out the grid
    setGridSize(gridSize);
    float maxLength = getMaxLength();
    float numberOfGridlines = maxLength / gridSize;
    float gridIncrement = maxLength / numberOfGridlines;
    List<Float> gridLinePositions = getGridLinePositions(gridSize);

    Rectangle selectedArea = new Rectangle (p.x,p.y, s.x,s.y);

    // now work out the scaling factor that'll be needed to work out
    // the positions of the pixels on the bitmap.    
    float scalingFactor = getImage().width / getImageFrame().getWidth();
    
    // now go through all the combinations of the two values.
    Set<PVector> nativeCoords = new HashSet<PVector>();
    for (Float a : gridLinePositions)
    {
      for (Float b : gridLinePositions)
      {
        PVector nativeCoord = new PVector(a, b);
        PVector cartesianCoord = asCartesianCoords(nativeCoord);
        if (selectedArea.surrounds(cartesianCoord))
        {
          if (isChromaKey(cartesianCoord, scalingFactor))
          {
            nativeCoord.z = MASKED_PIXEL_BRIGHTNESS; // magic number
            nativeCoords.add(nativeCoord);
          }
          else
          {
            if (sampleSize >= 1.0)
            {
              float brightness = getPixelBrightness(cartesianCoord, sampleSize, scalingFactor);
              nativeCoord.z = brightness;
            }
            nativeCoords.add(nativeCoord);
          }
        }
      }
    }
    
    return nativeCoords;
  }
  
  protected PVector snapToGrid(PVector loose, float gridSize)
  {
    List<Float> pos = getGridLinePositions(gridSize);
    boolean higherupperFound = false;
    boolean lowerFound = false;
    
    float halfGrid = gridSize / 2.0;
    float x = loose.x;
    float y = loose.y;
    
    Float snappedX = null;
    Float snappedY = null;
    
    int i = 0;
    while ((snappedX == null || snappedY == null) && i < pos.size())
    {
      float upperBound = pos.get(i)+halfGrid;
      float lowerBound = pos.get(i)-halfGrid;
//      println("pos:" +pos.get(i) + "half: "+halfGrid+ ", upper: "+ upperBound + ", lower: " + lowerBound);
      if (snappedX == null 
        && x > lowerBound 
        && x <= upperBound)
      {
        snappedX = pos.get(i);
//        println("snappedX:" + snappedX);
      }

      if (snappedY == null 
        && y > lowerBound 
        && y <= upperBound)
      {
        snappedY = pos.get(i);
//        println("snappedY:" + snappedY);
      }
            
      i++;
    }
    
    PVector snapped = new PVector((snappedX == null) ? 0.0 : snappedX, (snappedY == null) ? 0.0 : snappedY);
//    println("loose:" + loose);
//    println("snapped:" + snapped);
    return snapped;
  }
  
  protected List<Float> getGridLinePositions(float gridSize)
  {
    setGridSize(gridSize);
    return this.gridLinePositions;
  }
  
  private List<Float> generateGridLinePositions(float gridSize)
  {
    List<Float> glp = new ArrayList<Float>();
    float maxLength = getMaxLength();
    for (float i = gridSize; i <= maxLength; i+=gridSize)
    {
      glp.add(i);
    }
    return glp;
  }

 

}
