/*------------------------------------------------------------------------
    Class and controllers on the "serial port" subwindow
------------------------------------------------------------------------*/

class SerialPortWindow extends ControlFrame {
	public SerialPortWindow() {
		super(parentPapplet, 150, 350);
		
		int xPos = 100;
		int yPos = 100;

		final Frame f = new Frame(CHANGE_SERIAL_PORT_WINDOW_NAME);
		f.add(this);
		this.init();
		f.setTitle(CHANGE_SERIAL_PORT_WINDOW_NAME);
		f.setSize(super.w, super.h);
		f.setLocation(xPos, yPos);
		f.setResizable(false);
		f.setVisible(true);

		f.addWindowListener( new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent we) {
				f.dispose();
			}
		});

		RadioButton r = cp5().addRadioButton("radio_serialPort")
			.setPosition(10, 10)
			.setSize(15,15)
			.setSpacingRow(5)
			.plugTo(parentPapplet, "radio_serialPort");
  
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
	}
}

void radio_serialPort(int newSerialPort) 
{
  println("In radio_serialPort");
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