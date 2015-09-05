// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrame extends PApplet {
  public int w, h;
  int abc = 100;
  public ControlP5 cp5;
  protected PApplet parent;

  private ControlFrame() {
  }

  public ControlFrame(PApplet theParent, int theWidth, int theHeight) {
    this.parent = theParent;
    this.w = theWidth;
    this.h = theHeight;
  }

  public ControlP5 cp5() {
    if (this.cp5 == null) {
      this.cp5 = this.setupControlP5();
    }
    return this.cp5;
  }

  public PApplet getParent() {
    return this.parent;
  }

  public void setup() {
    size(w, h);
    frameRate(5);
  }

  public ControlP5 setupControlP5() {
    println("About to create new ControlP5");
    ControlP5 cp5 = new ControlP5(this);
    println("Created: " + cp5);
    while (cp5 == null) {
      println("Was null: " + cp5);
    }
    println("Finally created: " + cp5);
    return cp5;
  }

  public void draw() {
    background(abc);
  }
}



