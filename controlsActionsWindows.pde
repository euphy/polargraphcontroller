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

void button_mode_sendMachineLiveMode() {
	sendMachineLiveMode();
}
	
String CHANGE_SERIAL_PORT_WINDOW_NAME = "changeSerialPortWindow";
String MACHINE_STORE_WINDOW_NAME = "chooseStoreFilenameWindow";
String MACHINE_EXEC_WINDOW_NAME = "chooseExecFilenameWindow";
String DRAW_PIXELS_WINDOW_NAME = "drawPixelsWindow";
String DRAW_WRITING_WINDOW_NAME = "drawWritingWindow";

void button_mode_serialPortDialog() {
	final SerialPortWindow serialPortWindow = new SerialPortWindow();
}

void button_mode_machineStoreDialog() {
	final MachineStoreWindow machineStoreWindow = new MachineStoreWindow();
}

void button_mode_machineExecDialog() {
	final MachineExecWindow machineExecWindow = new MachineExecWindow();
}

void button_mode_drawPixelsDialog() {
	final DrawPixelsWindow drawPixelsWindow = new DrawPixelsWindow();
}

void button_mode_drawWritingDialog() {
	final DrawWritingWindow drawWritingWindow = new DrawWritingWindow();
}

///*------------------------------------------------------------------------
//    Details about the "writing" subwindow
//------------------------------------------------------------------------*/
String textToWrite = "";
String spriteFilePrefix = "sprite/let";
String spriteFileSuffix = ".txt";
public class DrawWritingWindow extends ControlFrame {
	public DrawWritingWindow() {
		super(parentPapplet, 450, 250);
		int xPos = 100;
		int yPos = 100;
		String name = DRAW_WRITING_WINDOW_NAME;

		final Frame f = new Frame(name);
		f.add(this);
		this.init();
		f.setTitle(name);
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
		Textfield spriteFileField = cp5().addTextfield("spriteFilePrefixField",20,20,150,20)
			.setText(getSpriteFilePrefix())
			.setLabel("File prefix")
			.plugTo("spriteFilePrefixField");

		Textfield writingField = cp5().addTextfield("textToWriteField",20,60,400,20)
			.setText(getTextToWrite())
			.setLabel("Text to write")
			.plugTo("textToWriteField");

		Button importTextButton = cp5().addButton("importTextButton",0,20,100,120,20)
			.setLabel("Load text from file")
			.plugTo("importTextButton");

		RadioButton rPos = cp5().addRadioButton("radio_drawWritingDirection",20,140);
		//  rPos.add("North-east", DRAW_DIR_NE);
		rPos.add("South-east", DRAW_DIR_SE);
		//  rPos.add("South-west", DRAW_DIR_SW);
		//  rPos.add("North-west", DRAW_DIR_NW);
		rPos.plugTo("radio_drawWritingDirection");

		Button submitButton = cp5.addButton("submitWritingWindow",0,300,100,120,20)
			.setLabel("Generate commands")
			.plugTo("submitWritingWindow");
	}

	void spriteFilePrefixField(String value) {
		spriteFilePrefix = value;
	}
	void textToWriteField(String value) {
		textToWrite = value;
	}

	String getTextToWrite() {
		return textToWrite;
	}
	String getSpriteFilePrefix() {
		return spriteFilePrefix;
	}
	String getSpriteFileSuffix() {
		return spriteFileSuffix;
	}

	void importTextButton() {
		println("Text!");
		selectInput("Select the text file to load the text from:", "importTextToWriteFromFile", null, this);
	}
	
	public void importTextToWriteFromFile(File selection) {
		if (selection != null) {
			String fp = selection.getAbsolutePath();
			println("Input file: " + fp);
			List<String> rows = java.util.Arrays.asList(loadStrings(fp));
			StringBuilder sb = new StringBuilder(200);
			for (String row : rows) {
				sb.append(row);
			}
			textToWriteField(sb.toString());
			println("Completed text import, " + getTextToWrite().length() + " characters found.");
			
			println("Text: " + getTextToWrite());
			
			Textfield tf = cp5().get(Textfield.class, "textToWriteField");
			tf.setText(getTextToWrite());
			tf.submit();
		}
	}

