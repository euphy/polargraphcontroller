ControlFrameSimple addMachineExecControlFrame(String theName, int theWidth, int theHeight, int theX, int theY, int theColor ) {
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
  Textfield filenameField = p.cp5().addTextfield("machineExec_execFilename",20,20,150,20)
    .setText(getStoreFilename())
    .setLabel("Filename to execute from")
    .addListener( new ControlListener() {
      public void controlEvent( ControlEvent ev ) {
        machineExec_execFilename(ev.getController().getStringValue());
        Textfield tf = p.cp5().get(Textfield.class, "machineExec_execFilename");
      }
    });
    

  Button submitButton = p.cp5().addButton("machineExec_submitExecFilenameWindow",0,180,20,60,20)
    .setLabel("Submit")
    .addListener( new ControlListener() {
      public void controlEvent( ControlEvent ev ) {
        p.cp5().get(Textfield.class, "machineExec_execFilename").submit();
        p.cp5().get(Textfield.class, "machineExec_execFilename").setText(getStoreFilename());
      }
    });
    
  filenameField.setFocus(true);
    
  return p;
}

void machineExec_execFilename(String filename) {
  println("Filename event: "+ filename);
  if (filename != null 
      && filename.length() <= 12
      && !"".equals(filename.trim())) {
    filename = filename.trim();
    setStoreFilename(filename);
    sendMachineExecMode();
  }
}

