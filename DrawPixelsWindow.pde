///*------------------------------------------------------------------------
//    Details about the "drawing" subwindow
//------------------------------------------------------------------------*/

public Integer renderStartDirection = DRAW_DIR_SE; // default start drawing in SE direction (DOWN)
public Integer renderStartPosition = DRAW_DIR_NE; // default top right hand corner for start
public Integer renderStyle = PIXEL_STYLE_SQ_FREQ; // default pixel style square wave

ControlFrameSimple addDrawPixelsControlFrame(String theName, int theWidth, int theHeight, int theX, int theY, int theColor ) {
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
  RadioButton rPos = p.cp5().addRadioButton("radio_startPosition",10,10)
    .add("Top-right", DRAW_DIR_NE)
    .add("Bottom-right", DRAW_DIR_SE)
    .add("Bottom-left", DRAW_DIR_SW)
    .add("Top-left", DRAW_DIR_NW)
    .plugTo(this, "radio_startPosition");

  RadioButton rSkip = p.cp5().addRadioButton("radio_pixelSkipStyle",10,100)
    .add("Lift pen over masked pixels", 1)
    .add("Draw masked pixels as blanks", 2)
    .plugTo(this, "radio_pixelSkipStyle");

  RadioButton rStyle = p.cp5().addRadioButton("radio_pixelStyle",100,10);
  rStyle.add("Variable frequency square wave", PIXEL_STYLE_SQ_FREQ);
  rStyle.add("Variable size square wave", PIXEL_STYLE_SQ_SIZE);
  rStyle.add("Solid square wave", PIXEL_STYLE_SQ_SOLID);
  rStyle.add("Scribble", PIXEL_STYLE_SCRIBBLE);
  if (currentHardware >= HARDWARE_VER_MEGA) {
    rStyle.add("Spiral", PIXEL_STYLE_CIRCLE);
    rStyle.add("Sawtooth", PIXEL_STYLE_SAW);
  }
  rStyle.plugTo(this, "radio_pixelStyle");
  

  Button submitButton = p.cp5().addButton("submitDrawWindow",0,280,10,120,20)
    .setLabel("Generate commands")
    .plugTo(this, "submitDrawWindow");
      
  return p;
}

void radio_startPosition(int pos) {
  renderStartPosition = pos;
  radio_rowStartDirection(1);
}

void radio_rowStartDirection(int dir) {
  if (renderStartPosition == DRAW_DIR_NE || renderStartPosition == DRAW_DIR_SW)
    renderStartDirection = (dir == 0) ? DRAW_DIR_NW : DRAW_DIR_SE;
  else if (renderStartPosition == DRAW_DIR_SE || renderStartPosition == DRAW_DIR_NW)
    renderStartDirection = (dir == 0) ? DRAW_DIR_NE : DRAW_DIR_SW;
}

void radio_pixelStyle(int style)  {
  renderStyle = style;
}

void radio_pixelSkipStyle(int style) {
  if (style == 1)
    liftPenOnMaskedPixels = true;
  else if (style == 2)
    liftPenOnMaskedPixels = false;
}

void submitDrawWindow(int theValue) {
  println("draw.");
  println("Style: " + renderStyle);
  println("Start pos: " + renderStartPosition);
  println("Start dir: " + renderStartDirection);

  switch (renderStyle) {
    case PIXEL_STYLE_SQ_FREQ: button_mode_renderSquarePixel(); break;
    case PIXEL_STYLE_SQ_SIZE: button_mode_renderScaledSquarePixels(); break;
    case PIXEL_STYLE_SQ_SOLID: button_mode_renderSolidSquarePixels(); break;
    case PIXEL_STYLE_SCRIBBLE: button_mode_renderScribblePixels(); break;
    case PIXEL_STYLE_CIRCLE: button_mode_renderCirclePixel(); break;
    case PIXEL_STYLE_SAW: button_mode_renderSawPixel(); break;
  }
}


class DrawPixelsWindow extends ControlFrame {


	public DrawPixelsWindow () {
		super(parentPapplet, 450, 150);
		
		int xPos = 100;
		int yPos = 100;
		String name = DRAW_PIXELS_WINDOW_NAME;

		final Frame f = new Frame(DRAW_PIXELS_WINDOW_NAME);
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
		

	}


}
