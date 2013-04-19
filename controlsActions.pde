/**
  Polargraph controller
  Copyright Sandy Noble 2012.

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
  http://code.google.com/p/polargraph/
*/
void button_mode_begin()
{
  button_mode_clearQueue();
}
void numberbox_mode_changeGridSize(float value)
{
  setGridSize(value);
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
  }
}
void numberbox_mode_changeSampleArea(float value)
{
  setSampleArea(value);
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
  }
}
void numberbox_mode_changePixelScaling(float value)
{
  setPixelScalingOverGridSize(value);
}
void minitoggle_mode_showImage(boolean flag)
{
  this.displayingImage = flag;
}
void minitoggle_mode_showVector(boolean flag)
{
  this.displayingVector = flag;
}
void minitoggle_mode_showDensityPreview(boolean flag)
{
  this.displayingDensityPreview = flag;
}
void minitoggle_mode_showQueuePreview(boolean flag)
{
  this.displayingQueuePreview = flag;
}
void minitoggle_mode_showGuides(boolean flag)
{
  this.displayingGuides = flag;
}
void unsetOtherToggles(String except)
{
  for (String name : getAllControls().keySet())
  {
    if (name.startsWith("toggle_"))
    {
      if (name.equals(except))
      {
//        println("not resetting this one.");
      }
      else
      {
        getAllControls().get(name).setValue(0);
      }
    }
  }
}
void button_mode_penUp()
{
  addToCommandQueue(CMD_PENUP + penLiftUpPosition +",END");
}
void button_mode_penDown()
{
  addToCommandQueue(CMD_PENDOWN + penLiftDownPosition +",END");
}
void numberbox_mode_penUpPos(int value)
{
  penLiftUpPosition =  value;
}
void numberbox_mode_penDownPos(int value)
{
  penLiftDownPosition =  value;
}
void button_mode_sendPenliftRange()
{
  addToCommandQueue(CMD_SETPENLIFTRANGE+penLiftDownPosition+","+penLiftUpPosition+",END");
}  
void button_mode_sendPenliftRangePersist()
{
  addToCommandQueue(CMD_SETPENLIFTRANGE+penLiftDownPosition+","+penLiftUpPosition+",1,END");
}  

void numberbox_mode_liveBlurValue(int value)
{
  blurValue =  value;
}
void numberbox_mode_liveSimplificationValue(int value)
{
  liveSimplification =  value;
}
void numberbox_mode_livePosteriseValue(int value)
{
  posterizeValue =  value;
}
void button_mode_liveCaptureFromLive()
{
  webcam_captureCurrentImage();
}
void button_mode_liveClearCapture()
{
  captureShape = null;
}
void button_mode_liveAddCaption()
{
  
}
void numberbox_mode_vectorPathLengthHighPassCutoff(int value)
{
  pathLengthHighPassCutoff =  value;
}

void button_mode_liveConfirmDraw()
{
  if (captureShape != null)
  {
    confirmedDraw = true;
    
    // work out scaling and position
    float scaling = getDisplayMachine().inMM(getDisplayMachine().getPictureFrame().getWidth()) / captureShape.getWidth();
    PVector position = new PVector(getDisplayMachine().inMM(getDisplayMachine().getPictureFrame().getPosition().x), 
    getDisplayMachine().inMM(getDisplayMachine().getPictureFrame().getPosition().y));
  
    sendVectorShapes(captureShape, scaling, position, PATH_SORT_CENTRE_FIRST);
    button_mode_penUp();

    //  save shape as SVG
    webcam_saveShape(captureShape);
  }
}  


