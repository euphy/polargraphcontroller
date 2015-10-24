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
  ControlFrameSimple cf = addSerialPortControlFrame("Serial Port", 200, 200, 20, 240, color( 100 ) );
}

void button_mode_machineStoreDialog() {
  ControlFrameSimple cf = addMachineStoreControlFrame("Machine Store", 450, 250, 20, 240, color( 100 ) );
}

void button_mode_machineExecDialog() {
  ControlFrameSimple cf = addMachineExecControlFrame("Machine Execute", 450, 250, 20, 240, color( 100 ) );
}

void button_mode_drawPixelsDialog() {
  ControlFrameSimple cf = addDrawPixelsControlFrame("Render pixels", 450, 250, 20, 240, color( 100 ) );
}

void button_mode_drawWritingDialog() {
  ControlFrameSimple cf = addSpriteWritingControlFrame("Sprite Writing", 450, 250, 20, 240, color( 100 ) );
}

void button_mode_RandomSpriteDialog() {
  ControlFrameSimple cf = addRandomSpriteControlFrame("Random Sprite", 450, 250, 20, 240, color( 100 ) );
}

void button_mode_drawNorwegianDialog() {
  ControlFrameSimple cf = addNorwegianPixelControlFrame("Norwegian Pixel", 450, 250, 20, 240, color( 100 ) );
}

///*------------------------------------------------------------------------
//    Details about the "writing" subwindow
//------------------------------------------------------------------------*/

String spriteWriting_textToWrite = "";
String spriteWriting_spriteFilePrefix = "sprite/let";
String spriteWriting_spriteFileSuffix = ".txt";

