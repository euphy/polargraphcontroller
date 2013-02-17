/**
  Polargraph controller
  Copyright Sandy Noble 2012.

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
  http://code.google.com/p/polargraph/
*/
class Panel
{
  private Rectangle outline = null;
  private String name = null;
  private List<Controller> controls = null;
  private Map<String, PVector> controlPositions = null;
  private Map<String, PVector> controlSizes = null;
  private boolean resizable = true;
  private float minimumHeight = DEFAULT_CONTROL_SIZE.y+4;
  private color outlineColour = color(255);
  
  public final color CONTROL_COL_BG_DEFAULT = color(0,54,82);
  public final color CONTROL_COL_BG_DISABLED = color(20,44,62);
  public final color CONTROL_COL_LABEL_DEFAULT = color(255);
  public final color CONTROL_COL_LABEL_DISABLED = color(200);

  public Panel(String name, Rectangle outline)
  {
    this.name = name;
    this.outline = outline;
  }
  
  public Rectangle getOutline()
  {
    return this.outline;
  }
  public void setOutline(Rectangle r)
  {
    this.outline = r;
  }
  
  public String getName()
  {
    return this.name;
  }
  public void setName(String name)
  {
    this.name = name;
  }
  
  public List<Controller> getControls()
  {
    if (this.controls == null)
      this.controls = new ArrayList<Controller>(0);
    return this.controls;
  }
  public void setControls(List<Controller> c)
  {
    this.controls = c;
  }
  
  public Map<String, PVector> getControlPositions()
  {
    return this.controlPositions;
  }
  public void setControlPositions(Map<String, PVector> cp)
  {
    this.controlPositions = cp;
  }
  
  public Map<String, PVector> getControlSizes()
  {
    return this.controlSizes;
  }
  public void setControlSizes(Map<String, PVector> cs)
  {
    this.controlSizes = cs;
  }
  
  void setOutlineColour(color c)
  {
    this.outlineColour = c;
  }
  
  void setResizable(boolean r)
  {
    this.resizable = r;
  }
  boolean isResizable()
  {
    return this.resizable;
  }
  
  void setMinimumHeight(float h)
  {
    this.minimumHeight = h;
  }
  float getMinimumHeight()
  {
    return this.minimumHeight;
  }
  
  public void draw()
  {
//    stroke(outlineColour);
//    strokeWeight(2);
//    rect(getOutline().getLeft(), getOutline().getTop(), getOutline().getWidth(), getOutline().getHeight());

    drawControls();
  }
  
  public void drawControls()
  {
    for (Controller c : this.getControls())
    {
      PVector pos = getControlPositions().get(c.name());
      float x = pos.x+getOutline().getLeft();
      float y = pos.y+getOutline().getTop();
      c.setPosition(x, y);

      PVector cSize = getControlSizes().get(c.name());
      c.setSize((int)cSize.x, (int)cSize.y);

      boolean locked = false;
      
      // theres a few cases here where the controls are locked (disabled)
      
      // any drawing / extracting controls are disabled if there is no selec
      // box specified.
      if (getControlsToLockIfBoxNotSpecified().contains(c.name()) && !isBoxSpecified())
      {
        locked = true;        
      }
      
      // if there is no vector shape loaded then lock the "draw vector"
      // control.
      if (c.name().equals(MODE_RENDER_VECTORS) && getVectorShape() == null)
      {
        locked = true;
      }
  
      // if there's no image loaded, then hide resizing/moving
      if (getControlsToLockIfImageNotLoaded().contains(c.name()) && getDisplayMachine().getImage() == null)
      {
        locked = true;        
      }
      
      if (c.name().equals(MODE_LOAD_VECTOR_FILE))
      {
        if (getVectorShape() != null)
          c.setLabel("Clear vector");
        else
          c.setLabel("Load vector");
      }
      else if (c.name().equals(MODE_LOAD_IMAGE))
      {
        if (getDisplayMachine().getImage() != null)
          c.setLabel("Clear image");
        else
          c.setLabel("Load image file");
      }
      

      int col = c.getColor().getBackground();      
      setLock(c, locked);
    }
  }
  
  void setLock(Controller c, boolean locked) 
  {
    c.setLock(locked);
    if (locked) 
    {
      c.setColorBackground(CONTROL_COL_BG_DISABLED);
      c.setColorLabel(CONTROL_COL_LABEL_DISABLED);
    } 
    else 
    {
      c.setColorBackground(CONTROL_COL_BG_DEFAULT);
      c.setColorLabel(CONTROL_COL_LABEL_DEFAULT);
    }
  }  
  
  void setHeight(float h)
  {
    if (this.isResizable())
    {
      if (h <= getMinimumHeight())
        this.getOutline().setHeight(getMinimumHeight());
      else
        this.getOutline().setHeight(h);
      setControlPositions(buildControlPositionsForPanel(this));
      
      float left = 0.0;
      String controlName = "";
      for (String key : getControlPositions().keySet())
      {
        PVector pos = getControlPositions().get(key);
        if (pos.x >= left)
        {
          left = pos.x;
          controlName = key;
        }
      }
      
      Map<String, PVector> map = getControlSizes();
      
//      PVector size = getControlSizes().get(controlName);
//      println("size: " + size);
      float right = left + DEFAULT_CONTROL_SIZE.x;
      
      this.getOutline().setWidth(right);
    }
  }
  
  
}
