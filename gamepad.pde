ControllIO controllIO;
ControllDevice joypad;
ControllCoolieHat cooliehat;
ControllStick leftStick;
ControllStick rightStick;

ControllButton buttonA;
ControllButton buttonB;
ControllButton buttonX;
ControllButton buttonY;

void gamepad_init()
{
  controllIO = ControllIO.getInstance(this);

  joypad = controllIO.getDevice("Controller (Xbox 360 Wireless Receiver for Windows)");
  joypad.printButtons();

  buttonA = joypad.getButton("Button 0");
  buttonB = joypad.getButton("Button 1");
  buttonX = joypad.getButton("Button 2");
  buttonY = joypad.getButton("Button 3");
  
  buttonA.plug(this, "buttonARelease", ControllIO.ON_RELEASE);
}

void buttonARelease()
{
  button_mode_liveCaptureFromLive();
  
}
