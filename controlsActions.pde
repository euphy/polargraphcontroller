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
  if (value != blurValue)
  {
    blurValue =  value;
    retraceShape = true;
  }
}
void numberbox_mode_liveSimplificationValue(int value)
{
  if (value != liveSimplification)
  {
    liveSimplification =  value;
    retraceShape = true;
  }
}
void numberbox_mode_livePosteriseValue(int value)
{
  if (value != posterizeValue)
  {
    posterizeValue =  value;
    retraceShape = true;
  }
}
void button_mode_liveCaptureFromLive()
{
  trace_captureCurrentImage();
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
    float scaling = getDisplayMachine().inMM(getDisplayMachine().getImageFrame().getWidth()) / captureShape.getWidth();
    PVector position = new PVector(getDisplayMachine().inMM(getDisplayMachine().getImageFrame().getPosition().x), 
    getDisplayMachine().inMM(getDisplayMachine().getImageFrame().getPosition().y));

    int oldPolygonizer = polygonizer;
    polygonizer = RG.ADAPTATIVE;
    setupPolygonizer();  
    sendVectorShapes(captureShape, scaling, position, PATH_SORT_CENTRE_FIRST);
    button_mode_penUp();

    //  save shape as SVG
    trace_saveShape(captureShape);
    polygonizer = oldPolygonizer;
    setupPolygonizer();
  }
} 
void toggle_mode_showWebcamRawVideo(boolean flag)
{
//  drawingLiveVideo = flag;
}
void toggle_mode_flipWebcam(boolean flag)
{
  flipWebcamImage = flag;
}
void toggle_mode_rotateWebcam(boolean flag)
{
  rotateWebcamImage = flag;
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
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendSawtoothPixels(pixels);
  }
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
  pixelExtractBrightThreshold = (int) value;
}
void numberbox_mode_pixelDarkThreshold(float value)
{
  pixelExtractDarkThreshold = (int) value;
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
  float steps = getDisplayMachine().inSteps((int) value);
  getDisplayMachine().getSize().x = steps;
}
void numberbox_mode_changeMachineHeight(float value)
{
  clearBoxVectors();
  float steps = getDisplayMachine().inSteps((int) value);
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
  float steps = getDisplayMachine().inSteps((int) value);
  getDisplayMachine().getPage().setWidth(steps);
}
void numberbox_mode_changePageHeight(float value)
{
  float steps = getDisplayMachine().inSteps((int) value);
  getDisplayMachine().getPage().setHeight(steps);
}
void numberbox_mode_changePageOffsetX(float value)
{
  float steps = getDisplayMachine().inSteps((int) value);
  getDisplayMachine().getPage().getTopLeft().x = steps;
}
void numberbox_mode_changePageOffsetY(float value)
{
  float steps = getDisplayMachine().inSteps((int) value);
  getDisplayMachine().getPage().getTopLeft().y = steps;
}
void button_mode_changePageOffsetXCentre()
{
  float pageWidth = getDisplayMachine().getPage().getWidth();
  float machineWidth = getDisplayMachine().getSize().x;
  float diff = (machineWidth - pageWidth) / 2.0;
  getDisplayMachine().getPage().getTopLeft().x = (int) diff;
  initialiseNumberboxValues(getAllControls());
}

void numberbox_mode_changeHomePointX(float value)
{
  float steps = getDisplayMachine().inSteps((int) value);
  getHomePoint().x = steps;
}
void numberbox_mode_changeHomePointY(float value)
{
  float steps = getDisplayMachine().inSteps((int) value);
  getHomePoint().y = steps;
}
void button_mode_changeHomePointXCentre()
{
  float halfWay = getDisplayMachine().getSize().x / 2.0;
  getHomePoint().x = (int) halfWay;
  getHomePoint().y = (int) getDisplayMachine().getPage().getTop();
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

void button_mode_selectRoveImageSource()
{
  addToCommandQueue(CMD_SELECT_ROVE_SOURCE_IMAGE+",w1.pbm,END");
}
void button_mode_startMarking()
{
  // C47,<start (1) or stop (0)>,<mark style>,END
  addToCommandQueue(CMD_RENDER_ROVE+",1,1,END");
}
void button_mode_stopMarking()
{
  addToCommandQueue(CMD_RENDER_ROVE+",0,0,END");
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

void button_mode_sendButtonActivate()
{
  addToCommandQueue(CMD_ACTIVATE_MACHINE_BUTTON+",END");
}
void button_mode_sendButtonDeactivate()
{
  addToCommandQueue(CMD_DEACTIVATE_MACHINE_BUTTON+",END");
}

void numberbox_mode_previewCordOffsetValue(int value)
{
  previewCordOffset = value;
  previewQueue(true);
}

void button_mode_cycleDensityPreviewStyle() 
{
  Controller c = cp5.getController(MODE_CYCLE_DENSITY_PREVIEW_STYLE);
  c.setLabel(this.controlLabels.get(MODE_CYCLE_DENSITY_PREVIEW_STYLE) + ": " + densityPreviewStyle);
  
  if (densityPreviewStyle == DENSITY_PREVIEW_STYLE_COUNT) {
    densityPreviewStyle = 0;
  }
  else {
    densityPreviewStyle++;
  }
}

void numberbox_mode_changeDensityPreviewPosterize(int value) {
  if (value < 1) value = 1;
  else if (value > 255) value = 255;
  
  densityPreviewPosterize = value;
}

void minitoggle_mode_previewPixelDensityRange(boolean flag) {
  previewPixelDensityRange = flag;
  println("previewPixelDensityRange: " + previewPixelDensityRange);
}

void numberbox_mode_changePolygonizerLength(float value) {
  polygonizerLength = value;
  setupPolygonizer();
}


void button_mode_cyclePolygonizer() 
{
  
  // this is a bit silly for only two choices
  if (polygonizer == 1) {
    polygonizer = 0;
  }
  else {
    polygonizer++;
  }
  setupPolygonizer();
  Controller c = cp5.getController(MODE_CHANGE_POLYGONIZER);
  c.setLabel(this.controlLabels.get(MODE_CHANGE_POLYGONIZER) + ": " + polygonizer);
}