void toggle_mode_inputBoxTopLeft(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_INPUT_BOX_TOP_LEFT);
    setMode(MODE_INPUT_BOX_TOP_LEFT);
  }
  else
    currentMode = "";
}
void toggle_mode_inputBoxBotRight(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_INPUT_BOX_BOT_RIGHT);
    setMode(MODE_INPUT_BOX_BOT_RIGHT);
    // unset topleft
  }
  else
    currentMode = "";
}
void button_mode_drawOutlineBox()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
    sendOutlineOfBox();
}
void button_mode_drawOutlineBoxRows()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendOutlineOfRows(pixels, DRAW_DIR_SE);
  }
}
void button_mode_drawShadeBoxRowsPixels()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendOutlineOfPixels(pixels);
  }
}
void toggle_mode_drawToPosition(boolean flag)
{
  // unset other toggles
  if (flag)
  {
    unsetOtherToggles(MODE_DRAW_TO_POSITION);
    setMode(MODE_DRAW_TO_POSITION);
  }
}
void button_mode_renderSquarePixel()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendSquarePixels(pixels);
  }
}
void button_mode_renderSawPixel()
{
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendSawtoothPixels();
}
void button_mode_renderCirclePixel()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendCircularPixels(pixels);
  }
}
void button_mode_renderVectors()
{
  // turn off vector view and turn queue preview on
  //minitoggle_mode_showVector(false);
  minitoggle_mode_showQueuePreview(true);
  println("here");
  sendVectorShapes();
}

void toggle_mode_setPosition(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_SET_POSITION);
    setMode(MODE_SET_POSITION);
  }
}

void button_mode_returnToHome()
{
  // lift pen
  button_mode_penUp();
  PVector pgCoords = getDisplayMachine().asNativeCoords(getHomePoint());
  sendMoveToNativePosition(false, pgCoords);
}

void button_mode_drawTestPattern()
{
  sendTestPattern();
}

void button_mode_drawGrid()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendGridOfBox(pixels);
  }
}
void button_mode_loadImage()
{
  if (getDisplayMachine().getImage() == null)
  {
    loadImageWithFileChooser();
    if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
    {
      getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    }
  }
  else
  {
    getDisplayMachine().setImage(null);
    getDisplayMachine().setImageFilename(null);
  }
}
void button_mode_loadVectorFile()
{
  if (getVectorShape() == null)
  {
    loadVectorWithFileChooser();
    minitoggle_mode_showVector(true);
  }
  else
  {
    vectorShape = null;
    vectorFilename = null;
  }
}
void numberbox_mode_pixelBrightThreshold(float value)
{
  pixelExtractBrightThreshold = int(value+0.5);
}
void numberbox_mode_pixelDarkThreshold(float value)
{
  pixelExtractDarkThreshold = int(value+0.5);
}

void button_mode_pauseQueue()
{
}
void button_mode_runQueue()
{
}
void button_mode_clearQueue()
{
  resetQueue();
}
void button_mode_setPositionHome()
{
  sendSetHomePosition();
}
void button_mode_drawTestPenWidth()
{
  sendTestPenWidth();
}
void button_mode_renderScaledSquarePixels()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendScaledSquarePixels(pixels);
  }
}
void button_mode_renderSolidSquarePixels()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendSolidSquarePixels(pixels);
  }
}
void button_mode_renderScribblePixels()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendScribblePixels(pixels);
  }
}
void button_mode_changeMachineSpec()
{
  sendMachineSpec();
}
void button_mode_requestMachineSize()
{
  sendRequestMachineSize();
}
void button_mode_resetMachine()
{
  sendResetMachine();
}
void button_mode_saveProperties()
{
  savePropertiesFile();
  // clear old properties.
  props = null;
  loadFromPropertiesFile();
}
void button_mode_saveAsProperties()
{
  saveNewPropertiesFileWithFileChooser();
}
void button_mode_loadProperties()
{
  loadNewPropertiesFilenameWithFileChooser();
}
void toggle_mode_moveImage(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_MOVE_IMAGE);
    setMode(MODE_MOVE_IMAGE);
  }
  else
  {
    setMode("");
  }
}

void toggle_mode_chooseChromaKeyColour(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_CHOOSE_CHROMA_KEY_COLOUR);
    setMode(MODE_CHOOSE_CHROMA_KEY_COLOUR);
  }
  else
    setMode("");
}

void button_mode_convertBoxToPictureframe()
{
  setPictureFrameDimensionsToBox();
}
void button_mode_selectPictureframe()
{
  setBoxToPictureframeDimensions();
}
void button_mode_exportQueue()
{
  exportQueueToFile();
}
void button_mode_importQueue()
{
  importQueueFromFile();
}
void toggle_mode_drawDirect(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_DRAW_DIRECT);
    setMode(MODE_DRAW_DIRECT);
  }
}

