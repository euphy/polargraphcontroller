/*------------------------------------------------------------------------
 Class and controllers on the "serial port" subwindow
 ------------------------------------------------------------------------*/

ControlFrameSimple addSerialPortControlFrame(String theName, int theWidth, int theHeight, int theX, int theY, int theColor ) {
  final Frame f = new Frame( theName );
  final ControlFrameSimple p = new ControlFrameSimple( this, theWidth, theHeight, theColor );

  f.add( p );
  p.init();
  f.setTitle(theName);
  f.setSize( p.w, p.h );
  f.setLocation( theX, theY );
  f.addWindowListener( new WindowAdapter() {
    @Override
      public void windowClosing(WindowEvent we) {
      p.dispose();
      f.dispose();
    }
  } 
  );
  f.setResizable( true );
  f.setVisible( true );
  // sleep a little bit to allow p to call setup.
  // otherwise a nullpointerexception might be caused.
  try {
    Thread.sleep( 100 );
  } 
  catch(Exception e) {
  }
  
  // set up controls
  RadioButton r = p.cp5().addRadioButton("radio_serialPort")
    .setPosition(10, 10)
    .setSize(15, 15)
    .setSpacingRow(5)
    .plugTo(this, "radio_serialPort");

  r.addItem("No serial connection", -1);

  String[] ports = Serial.list();

  for (int i = 0; i < ports.length; i++) {
    println("Adding " + ports[i]);
    r.addItem(ports[i], i);
  }

  int portNo = getSerialPortNumber();
  if (portNo >= 0 && portNo < ports.length)
    r.activate(ports[portNo]);
  else
    r.activate("No serial connection");

  return p;
}


void radio_serialPort(int newSerialPort) 
{
  println("In radio_serialPort");
  if (newSerialPort == -2)
  {
  } 
  else if (newSerialPort == -1) {
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
  else if (newSerialPort != getSerialPortNumber()) {
    println("About to connect to serial port in slot " + newSerialPort);
    // Print a list of the serial ports, for debugging purposes:
    if (newSerialPort < Serial.list().length) {
      try {
        drawbotReady = false;
        drawbotConnected = false;
        if (myPort != null) {
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
      catch (Exception e) {
        println("Attempting to connect to serial port in slot " + getSerialPortNumber() 
          + " caused an exception: " + e.getMessage());
      }
    } else {
      println("No serial ports found.");
      useSerialPortConnection = false;
    }
  } else {
    println("no serial port change.");
  }
}

