/*------------------------------------------------------------------------
    Details about the "machine store" subwindow
------------------------------------------------------------------------*/

ControlFrameSimple addMachineStoreControlFrame(String theName, int theWidth, int theHeight, int theX, int theY, int theColor ) {
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

    Textfield filenameField = p.cp5().addTextfield("machineStore_storeFilename",20,20,150,20)
      .setText(getStoreFilename())
      .setLabel("Filename to store to")
      .addListener( new ControlListener() {
        public void controlEvent( ControlEvent ev ) {
          machineStore_storeFilename(ev.getController().getStringValue());
          Textfield tf = p.cp5().get(Textfield.class, "machineExec_execFilename");
        }
      });

    Button submitButton = p.cp5().addButton("machineStore_submitStoreFilenameWindow",0,180,20,60,20)
      .setLabel("Submit")
      .addListener( new ControlListener() {
        public void controlEvent( ControlEvent ev ) {
          p.cp5().get(Textfield.class, "machineStore_storeFilename").submit();
          p.cp5().get(Textfield.class, "machineStore_storeFilename").setText(getStoreFilename());
        }
      });

    Toggle overwriteToggle = p.cp5().addToggle("machineStore_toggleAppendToFile",true,180,50,20,20)
      .setCaptionLabel("Overwrite existing file")
      .plugTo(this, "machineStore_toggleAppendToFile");
      
     
  filenameField.setFocus(true);
    
  return p;
}

void machineStore_toggleAppendToFile(boolean theFlag) {
  setOverwriteExistingStoreFile(theFlag);
}
  
void machineStore_storeFilename(String filename) {
  println("Filename event: "+ filename);
  if (filename != null 
      && filename.length() <= 12
      && !"".equals(filename.trim())) {
    filename = filename.trim();
    setStoreFilename(filename);
    sendMachineStoreMode();
  }
}