void numberbox_mode_resizeImage(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  Rectangle r = getDisplayMachine().getImageFrame();
  float ratio = r.getHeight() / r.getWidth();

  float oldSize = r.getSize().x;
  
  r.getSize().x = steps;
  r.getSize().y = steps * ratio;

  float difference = (r.getSize().x / 2.0)-(oldSize/2.0);
  r.getPosition().x -= difference;
  r.getPosition().y -= difference * ratio;
  
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), getSampleArea());
}

void numberbox_mode_resizeVector(float value)
{
  if (getVectorShape() != null)
  {
    // get current size of vector in local coordinates
    PVector oldVectorSize = new PVector(getVectorShape().width, getVectorShape().height);
    oldVectorSize = PVector.mult(oldVectorSize, (vectorScaling/100));
    // and current centre point of vector
    PVector oldCentroid = new PVector(oldVectorSize.x / 2.0, oldVectorSize.y / 2.0);
    
    // get newly scaled size of vector
    PVector newVectorSize = new PVector(getVectorShape().width, getVectorShape().height);
    newVectorSize = PVector.mult(newVectorSize, (value/100));
    // and new centre point of vector
    PVector newCentroid = new PVector(newVectorSize.x / 2.0, newVectorSize.y / 2.0);
    
    // difference is current centre minus new centre
    PVector difference = PVector.sub(oldCentroid, newCentroid);
    
    // add difference onto vector position
    PVector newVectorPosition = PVector.add(vectorPosition, difference);
    vectorPosition = newVectorPosition;
  }
  
  vectorScaling = value;
  
}
void toggle_mode_moveVector(boolean flag)
{
  // unset other toggles
  if (flag)
  {
    unsetOtherToggles(MODE_MOVE_VECTOR);
    setMode(MODE_MOVE_VECTOR);
  }
  else
  {
    setMode("");
  }
}

void numberbox_mode_changeMachineWidth(float value)
{
  clearBoxVectors();
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getSize().x = steps;
}
void numberbox_mode_changeMachineHeight(float value)
{
  clearBoxVectors();
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getSize().y = steps;
}
void numberbox_mode_changeMMPerRev(float value)
{
  clearBoxVectors();
  getDisplayMachine().setMMPerRev(value);
}
void numberbox_mode_changeStepsPerRev(float value)
{
  clearBoxVectors();
  getDisplayMachine().setStepsPerRev(value);
}
void numberbox_mode_changeStepMultiplier(float value)
{
  machineStepMultiplier = (int) value;
}
void numberbox_mode_changeMinVectorLineLength(float value)
{
  minimumVectorLineLength = (int) value;
}
void numberbox_mode_changePageWidth(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().setWidth(steps);
}
void numberbox_mode_changePageHeight(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().setHeight(steps);
}
void numberbox_mode_changePageOffsetX(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().getTopLeft().x = steps;
}
void numberbox_mode_changePageOffsetY(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().getTopLeft().y = steps;
}
void button_mode_changePageOffsetXCentre()
{
  float pageWidth = getDisplayMachine().getPage().getWidth();
  float machineWidth = getDisplayMachine().getSize().x;
  float diff = (machineWidth - pageWidth) / 2.0;
  getDisplayMachine().getPage().getTopLeft().x = diff;
  initialiseNumberboxValues(getAllControls());
}

void numberbox_mode_changeHomePointX(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getHomePoint().x = steps;
}
void numberbox_mode_changeHomePointY(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getHomePoint().y = steps;
}
void button_mode_changeHomePointXCentre()
{
  float halfWay = getDisplayMachine().getSize().x / 2.0;
  getHomePoint().x = halfWay;
  getHomePoint().y = getDisplayMachine().getPage().getTop();
  initialiseNumberboxValues(getAllControls());
}


