/*------------------------------------------------------------------------
    Details about the "machine store" subwindow
------------------------------------------------------------------------*/
class MachineStoreWindow extends ControlFrame {

	void storeFilename(String filename) {
		println("Filename event: "+ filename);
		if (filename != null && filename.length() <= 12) {
			setStoreFilename(filename);
			sendMachineStoreMode();
		}
	}

	void toggleAppendToFile(boolean theFlag) {
		setOverwriteExistingStoreFile(theFlag);
	}

	void submitStoreFilenameWindow(int theValue) {
		cp5().get(Textfield.class, "storeFilename").submit();
	}

	public MachineStoreWindow() {
		super(parentPapplet, 450, 150);
		int xPos = 100;
		int yPos = 100;
		String name = MACHINE_STORE_WINDOW_NAME;

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
		
		Textfield filenameField = cp5().addTextfield("storeFilename",20,20,150,20)
			.setText(getStoreFilename())
			.setLabel("Filename to store to")
			.plugTo("storeFilename");

		Button submitButton = cp5().addButton("submitStoreFilenameWindow",0,180,20,60,20)
			.setLabel("Submit")
			.plugTo("submitStoreFilenameWindow");

		Toggle overwriteToggle = cp5().addToggle("toggleAppendToFile",true,180,50,20,20)
			.setCaptionLabel("Overwrite existing file")
			.plugTo("toggleAppendToFile");

		filenameField.setFocus(true);		
	}
}