	void submitWritingWindow(int theValue) 
	{
		println("Write.");
		 
		Textfield tf = cp5().get(Textfield.class, "spriteFilePrefixField");
		tf.submit();
		tf.setText(getSpriteFilePrefix());
		 
		Textfield wf = cp5.get(Textfield.class, "textToWriteField");
		wf.submit();
		wf.setText(getTextToWrite());
		 
		println("Start dir: " + renderStartDirection);
		println("Sprite file prefix: " + spriteFilePrefix);
		println("Text: " + textToWrite);

		for (int i=0; i<getTextToWrite().length(); i++) {
			String filename = getSpriteFilePrefix() + (int) getTextToWrite().charAt(i) + getSpriteFileSuffix();
			addToCommandQueue(CMD_DRAW_SPRITE + int(gridSize * pixelScalingOverGridSize) + "," + filename+",END");
			println(filename);
		}
	}
}
//
//void button_mode_drawWritingDialog()
//{
//  this.dialogWindow = cp5.addControlWindow("drawWritingWindow",100,100,450,200);
//  dialogWindow.hideCoordinates();
//  
//  dialogWindow.setBackground(getBackgroundColour());
//
//
//
///*------------------------------------------------------------------------
//    Details about the "sprite" subwindow
//------------------------------------------------------------------------*/
//String spriteFilename;
//int minSpriteSize = 100;
//int maxSpriteSize = 500;
//
//void button_mode_drawSpriteDialog()
//{
//  this.dialogWindow = cp5.addControlWindow("drawSpriteWindow",100,100,450,200);
//  dialogWindow.hideCoordinates();
//  
//  dialogWindow.setBackground(getBackgroundColour());
//
//  delay(200);
//  Textfield spriteFilenameField = cp5.addTextfield("spriteFilenameField",20,20,400,20);
//  spriteFilenameField.setText("filename.txt");
//  spriteFilenameField.setLabel("Sprite filename");
//  spriteFilenameField.setWindow(dialogWindow);
//
//  Numberbox minSizeField = cp5.addNumberbox("minimumSpriteSize",20,60,100,20);
//  minSizeField.setValue(getMinimumSpriteSize());
//  minSizeField.setMin(10);
//  minSizeField.setMax(getMaximumSpriteSize());
//  minSizeField.setMultiplier(0.5);  
//  minSizeField.setLabel("Minimum size");
//  minSizeField.setWindow(dialogWindow);
//
//  Numberbox maxSizeField = cp5.addNumberbox("maximumSpriteSize",20,100,100,20);
//  maxSizeField.setValue(getMaximumSpriteSize());
//  maxSizeField.setMin(getMinimumSpriteSize());
//  maxSizeField.setMultiplier(0.5);  
//  maxSizeField.setLabel("Maximum size");
//  maxSizeField.setWindow(dialogWindow);
//
//  Radio rPos = cp5.addRadio("radio_drawWritingDirection",20,140);
//  rPos.add("North-east", DRAW_DIR_NE);
//  rPos.add("South-east", DRAW_DIR_SE);
//  rPos.add("South-west", DRAW_DIR_SW);
//  rPos.add("North-west", DRAW_DIR_NW);
//  rPos.setWindow(dialogWindow);
//  
//
//
//  Button submitButton = cp5.addButton("submitSpriteWindow",0,300,100,120,20);
//  submitButton.setLabel("Draw sprite");
//  submitButton.setWindow(dialogWindow);
//}
//
//void radio_drawWritingDirection(int dir)
//{
//  renderStartDirection = dir;
//}
//
//String getSpriteFilename()
//{
//  return spriteFilename;
//}
//int getMinimumSpriteSize()
//{
//  return minSpriteSize;
//}
//int getMaximumSpriteSize()
//{
//  return maxSpriteSize;
//}
//
//void submitSpriteWindow(int theValue) 
//{
//  println("Sprite.");
//  
//  Textfield tf = (Textfield) cp5.controller("spriteFilenameField");
//  tf.submit();
//  tf.setText(getSpriteFilename());
//  
//  println("Start dir: " + renderStartDirection);
//  println("Filename: " + spriteFilename);
//
//  addToCommandQueue(CMD_DRAW_SPRITE + "," + spriteFilename + "," 
//  + getMinimumSpriteSize() + "," + getMaximumSpriteSize() + "," + renderStartDirection + ",END");
//  
//}
//
//
///*------------------------------------------------------------------------
//    Details about the "norwegian draw" subwindow
//------------------------------------------------------------------------*/
//String norwegianExecFilename = "filename.pbm";
//int norwegianAmplitude = 20;
//int norwegianWavelength = 2;
//
//void button_mode_drawNorwegianDialog()
//{
//  this.dialogWindow = cp5.addControlWindow("chooseNorwegianFilenameWindow",100,100,450,150);
//  dialogWindow.hideCoordinates();
//  
//  dialogWindow.setBackground(getBackgroundColour());
//
//  Textfield filenameField = cp5.addTextfield("norwegianExecFilename",20,20,150,20);
//  filenameField.setText(norwegianExecFilename);
//  filenameField.setLabel("Filename to execute from");
//  filenameField.setWindow(dialogWindow);
//
//  Numberbox minSizeField = cp5.addNumberbox("norwegianAmplitude",20,60,100,20);
//  minSizeField.setValue(norwegianAmplitude);
//  minSizeField.setMin(10);
//  minSizeField.setMultiplier(0.5);  
//  minSizeField.setLabel("Amplitude");
//  minSizeField.setWindow(dialogWindow);
//
//  Numberbox maxSizeField = cp5.addNumberbox("norwegianWavelength",20,100,100,20);
//  maxSizeField.setValue(norwegianWavelength);
//  maxSizeField.setMin(1);
//  maxSizeField.setMultiplier(0.5);  
//  maxSizeField.setLabel("Wavelength");
//  maxSizeField.setWindow(dialogWindow);
//
//  Button outlineButton = cp5.addButton("submitNorwegianExecTraceOutline",0,180,20,80,20);
//  outlineButton.setLabel("Trace outline");
//  outlineButton.setWindow(dialogWindow);
//
//  Button submitButton = cp5.addButton("submitNorwegianExecFilenameWindow",0,180,100,80,20);
//  submitButton.setLabel("Submit");
//  submitButton.setWindow(dialogWindow);
//
//  filenameField.setFocus(true);
//
//}
//
//void submitNorwegianExecTraceOutline(int theValue) 
//{
//  Textfield tf = (Textfield) cp5.controller("norwegianExecFilename");
//  tf.submit();
//  tf.setText(norwegianExecFilename);
//  
//  println("Filename:" + norwegianExecFilename);
//  
//  addToCommandQueue(CMD_DRAW_NORWEGIAN_OUTLINE + norwegianExecFilename + ",END");
//}
//
//void submitNorwegianExecFilenameWindow(int theValue) 
//{
//  Textfield tf = (Textfield) cp5.controller("norwegianExecFilename");
//  tf.submit();
//  tf.setText(norwegianExecFilename);
//  
//  println("Filename:" + norwegianExecFilename);
//  println("Amplitude:" + norwegianAmplitude);
//  println("Wavelength:" + norwegianWavelength);
//  
//  addToCommandQueue(CMD_DRAW_NORWEGIAN + norwegianExecFilename + ","+norwegianAmplitude+","+norwegianWavelength+",END");
//}
//
//