void numberbox_mode_changePenWidth(float value)
{
  currentPenWidth =  Math.round(value*100.0)/100.0;
}
void button_mode_sendPenWidth()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  
  df.applyPattern("###.##");
  addToRealtimeCommandQueue(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
}  

void numberbox_mode_changePenTestStartWidth(float value)
{
  testPenWidthStartSize = Math.round(value*100.0)/100.0;
}
void numberbox_mode_changePenTestEndWidth(float value)
{
  testPenWidthEndSize = Math.round(value*100.0)/100.0;
}
void numberbox_mode_changePenTestIncrementSize(float value)
{
  testPenWidthIncrementSize = Math.round(value*100.0)/100.0;
}

void numberbox_mode_changeMachineMaxSpeed(float value)
{
  currentMachineMaxSpeed =  Math.round(value*100.0)/100.0;
}
void numberbox_mode_changeMachineAcceleration(float value)
{
  currentMachineAccel =  Math.round(value*100.0)/100.0;
}
void button_mode_sendMachineSpeed()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  

  df.applyPattern("###.##");
  addToRealtimeCommandQueue(CMD_SETMOTORSPEED+df.format(currentMachineMaxSpeed)+",END");

  df.applyPattern("###.##");
  addToRealtimeCommandQueue(CMD_SETMOTORACCEL+df.format(currentMachineAccel)+",END");
}

void button_mode_sendMachineSpeedPersist()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  

  df.applyPattern("###.##");
  addToCommandQueue(CMD_SETMOTORSPEED+df.format(currentMachineMaxSpeed)+",1,END");

  df.applyPattern("###.##");
  addToCommandQueue(CMD_SETMOTORACCEL+df.format(currentMachineAccel)+",1,END");
}

void button_mode_sendRoveArea()
{
  if (isBoxSpecified())
  {
    addToCommandQueue(CMD_SET_ROVE_AREA+(long)boxVector1.x+","+(long)boxVector1.y+","
    +(long)(boxVector2.x-boxVector1.x)+","+(long)(boxVector2.y-boxVector1.y)+",END");
  }
}

void toggle_mode_sendStartText(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_SEND_START_TEXT);
    setMode(MODE_SEND_START_TEXT);
  }
  else
  {
    setMode("");
  }
}

void button_mode_startSwirling()
{
  addToCommandQueue(CMD_SWIRLING+"1,END");
}
void button_mode_stopSwirling()
{
  addToCommandQueue(CMD_SWIRLING+"0,END");
}
void setMode(String m)
{
  lastMode = currentMode;
  currentMode = m;
}
void revertToLastMode()
{
  currentMode = lastMode;
}

/*------------------------------------------------------------------------
    Details about the "serial port" subwindow
------------------------------------------------------------------------*/

void button_mode_serialPortDialog()
{
  ControlWindow serialPortWindow = cp5.addControlWindow("changeSerialPortWindow",100,100,150,150);
  serialPortWindow.hideCoordinates();
  
  serialPortWindow.setBackground(getBackgroundColour());
  Radio r = cp5.addRadio("radio_serialPort",10,10);
  r.setWindow(serialPortWindow);

  String[] ports = Serial.list();
  if (getSerialPortNumber() >= 0 && getSerialPortNumber() < ports.length)
    r.setValue(getSerialPortNumber());
    
  r.add("setup", -2);
  r.add("No serial connection", -1);
  
  for (int i = 0; i < ports.length; i++)
  {
    r.add(ports[i], i);
  }
  
  int portNo = getSerialPortNumber();
  if (portNo > -1 && portNo < ports.length)
    r.activate(ports[portNo]);
  else
    r.activate("No serial connection");
    
  r.removeItem("setup");
}

