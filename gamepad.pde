ControllIO controllIO;
ControllDevice joypad;

ControllButton buttonA;
ControllButton buttonB;
ControllButton buttonX;
ControllButton buttonY;
ControllButton buttonL;
ControllButton buttonR;

ControllCoolieHat dpad;


String inputDeviceName = "Controller (Xbox 360 Wireless Receiver for Windows)";


String signalFromGamepad = null;

static final String BUTTON_A_RELEASED = "ButtonAReleased";
static final String BUTTON_B_RELEASED = "ButtonBReleased";
static final String BUTTON_L_RELEASED = "ButtonLReleased";
static final String BUTTON_R_RELEASED = "ButtonRReleased";

void gamepad_init()
{
  controllIO = ControllIO.getInstance(this);

  try
  {
    joypad = controllIO.getDevice(inputDeviceName);
    joypad.printButtons();
  
    buttonA = joypad.getButton("Button 0");
    buttonB = joypad.getButton("Button 1");
    buttonX = joypad.getButton("Button 2");
    buttonY = joypad.getButton("Button 3");
    
    buttonL = joypad.getButton("Button 4");
    buttonR = joypad.getButton("Button 5");
    
    buttonA.plug(this, "buttonARelease", ControllIO.ON_RELEASE);
    buttonB.plug(this, "buttonBRelease", ControllIO.ON_RELEASE);
    buttonX.plug(this, "buttonXPress", ControllIO.ON_PRESS);
    buttonX.plug(this, "buttonXRelease", ControllIO.ON_RELEASE);
    buttonY.plug(this, "buttonYRelease", ControllIO.ON_RELEASE);
    
    buttonL.plug(this, "buttonLRelease", ControllIO.ON_RELEASE);
    buttonR.plug(this, "buttonRRelease", ControllIO.ON_RELEASE);
    
    dpad = joypad.getCoolieHat(10);
    dpad.setMultiplier(4);
    dpad.plug(this, "dpadPress", ControllIO.ON_PRESS);
    
  }
  catch (RuntimeException e)
  {
    println("Requested device (" + inputDeviceName + ") not found.");
  }
}

public void buttonARelease()
{
  signalFromGamepad = BUTTON_A_RELEASED;
}
public void buttonBRelease()
{
  signalFromGamepad = BUTTON_B_RELEASED;
}
public void buttonLRelease()
{
  signalFromGamepad = BUTTON_L_RELEASED;
}
public void buttonRRelease()
{
  signalFromGamepad = BUTTON_R_RELEASED;
}

void buttonXPress()
{
  drawingLiveVideo = true;
}
void buttonXRelease()
{
  drawingLiveVideo = false;
}
void buttonYRelease()
{
  flipWebcamImage = !flipWebcamImage;
}

void dpadPress(float x, float y)
{
  println("VAl:" + dpad.getValue());
  float val = dpad.getValue();
  if (val == 2.0)
  {
    liveSimplification--;
    if (liveSimplification < LIVE_SIMPLIFICATION_MIN)
      liveSimplification = LIVE_SIMPLIFICATION_MIN;
  }
  else if (val == 6.0)
  {
    liveSimplification++;
    if (liveSimplification > LIVE_SIMPLIFICATION_MAX)
      liveSimplification = LIVE_SIMPLIFICATION_MAX;
  }
  if (val == 8.0) // left
  {
    pathLengthHighPassCutoff--;
    if (pathLengthHighPassCutoff < PATH_LENGTH_HIGHPASS_CUTOFF_MIN)
      pathLengthHighPassCutoff = PATH_LENGTH_HIGHPASS_CUTOFF_MIN;
  }
  else if (val == 4.0) // right
  {
    pathLengthHighPassCutoff++;
    if (pathLengthHighPassCutoff > PATH_LENGTH_HIGHPASS_CUTOFF_MAX)
      pathLengthHighPassCutoff = PATH_LENGTH_HIGHPASS_CUTOFF_MAX;
  }

  Numberbox n = (Numberbox) getAllControls().get(MODE_LIVE_SIMPLIFICATION_VALUE);
  n.setValue(liveSimplification);
  n.update();

  n = (Numberbox) getAllControls().get(MODE_VECTOR_PATH_LENGTH_HIGHPASS_CUTOFF);
  n.setValue(pathLengthHighPassCutoff);
  n.update();

}

void processGamepadInput()
{
  if (signalFromGamepad != null)
  {
    println("Signal from gamepad:  " + signalFromGamepad);
    if (signalFromGamepad == BUTTON_A_RELEASED)
    {
      if (captureShape == null && !confirmedDraw)
        button_mode_liveCaptureFromLive(); 
      else if (captureShape != null && !confirmedDraw)
        button_mode_liveClearCapture();
      else if (captureShape != null && confirmedDraw)
      {
        button_mode_liveClearCapture();
        button_mode_clearQueue();
        confirmedDraw = false;
      }
    }
    else if (signalFromGamepad == BUTTON_B_RELEASED)
    {
      if (captureShape != null && !confirmedDraw)
        button_mode_liveConfirmDraw();
    }
    else if (signalFromGamepad == BUTTON_L_RELEASED)
    {
      commandQueueRunning = !commandQueueRunning;
    }
    else if (signalFromGamepad == BUTTON_R_RELEASED)
    {
      cp5.tab(TAB_NAME_INPUT).setActive(true);
    } 
      
    // clear the signal  
    signalFromGamepad = null;
  }
  
}