ControlFrameSimple addSpriteWritingControlFrame(String theName, int theWidth, int theHeight, int theX, int theY, int theColor ) {
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
      cp5s.remove(DRAW_WRITING_WINDOW_NAME);
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
  
  cp5s.put(DRAW_WRITING_WINDOW_NAME, p.cp5());
  println(cp5s);
  
  // set up controls
    Textfield spriteFileField = p.cp5().addTextfield("spriteWriting_spriteFilePrefixField", 20, 20, 150, 20)
      .setText(spriteWriting_getSpriteFilePrefix())
      .setLabel("File prefix")
      .plugTo(this, "spriteWriting_spriteFilePrefixField");

    Textfield writingField = p.cp5().addTextfield("spriteWriting_textToWriteField", 20, 60, 400, 20)
      .setText(spriteWriting_getTextToWrite())
      .setLabel("Text to write")
      .plugTo(this, "spriteWriting_textToWriteField");

    Button importTextButton = p.cp5().addButton("spriteWriting_importTextButton", 0, 20, 100, 120, 20)
      .setLabel("Load text from file")
      .addListener( new ControlListener() {
        public void controlEvent( ControlEvent ev ) {
          spriteWriting_importTextButton();
        }
      });
      
    RadioButton rPos = p.cp5().addRadioButton("spriteWriting_radio_drawWritingDirection", 20, 140);
    rPos.add("South-east", DRAW_DIR_SE);
    rPos.activate("South-east");
    rPos.plugTo(this, "spriteWriting_radio_drawWritingDirection");

    Button submitButton = p.cp5.addButton("spriteWriting_submitWritingWindow", 0, 300, 100, 120, 20)
      .setLabel("Generate commands")
      .addListener( new ControlListener() {
        public void controlEvent( ControlEvent ev ) {
          spriteWriting_submitWritingWindow(p.cp5());
        }
      });
      
      
    return p;
}



  void spriteWriting_spriteFilePrefixField(String value) {
    spriteWriting_spriteFilePrefix = value;
  }
  void spriteWriting_textToWriteField(String value) {
    spriteWriting_textToWrite = value;
  }
  String spriteWriting_getTextToWrite() {
    return spriteWriting_textToWrite;
  }
  String spriteWriting_getSpriteFilePrefix() {
    return spriteWriting_spriteFilePrefix;
  }
  String spriteWriting_getSpriteFileSuffix() {
    return spriteWriting_spriteFileSuffix;
  }

  void spriteWriting_importTextButton() {
    println("Text being imported!");
    selectInput("Select the text file to load the text from:", 
                "spriteWriting_importTextToWriteFromFile");
  }

  public void spriteWriting_importTextToWriteFromFile(File selection) {
    if (selection != null) {
      String fp = selection.getAbsolutePath();
      println("Input file: " + fp);
      List<String> rows = java.util.Arrays.asList(loadStrings(fp));
      StringBuilder sb = new StringBuilder(200);
      for (String row : rows) {
        sb.append(row);
      }
      spriteWriting_textToWriteField(sb.toString());
      println("Completed text import, " + spriteWriting_getTextToWrite().length() + " characters found.");

      println("Text: " + spriteWriting_getTextToWrite());
      
      println(cp5s);

      Textfield tf = cp5s.get(DRAW_WRITING_WINDOW_NAME).get(Textfield.class, "spriteWriting_textToWriteField");      
      if (spriteWriting_getTextToWrite() != null 
          && !"".equals(spriteWriting_getTextToWrite().trim())) {
        tf.setText(spriteWriting_getTextToWrite());
        tf.submit();
        tf.setText(spriteWriting_getTextToWrite());
      }
    }
  }

  void spriteWriting_submitWritingWindow(ControlP5 parent) 
  {
    println("Write.");

    Textfield tf = parent.get(Textfield.class, "spriteWriting_spriteFilePrefixField");
    tf.submit();
    tf.setText(spriteWriting_getSpriteFilePrefix());

    Textfield wf = parent.get(Textfield.class, "spriteWriting_textToWriteField");
    wf.submit();
    wf.setText(spriteWriting_getTextToWrite());

    println("Start dir: " + renderStartDirection);
    println("Sprite file prefix: " + spriteWriting_spriteFilePrefix);
    println("Text: " + spriteWriting_textToWrite);

    for (int i=0; i<spriteWriting_getTextToWrite ().length(); i++) {
      String filename = spriteWriting_getSpriteFilePrefix() + (int) spriteWriting_getTextToWrite().charAt(i) + spriteWriting_getSpriteFileSuffix();
      addToCommandQueue(CMD_DRAW_SPRITE + int(gridSize * pixelScalingOverGridSize) + "," + filename+",END");
      println(filename);
    }
  }


///*------------------------------------------------------------------------
//    Details about the "sprite" subwindow
//------------------------------------------------------------------------*/
String sprite_spriteFilename;
int sprite_minSpriteSize = 100;
int sprite_maxSpriteSize = 500;

ControlFrameSimple addRandomSpriteControlFrame(String theName, int theWidth, int theHeight, int theX, int theY, int theColor ) {
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

  Textfield spriteFilenameField = p.cp5().addTextfield("sprite_spriteFilenameField",20,20,400,20)
    .setText("filename.txt")
    .setLabel("Sprite filename")
    .plugTo(this, "sprite_spriteFilenameField");

  Numberbox minSizeField = p.cp5().addNumberbox("sprite_minimumSpriteSize",20,60,100,20)
    .setValue(sprite_getMinimumSpriteSize())
    .setMin(10)
    .setMax(sprite_getMaximumSpriteSize())
    .setMultiplier(0.5)
    .setLabel("Minimum size")
    .plugTo(this, "sprite_minimumSpriteSize");

  Numberbox maxSizeField = p.cp5().addNumberbox("sprite_maximumSpriteSize",20,100,100,20)
    .setValue(sprite_getMaximumSpriteSize())
    .setMin(sprite_getMinimumSpriteSize())
    .setMultiplier(0.5)
    .setLabel("Maximum size")
    .plugTo(this, "sprite_maximumSpriteSize");

  Button submitButton = p.cp5().addButton("sprite_submitSpriteWindow",0,300,100,120,20)
    .setLabel("Draw sprite")
    .addListener( new ControlListener() {
      public void controlEvent( ControlEvent ev ) {
        spriteWriting_submitWritingWindow(p.cp5());
      }
    });

  spriteFilenameField.setFocus(true);
           
  return p;
}