void radio_serialPort(int newSerialPort) 
{
  if (newSerialPort == -2)
  {
  }
  else if (newSerialPort == -1)
  {
    println("Disconnecting serial port.");
    useSerialPortConnection = false;
    if (myPort != null)
    {
      myPort.stop();
      myPort = null;
    }
    drawbotReady = false;
    drawbotConnected = false;
    serialPortNumber = newSerialPort;
  }
  else if (newSerialPort != getSerialPortNumber())
  {
    println("About to connect to serial port in slot " + newSerialPort);
    // Print a list of the serial ports, for debugging purposes:
    if (newSerialPort < Serial.list().length)
    {
      try 
      {
        drawbotReady = false;
        drawbotConnected = false;
        if (myPort != null)
        {
          myPort.stop();
          myPort = null;
        }
        if (getSerialPortNumber() >= 0)
          println("closing " + Serial.list()[getSerialPortNumber()]);
        
        serialPortNumber = newSerialPort;
        String portName = Serial.list()[serialPortNumber];
  
        myPort = new Serial(this, portName, getBaudRate());
        //read bytes into a buffer until you get a linefeed (ASCII 10):
        myPort.bufferUntil('\n');
        useSerialPortConnection = true;
        println("Successfully connected to port " + portName);
      }
      catch (Exception e)
      {
        println("Attempting to connect to serial port in slot " + getSerialPortNumber() 
        + " caused an exception: " + e.getMessage());
      }
    }
    else
    {
      println("No serial ports found.");
      useSerialPortConnection = false;
    }
  }
  else
  {
    println("no serial port change.");
  }
}


/*------------------------------------------------------------------------
    Details about the "machine store" subwindow
------------------------------------------------------------------------*/

ControlWindow dialogWindow = null;

void button_mode_machineStoreDialog()
{
  this.dialogWindow = cp5.addControlWindow("chooseStoreFilenameWindow",100,100,450,150);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  Textfield filenameField = cp5.addTextfield("storeFilename",20,20,150,20);
  filenameField.setText(getStoreFilename());
  filenameField.setLabel("Filename to store to");
  filenameField.setWindow(dialogWindow);

  Button submitButton = cp5.addButton("submitStoreFilenameWindow",0,180,20,60,20);
  submitButton.setLabel("Submit");
  submitButton.setWindow(dialogWindow);

  Toggle overwriteToggle = cp5.addToggle("toggleAppendToFile",true,180,50,20,20);
  overwriteToggle.setCaptionLabel("Overwrite existing file");
  overwriteToggle.setWindow(dialogWindow);

  filenameField.setFocus(true);

}

void storeFilename(String filename)
{
  println("Filename event: "+ filename);
  if (filename != null && filename.length() <= 12)
  {
    setStoreFilename(filename);
    sendMachineStoreMode();
  }
}

void toggleAppendToFile(boolean theFlag) 
{
  setOverwriteExistingStoreFile(theFlag);
}

void submitStoreFilenameWindow(int theValue) 
{
  Textfield tf = (Textfield) cp5.controller("storeFilename");
  tf.submit();
}

void button_mode_machineExecDialog()
{
  this.dialogWindow = cp5.addControlWindow("chooseExecFilenameWindow",100,100,450,150);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  Textfield filenameField = cp5.addTextfield("execFilename",20,20,150,20);
  filenameField.setText(getStoreFilename());
  filenameField.setLabel("Filename to execute from");
  filenameField.setWindow(dialogWindow);

  Button submitButton = cp5.addButton("submitExecFilenameWindow",0,180,20,60,20);
  submitButton.setLabel("Submit");
  submitButton.setWindow(dialogWindow);

  filenameField.setFocus(true);

}

void execFilename(String filename)
{
  println("Filename event: "+ filename);
  if (filename != null && filename.length() <= 12)
  {
    setStoreFilename(filename);
    sendMachineExecMode();
  }
}
void submitExecFilenameWindow(int theValue) 
{
  Textfield tf = (Textfield) cp5.controller("execFilename");
  tf.submit();
}

void button_mode_sendMachineLiveMode()
{
  sendMachineLiveMode();
}





