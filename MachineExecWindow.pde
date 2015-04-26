class MachineExecWindow extends ControlFrame {

	void execFilename(String filename) {
		println("Filename event: "+ filename);
		if (filename != null && filename.length() <= 12) {
			setStoreFilename(filename);
			sendMachineExecMode();
		}
	}
	
	void submitExecFilenameWindow(int theValue) {
		cp5().get(Textfield.class, "execFilename").submit();
	}

	public MachineExecWindow() {
		super(parentPapplet, 450, 150);
		int xPos = 100;
		int yPos = 100;
		String name = MACHINE_EXEC_WINDOW_NAME;

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
		
		Textfield filenameField = cp5().addTextfield("execFilename",20,20,150,20)
			.setText(getStoreFilename())
			.setLabel("Filename to execute from")
			.plugTo("execFilename");

		Button submitButton = cp5().addButton("submitExecFilenameWindow",0,180,20,60,20)
			.setLabel("Submit")
			.plugTo("submitExecFilenameWindow");

		filenameField.setFocus(true);
	}
}