String sprite_getSpriteFilename()
{
  return sprite_spriteFilename;
}
int sprite_getMinimumSpriteSize()
{
  return sprite_minSpriteSize;
}
int sprite_getMaximumSpriteSize()
{
  return sprite_maxSpriteSize;
}

void sprite_submitSpriteWindow(Textfield tf) 
{
  println("Sprite.");
  
  tf.submit();
  tf.setText(sprite_getSpriteFilename());
  
  println("Filename: " + sprite_getSpriteFilename());

  addToCommandQueue(CMD_DRAW_SPRITE + "," + sprite_getSpriteFilename() + "," 
  + sprite_getMinimumSpriteSize() + "," + sprite_getMaximumSpriteSize() + "," + DRAW_DIR_NE + ",END");
  
}


///*------------------------------------------------------------------------
//    Details about the "norwegian draw" subwindow
//------------------------------------------------------------------------*/
String norwegian_execFilename = "filename.pbm";
int norwegian_amplitude = 20;
int norwegian_wavelength = 2;

ControlFrameSimple addNorwegianPixelControlFrame(String theName, int theWidth, int theHeight, int theX, int theY, int theColor ) {
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
  Textfield filenameField = p.cp5().addTextfield("norwegian_execFilename",20,20,150,20)
    .setText(norwegian_execFilename)
    .setLabel("Filename to execute from")
    .plugTo(this, "norwegian_execFilename");

  Numberbox minSizeField = p.cp5().addNumberbox("norwegian_amplitude",20,60,100,20)
    .setValue(norwegian_amplitude)
    .setMin(10)
    .setMultiplier(0.5)  
    .setLabel("Amplitude")
    .plugTo(this, "norwegian_amplitude");

  Numberbox maxSizeField = p.cp5().addNumberbox("norwegian_wavelength",20,100,100,20)
  .setValue(norwegian_wavelength)
  .setMin(1)
  .setMultiplier(0.5)  
  .setLabel("Wavelength")
  .plugTo(this, "norwegian_wavelength");

  Button outlineButton = p.cp5().addButton("norwegian_submitNorwegianExecTraceOutline",0,180,20,80,20)
  .setLabel("Trace outline")
  .addListener( new ControlListener() {
    public void controlEvent( ControlEvent ev ) {
      norwegian_submitNorwegianExec(p.cp5().get(Textfield.class, "norwegian_execFilename"), true);
    }
  });

  Button submitButton = p.cp5().addButton("norwegian_submitNorwegianExecFilenameWindow",0,180,100,80,20)
  .setLabel("Submit")
  .addListener( new ControlListener() {
    public void controlEvent( ControlEvent ev ) {
      norwegian_submitNorwegianExec(p.cp5().get(Textfield.class, "norwegian_execFilename"), false);
    }
  });

  filenameField.setFocus(true);
      
      
  return p;
}


void norwegian_submitNorwegianExec(Textfield tf, boolean outline)
{
  tf.submit();
  tf.setText(norwegian_execFilename);
  
  println("Filename:" + norwegian_execFilename);
  
  if (outline) {
    addToCommandQueue(CMD_DRAW_NORWEGIAN_OUTLINE + norwegian_execFilename + ",END");
  }
  else {
    println("Filename:" + norwegian_execFilename);
    println("Amplitude:" + norwegian_amplitude);
    println("Wavelength:" + norwegian_wavelength);
    
    addToCommandQueue(CMD_DRAW_NORWEGIAN + norwegian_execFilename + ","+norwegian_amplitude+","+norwegian_wavelength+",END");
  }
}