/*------------------------------------------------------------------------
    Details about the "drawing" subwindow
------------------------------------------------------------------------*/
void button_mode_drawPixelsDialog()
{
  this.dialogWindow = cp5.addControlWindow("drawPixelsWindow",100,100,450,150);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  Radio rPos = cp5.addRadio("radio_startPosition",10,10);
  rPos.add("Top-right", DRAW_DIR_NE);
  rPos.add("Bottom-right", DRAW_DIR_SE);
  rPos.add("Bottom-left", DRAW_DIR_SW);
  rPos.add("Top-left", DRAW_DIR_NW);
  rPos.setWindow(dialogWindow);

  Radio rSkip = cp5.addRadio("radio_pixelSkipStyle",10,100);
  rSkip.add("Lift pen over masked pixels", 1);
  rSkip.add("Draw masked pixels as blanks", 2);
  rSkip.setWindow(dialogWindow);

//  Radio rDir = cp5.addRadio("radio_rowStartDirection",100,10);
//  rDir.add("Upwards", 0);
//  rDir.add("Downwards", 1);
//  rDir.setWindow(dialogWindow);

  Radio rStyle = cp5.addRadio("radio_pixelStyle",100,10);
  rStyle.add("Variable frequency square wave", PIXEL_STYLE_SQ_FREQ);
  rStyle.add("Variable size square wave", PIXEL_STYLE_SQ_SIZE);
  rStyle.add("Solid square wave", PIXEL_STYLE_SQ_SOLID);
  rStyle.add("Scribble", PIXEL_STYLE_SCRIBBLE);
  if (currentHardware >= HARDWARE_VER_MEGA)
  {
    rStyle.add("Circles", PIXEL_STYLE_CIRCLE);
    rStyle.add("Sawtooth", PIXEL_STYLE_SAW);
  }
  rStyle.setWindow(dialogWindow);

  Button submitButton = cp5.addButton("submitDrawWindow",0,280,10,120,20);
  submitButton.setLabel("Generate commands");
  submitButton.setWindow(dialogWindow);
  

}

public Integer renderStartPosition = DRAW_DIR_NE; // default top right hand corner for start
public Integer renderStartDirection = DRAW_DIR_SE; // default start drawing in SE direction (DOWN)
public Integer renderStyle = PIXEL_STYLE_SQ_FREQ; // default pixel style square wave
void radio_startPosition(int pos)
{
  this.renderStartPosition = pos;
  radio_rowStartDirection(1);
}
void radio_rowStartDirection(int dir)
{
  if (renderStartPosition == DRAW_DIR_NE || renderStartPosition == DRAW_DIR_SW)
    renderStartDirection = (dir == 0) ? DRAW_DIR_NW : DRAW_DIR_SE;
  else if (renderStartPosition == DRAW_DIR_SE || renderStartPosition == DRAW_DIR_NW)
    renderStartDirection = (dir == 0) ? DRAW_DIR_NE : DRAW_DIR_SW;
}
void radio_pixelStyle(int style)
{
  renderStyle = style;
}
void radio_pixelSkipStyle(int style)
{
  if (style == 1)
    liftPenOnMaskedPixels = true;
  else if (style == 2)
    liftPenOnMaskedPixels = false;
}
void submitDrawWindow(int theValue) 
{
  println("draw.");
  println("Style: " + renderStyle);
  println("Start pos: " + renderStartPosition);
  println("Start dir: " + renderStartDirection);
 
  switch (renderStyle)
  {
    case PIXEL_STYLE_SQ_FREQ: button_mode_renderSquarePixel(); break;
    case PIXEL_STYLE_SQ_SIZE: button_mode_renderScaledSquarePixels(); break;
    case PIXEL_STYLE_SQ_SOLID: button_mode_renderSolidSquarePixels(); break;
    case PIXEL_STYLE_SCRIBBLE: button_mode_renderScribblePixels(); break;
    case PIXEL_STYLE_CIRCLE: button_mode_renderCirclePixel(); break;
    case PIXEL_STYLE_SAW: button_mode_renderSawPixel(); break;
  }
  
   
}

/*------------------------------------------------------------------------
    Details about the "writing" subwindow
------------------------------------------------------------------------*/
String textToWrite = "";
String spriteFilePrefix = "sprite/let";
String spriteFileSuffix = ".txt";

