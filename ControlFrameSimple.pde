
// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrameSimple extends PApplet {

  int w, h;

  int bg;

  public void setup() {
    size(w, h);
    frameRate(5);
    cp5 = new ControlP5( this );
  }

  public void draw() {
    background( bg );
  }

  private ControlFrameSimple() {
  }

  public ControlFrameSimple(Object theParent, int theWidth, int theHeight, int theColor) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
    bg = theColor;
  }


  public ControlP5 cp5() {
    return this.cp5;
  }

  ControlP5 cp5;

  Object parent;
}

