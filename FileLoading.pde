/**
  Polargraph controller
  Copyright Sandy Noble 2018.

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



void loadImageWithFileChooser()
{
  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() {
      JFileChooser fc = new JFileChooser();
      if (lastImageDirectory != null) fc.setCurrentDirectory(lastImageDirectory);
      fc.setFileFilter(new ImageFileFilter());
      fc.setDialogTitle("Choose an image file...");

      int returned = fc.showOpenDialog(frame);
      
      lastImageDirectory = fc.getCurrentDirectory();
      
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        // see if it's an image
        PImage img = loadImage(file.getPath());
        if (img != null) 
        {
          img = null;
          getDisplayMachine().loadNewImageFromFilename(file.getPath());
          if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
          {
            getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
          }
        }
      }
    }
  });
}

class ImageFileFilter extends javax.swing.filechooser.FileFilter 
{
  public boolean accept(File file) {
      String filename = file.getName();
      filename.toLowerCase();
      if (file.isDirectory() || filename.endsWith(".png") || filename.endsWith(".jpg") || filename.endsWith(".jpeg")) 
        return true;
      else
        return false;
  }
  public String getDescription() {
      return "Image files (PNG or JPG)";
  }
}

void loadVectorWithFileChooser()
{
  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() {
      JFileChooser fc = new JFileChooser();
      if (lastImageDirectory != null) 
      { 
        fc.setCurrentDirectory(lastImageDirectory);
      }
      
      fc.setFileFilter(new VectorFileFilter());
      fc.setDialogTitle("Choose a vector file...");
      int returned = fc.showOpenDialog(frame);
      lastImageDirectory = fc.getCurrentDirectory();
      
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        if (file.exists())
        {
          RShape shape = loadShapeFromFile(file.getPath());
          if (shape != null) 
          {
            setVectorFilename(file.getPath());
            setVectorShape(shape);
          }
          else 
          {
            println("File not found (" + file.getPath() + ")");
          }
        }
      }
    }
  }
  );
}

class VectorFileFilter extends javax.swing.filechooser.FileFilter 
{
  public boolean accept(File file) {
    String filename = file.getName();
    filename.toLowerCase();
    if (file.isDirectory() || filename.endsWith(".svg") || isGCodeExtension(filename))
      return true;
    else
      return false;
  }
  public String getDescription() {
    return "Vector graphic files (SVG, GCode)";
  }
}

void loadNewPropertiesFilenameWithFileChooser()
{
  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() 
    {
      JFileChooser fc = new JFileChooser();
      if (lastPropertiesDirectory != null) fc.setCurrentDirectory(lastPropertiesDirectory);
      fc.setFileFilter(new PropertiesFileFilter());
      
      fc.setDialogTitle("Choose a config file...");

      int returned = fc.showOpenDialog(frame);
      
      lastPropertiesDirectory = fc.getCurrentDirectory();
      
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        if (file.exists())
        {
          println("New properties file exists.");
          newPropertiesFilename = file.toString();
          println("new propertiesFilename: "+  newPropertiesFilename);
          propertiesFilename = newPropertiesFilename;
          // clear old properties.
          props = null;
          loadFromPropertiesFile();
          
          // set values of number spinners etc
          updateNumberboxValues();
        }   
      }
    }
  });
}

class PropertiesFileFilter extends javax.swing.filechooser.FileFilter 
{
  public boolean accept(File file) {
      String filename = file.getName();
      filename.toLowerCase();
      if (file.isDirectory() || filename.endsWith(".properties.txt")) 
        return true;
      else
        return false;
  }
  public String getDescription() {
      return "Properties files (*.properties.txt)";
  }
}

void saveNewPropertiesFileWithFileChooser()
{
  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() 
    {
      JFileChooser fc = new JFileChooser();
      if (lastPropertiesDirectory != null) fc.setCurrentDirectory(lastPropertiesDirectory);
      fc.setFileFilter(new PropertiesFileFilter());
      
      fc.setDialogTitle("Enter a config file name...");

      int returned = fc.showSaveDialog(frame);
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        newPropertiesFilename = file.toString();
        newPropertiesFilename.toLowerCase();
        if (!newPropertiesFilename.endsWith(".properties.txt"))
          newPropertiesFilename+=".properties.txt";
          
        println("new propertiesFilename: "+  newPropertiesFilename);
        propertiesFilename = newPropertiesFilename;
        savePropertiesFile();
        // clear old properties.
        props = null;
        loadFromPropertiesFile();
      }
    }
  });
}



RShape loadShapeFromFile(String filename) {
  RShape sh = null;
  if (filename.toLowerCase().endsWith(".svg")) {
    sh = RG.loadShape(filename);
  }
  else if (isGCodeExtension(filename)) {
    sh = loadShapeFromGCodeFile(filename);
  }
  return sh;
}


boolean isGCodeExtension(String filename) {
  return (filename.toLowerCase().endsWith(".gcode") || filename.toLowerCase().endsWith(".g") || filename.toLowerCase().endsWith(".ngc") || filename.toLowerCase().endsWith(".txt"));
}


int countLines(String filename) throws IOException {
    InputStream is = new BufferedInputStream(new FileInputStream(filename));
    try {
        byte[] c = new byte[1024];
        int count = 0;
        int readChars = 0;
        boolean empty = true;
        while ((readChars = is.read(c)) != -1) {
            empty = false;
            for (int i = 0; i < readChars; ++i) {
                if (c[i] == '\n') {
                    ++count;
                }
            }
        }
        return (count == 0 && !empty) ? 1 : count+1;
    } finally {
        is.close();
    }
}

RShape loadShapeFromGCodeFile(String filename) {
  noLoop();
  RShape parent = null;
  BufferedReader reader = null;
  long totalPoints = 0;
  long time = millis();
  long countLines = 0;

  try {
    countLines = countLines(filename);
    println("" + countLines + " lines found.");
    if (countLines < 1) {
      throw new IOException("No lines found in GCode file.");
    }
    reader = createReader(filename);
    parent = new RShape();
    String line;
    boolean drawLine = false;
    int gCodeZAxisChanges = 0;
    
    long lineNo = 0;
    float lastPercent = 0.0f;
    boolean reportStatus = true;
    while ((line = reader.readLine ()) != null) {
      lineNo++;
//      println("Line: " + line);
      
      if (reportStatus) {
        float percent = ((float)lineNo / (float)countLines) * 100.0;
        println("----" + percent + "% of the way through.");
        lastPercent = percent;
      }

      if (line.toUpperCase().startsWith("G")) {
        if (reportStatus) {
          println(new StringBuilder().append(lineNo).append(" of ").append(countLines).append(": ").append(line).append(". Points: ").append(totalPoints).toString());
          long free = Runtime.getRuntime().freeMemory();
          long maximum = Runtime.getRuntime().maxMemory();
          println(new StringBuilder().append("Free: ").append(free).append(", max: ").append(maximum).toString());
        }
        
        Map<String, Float> ins = null;
        try {
          ins = unpackGCodeInstruction(line);
        }
        catch (Exception e) {
          println(e.toString());
          continue;
        }
//        println("Ins: " + ins);
        Integer code = Math.round(ins.get("G"));
        
        Float z = ins.get("Z");
        if (z != null) {
          gCodeZAxisChanges++;
          if (gCodeZAxisChanges == 2) {
            println("Assume second z axis change is to drop the pen to start drawing " + z);
            gcodeZAxisDrawingHeight = z;
            drawLine = true;
          }
          else if (gCodeZAxisChanges > 2) {
            drawLine = isGCodeZAxisForDrawing(z);
          }
          else {
            println("Assume first z axis change is to RAISE the pen " + z);
            drawLine = false;
          }
        }
        else { //  if there is no Z axis, assume it's always on
//          drawLine = true; // this isn't always safe!
        }        
        
        Float x = ins.get("X");
        Float y = ins.get("Y");
        if (x != null && y == null) {
          // move x axis only, use y of last
          RPoint[][] points = parent.getPointsInPaths();
          RPoint rp = points[points.length-1][points[points.length-1].length-1];
          y = rp.y;
        }
        else if (x == null && y != null) {
          // move y axis only, use x of last
          RPoint[][] points = parent.getPointsInPaths();
          RPoint rp = points[points.length-1][points[points.length-1].length-1];
          x = rp.x;
        }
        
        if (x != null && y != null) {
          // move both x and y axis
          if (drawLine) {
            parent.addLineTo(x, y);
          }
          else {
            parent.addMoveTo(x, y);
          }
        }
      }
      else {
        
      }
      
      if ((millis() - time) > 500) {
        time = millis();
        reportStatus = true;
      }
      else {
        reportStatus = false;
      }
      
      if (lineNo == (countLines-1)) {
        reportStatus = true;
      }
      
    }
  }
  catch (IOException e) {
    println("IOExecption reading lines from the gcode file " + filename);
    e.printStackTrace();
  }
  finally {
    try {
      reader.close();
    } 
    catch (IOException e) {
      println("IOException closing the gcode file " + filename);
      e.printStackTrace();
    }
  }
  
  RPoint[][] points = parent.getPointsInPaths();
  totalPoints = 0;
  if (points != null) {
    for (int i = 0; i<points.length; i++) {
      if (points[i] != null) {
        for (int j = 0; j<points[i].length; j++) {
          totalPoints++;
        }
      }
    }
  }

  String conclusionMessage = "Imported " + totalPoints + " points from " + countLines + " lines of code in the file.";
  println(conclusionMessage);
  javax.swing.JOptionPane.showMessageDialog(null, conclusionMessage);

  loop();
  return parent;
}

Boolean isGCodeZAxisForDrawing(float z) {
  return gcodeZAxisDrawingHeight.compareTo(z) == 0;
}

Map<String, Float> unpackGCodeInstruction(String line) throws Exception {
  Map<String, Float> instruction = new HashMap<String, Float>(4);
  try {
    String[] splitted = line.trim().split(" ");
    for (int i = 0; i < splitted.length; i++) {
      // remove ; character
      splitted[i] = splitted[i].replace(";", "");
      String axis = splitted[i].substring(0, 1);
      String sanitisedValue = splitted[i].substring(1);
      sanitisedValue = sanitisedValue.replace(",", ".");
      Float value = Float.parseFloat(sanitisedValue);
      if ("X".equalsIgnoreCase(axis) || "Y".equalsIgnoreCase(axis) || "Z".equalsIgnoreCase(axis) || "G".equalsIgnoreCase(axis)) {
        instruction.put(axis.toUpperCase(), value);
      }
    }
//  println("instruction: " + instruction);
    if (instruction.isEmpty()) {
      throw new Exception("Empty instruction");
    }
  }
  catch (NumberFormatException nfe) {
    println("Number format exception: " + nfe.getMessage()); 
  }
  catch (Exception e) {
    println("e: " + e);
    throw new Exception("Exception while reading the lines from a gcode file: " + line + ", " + e.getMessage());
  }
  
  return instruction;
}