void button_mode_drawWritingDialog()
{
  this.dialogWindow = cp5.addControlWindow("drawWritingWindow",100,100,450,200);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  Textfield spriteFileField = cp5.addTextfield("spriteFilePrefixField",20,20,150,20);
  spriteFileField.setText(getSpriteFilePrefix());
  spriteFileField.setLabel("File prefix");
  spriteFileField.setWindow(dialogWindow);

  Textfield writingField = cp5.addTextfield("textToWriteField",20,60,400,20);
  writingField.setText(getTextToWrite());
  writingField.setLabel("Text to write");
  writingField.setWindow(dialogWindow);

  Button importTextButton = cp5.addButton("importTextButton",0,20,100,120,20);
  importTextButton.setLabel("Load text from file");
  importTextButton.setWindow(dialogWindow);

  Radio rPos = cp5.addRadio("radio_drawWritingDirection",20,140);
//  rPos.add("North-east", DRAW_DIR_NE);
  rPos.add("South-east", DRAW_DIR_SE);
//  rPos.add("South-west", DRAW_DIR_SW);
//  rPos.add("North-west", DRAW_DIR_NW);
  rPos.setWindow(dialogWindow);
  


  Button submitButton = cp5.addButton("submitWritingWindow",0,300,100,120,20);
  submitButton.setLabel("Generate commands");
  submitButton.setWindow(dialogWindow);
}

void spriteFilePrefixField(String value)
{
  spriteFilePrefix = value;
}
void textToWriteField(String value)
{
  textToWrite = value;
}

String getTextToWrite()
{
  return textToWrite;
}
String getSpriteFilePrefix()
{
  return spriteFilePrefix;
}
String getSpriteFileSuffix()
{
  return spriteFileSuffix;
}

void importTextButton()
{
  textToWrite = importTextToWriteFromFile();
  Textfield tf = (Textfield) cp5.controller("textToWriteField");
  tf.setText(getTextToWrite());
  tf.submit();
}


void submitWritingWindow(int theValue) 
{
  println("Write.");
  
  Textfield tf = (Textfield) cp5.controller("spriteFilePrefixField");
  tf.submit();
  tf.setText(getSpriteFilePrefix());
  tf = (Textfield) cp5.controller("textToWriteField");
  tf.submit();
  tf.setText(getTextToWrite());
  
  println("Start dir: " + renderStartDirection);
  println("Sprite file prefix: " + spriteFilePrefix);
  println("Text: " + textToWrite);

  for (int i=0; i<getTextToWrite().length(); i++)
  {
    String filename = getSpriteFilePrefix() + (int) getTextToWrite().charAt(i) + getSpriteFileSuffix();
    addToCommandQueue(CMD_DRAW_SPRITE + int(gridSize * pixelScalingOverGridSize) + "," + filename+",END");
    println(filename);
  }
  
}


/*------------------------------------------------------------------------
    Details about the "sprite" subwindow
------------------------------------------------------------------------*/
String spriteFilename;
int minSpriteSize = 100;
int maxSpriteSize = 500;

void button_mode_drawSpriteDialog()
{
  this.dialogWindow = cp5.addControlWindow("drawSpriteWindow",100,100,450,200);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  delay(200);
  Textfield spriteFilenameField = cp5.addTextfield("spriteFilenameField",20,20,400,20);
  spriteFilenameField.setText("filename.txt");
  spriteFilenameField.setLabel("Sprite filename");
  spriteFilenameField.setWindow(dialogWindow);

  Numberbox minSizeField = cp5.addNumberbox("minimumSpriteSize",20,60,100,20);
  minSizeField.setValue(getMinimumSpriteSize());
  minSizeField.setMin(10);
  minSizeField.setMax(getMaximumSpriteSize());
  minSizeField.setMultiplier(0.5);  
  minSizeField.setLabel("Minimum size");
  minSizeField.setWindow(dialogWindow);

  Numberbox maxSizeField = cp5.addNumberbox("maximumSpriteSize",20,100,100,20);
  maxSizeField.setValue(getMaximumSpriteSize());
  maxSizeField.setMin(getMinimumSpriteSize());
  maxSizeField.setMultiplier(0.5);  
  maxSizeField.setLabel("Maximum size");
  maxSizeField.setWindow(dialogWindow);

  Radio rPos = cp5.addRadio("radio_drawWritingDirection",20,140);
  rPos.add("North-east", DRAW_DIR_NE);
  rPos.add("South-east", DRAW_DIR_SE);
  rPos.add("South-west", DRAW_DIR_SW);
  rPos.add("North-west", DRAW_DIR_NW);
  rPos.setWindow(dialogWindow);
  


  Button submitButton = cp5.addButton("submitSpriteWindow",0,300,100,120,20);
  submitButton.setLabel("Draw sprite");
  submitButton.setWindow(dialogWindow);
}

void radio_drawWritingDirection(int dir)
{
  renderStartDirection = dir;
}

String getSpriteFilename()
{
  return spriteFilename;
}
int getMinimumSpriteSize()
{
  return minSpriteSize;
}
int getMaximumSpriteSize()
{
  return maxSpriteSize;
}

void submitSpriteWindow(int theValue) 
{
  println("Sprite.");
  
  Textfield tf = (Textfield) cp5.controller("spriteFilenameField");
  tf.submit();
  tf.setText(getSpriteFilename());
  
  println("Start dir: " + renderStartDirection);
  println("Filename: " + spriteFilename);

  addToCommandQueue(CMD_DRAW_SPRITE + "," + spriteFilename + "," 
  + getMinimumSpriteSize() + "," + getMaximumSpriteSize() + "," + renderStartDirection + ",END");
  
}


/*------------------------------------------------------------------------
    Details about the "norwegian draw" subwindow
------------------------------------------------------------------------*/
String norwegianExecFilename = "filename.pbm";
int norwegianAmplitude = 20;
int norwegianWavelength = 2;

void button_mode_drawNorwegianDialog()
{
  this.dialogWindow = cp5.addControlWindow("chooseNorwegianFilenameWindow",100,100,450,150);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  Textfield filenameField = cp5.addTextfield("norwegianExecFilename",20,20,150,20);
  filenameField.setText(norwegianExecFilename);
  filenameField.setLabel("Filename to execute from");
  filenameField.setWindow(dialogWindow);

  Numberbox minSizeField = cp5.addNumberbox("norwegianAmplitude",20,60,100,20);
  minSizeField.setValue(norwegianAmplitude);
  minSizeField.setMin(10);
  minSizeField.setMultiplier(0.5);  
  minSizeField.setLabel("Amplitude");
  minSizeField.setWindow(dialogWindow);

  Numberbox maxSizeField = cp5.addNumberbox("norwegianWavelength",20,100,100,20);
  maxSizeField.setValue(norwegianWavelength);
  maxSizeField.setMin(1);
  maxSizeField.setMultiplier(0.5);  
  maxSizeField.setLabel("Wavelength");
  maxSizeField.setWindow(dialogWindow);

  Button outlineButton = cp5.addButton("submitNorwegianExecTraceOutline",0,180,20,80,20);
  outlineButton.setLabel("Trace outline");
  outlineButton.setWindow(dialogWindow);

  Button submitButton = cp5.addButton("submitNorwegianExecFilenameWindow",0,180,100,80,20);
  submitButton.setLabel("Submit");
  submitButton.setWindow(dialogWindow);

  filenameField.setFocus(true);

}

void submitNorwegianExecTraceOutline(int theValue) 
{
  Textfield tf = (Textfield) cp5.controller("norwegianExecFilename");
  tf.submit();
  tf.setText(norwegianExecFilename);
  
  println("Filename:" + norwegianExecFilename);
  
  addToCommandQueue(CMD_DRAW_NORWEGIAN_OUTLINE + norwegianExecFilename + ",END");
}

void submitNorwegianExecFilenameWindow(int theValue) 
{
  Textfield tf = (Textfield) cp5.controller("norwegianExecFilename");
  tf.submit();
  tf.setText(norwegianExecFilename);
  
  println("Filename:" + norwegianExecFilename);
  println("Amplitude:" + norwegianAmplitude);
  println("Wavelength:" + norwegianWavelength);
  
  addToCommandQueue(CMD_DRAW_NORWEGIAN + norwegianExecFilename + ","+norwegianAmplitude+","+norwegianWavelength+",END");
}



