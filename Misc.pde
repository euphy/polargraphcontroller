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

class Scaler
{
  public float scale = 1.0;
  public float mmPerStep = 1.0;
  
  public Scaler(float scale, float mmPerStep)
  {
    this.scale = scale;
    this.mmPerStep = mmPerStep;
  }
  public void setScale(float scale)
  {
    this.scale = scale;
  }
  
  public float scale(float in)
  {
    return in * mmPerStep * scale;
  }
}

class PreviewVector extends PVector
{
  public String command;
}
//
//
//import java.awt.Toolkit;
//import java.awt.BorderLayout;
//import java.awt.GraphicsEnvironment;
//
//public class Console extends WindowAdapter implements WindowListener, ActionListener, Runnable
//{
//  private JFrame frame;
//  private JTextArea textArea;
//  private Thread reader;
//  private Thread reader2;
//  private boolean quit;
//
//  private final PipedInputStream pin=new PipedInputStream(); 
//  private final PipedInputStream pin2=new PipedInputStream(); 
//
//  private PrintStream cOut = System.out;
//  private PrintStream cErr = System.err;
//
//  Thread errorThrower; // just for testing (Throws an Exception at this Console
//
//  public Console()
//  {
//    // create all components and add them
//    frame=new JFrame("Java Console");
//    Dimension screenSize=Toolkit.getDefaultToolkit().getScreenSize();
//    Dimension frameSize=new Dimension((int)(screenSize.width/2),(int)(screenSize.height/2));
//    int x=(int)(frameSize.width/2);
//    int y=(int)(frameSize.height/2);
//    frame.setBounds(x,y,frameSize.width,frameSize.height);
//
//    textArea=new JTextArea();
//    textArea.setEditable(false);
//    JButton button=new JButton("clear");
//
//    frame.getContentPane().setLayout(new BorderLayout());
//    frame.getContentPane().add(new JScrollPane(textArea),BorderLayout.CENTER);
//    frame.getContentPane().add(button,BorderLayout.SOUTH);
//    frame.setVisible(true);		
//
//    frame.addWindowListener(this);		
//    button.addActionListener(this);
//
//    try
//    {
//      this.cOut = System.out;
//      PipedOutputStream pout=new PipedOutputStream(this.pin);
//      System.setOut(new PrintStream(pout,true)); 
//    } 
//    catch (java.io.IOException io)
//    {
//      textArea.append("Couldn't redirect STDOUT to this console\n"+io.getMessage());
//    }
//    catch (SecurityException se)
//    {
//      textArea.append("Couldn't redirect STDOUT to this console\n"+se.getMessage());
//    } 
//
//    try 
//    {
//      this.cErr = System.err;
//      PipedOutputStream pout2=new PipedOutputStream(this.pin2);
//      System.setErr(new PrintStream(pout2,true));
//    } 
//    catch (java.io.IOException io)
//    {
//      textArea.append("Couldn't redirect STDERR to this console\n"+io.getMessage());
//    }
//    catch (SecurityException se)
//    {
//      textArea.append("Couldn't redirect STDERR to this console\n"+se.getMessage());
//    } 		
//
//    quit=false; // signals the Threads that they should exit
//
//    // Starting two seperate threads to read from the PipedInputStreams				
//    //
//    reader=new Thread(this);
//    reader.setDaemon(true);	
//    reader.start();	
//    //
//    reader2=new Thread(this);	
//    reader2.setDaemon(true);	
//    reader2.start();
//
////    // testing part
////    // you may omit this part for your application
////    // 
////    System.out.println("Hello World 2");
////    System.out.println("All fonts available to Graphic2D:\n");
////    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
////    String[] fontNames=ge.getAvailableFontFamilyNames();
////    for(int n=0;n<fontNames.length;n++)  System.out.println(fontNames[n]);		
////    // Testing part: simple an error thrown anywhere in this JVM will be printed on the Console
////    // We do it with a seperate Thread becasue we don't wan't to break a Thread used by the Console.
////    System.out.println("\nLets throw an error on this console");	
////    errorThrower=new Thread(this);
////    errorThrower.setDaemon(true);
////    errorThrower.start();					
//  }
//
//  public synchronized void windowClosed(WindowEvent evt)
//  {
//    quit=true;
//    this.notifyAll(); // stop all threads
//    try { 
//      reader.join(1000);
//      pin.close();
//      System.setOut(this.cOut);
//    } 
//    catch (Exception e){
//    }		
//    try { 
//      reader2.join(1000);
//      pin2.close(); 
//      System.setErr(this.cErr);
//    } 
//    catch (Exception e){
//    }
////    System.exit(0);
//  }		
//
//  public synchronized void windowClosing(WindowEvent evt)
//  {
//    frame.setVisible(false); // default behaviour of JFrame	
//    frame.dispose();
//  }
//
//  public synchronized void actionPerformed(ActionEvent evt)
//  {
//    textArea.setText("");
//  }
//
//  public synchronized void run()
//  {
//    try
//    {			
//      while (Thread.currentThread()==reader)
//      {
//        try { 
//          this.wait(100);
//        }
//        catch(InterruptedException ie) {
//        }
//        if (pin.available()!=0)
//        {
//          String input=this.readLine(pin);
//          textArea.append(input);
//          textArea.setCaretPosition(textArea.getDocument().getLength());
//
//        }
//        if (quit) return;
//      }
//
//      while (Thread.currentThread()==reader2)
//      {
//        try { 
//          this.wait(100);
//        }
//        catch(InterruptedException ie) {
//        }
//        if (pin2.available()!=0)
//        {
//          String input=this.readLine(pin2);
//          textArea.append(input);
//          textArea.setCaretPosition(textArea.getDocument().getLength());
//
//        }
//        if (quit) return;
//      }			
//    } 
//    catch (Exception e)
//    {
//      textArea.append("\nConsole reports an Internal error.");
//      textArea.append("The error is: "+e);			
//    }
//  }
//  
//  public void close()
//  {
//    this.windowClosing(null);
//  }
//
//  public synchronized String readLine(PipedInputStream in) throws IOException
//  {
//    String input="";
//    do
//    {
//      int available=in.available();
//      if (available==0) break;
//      byte b[]=new byte[available];
//      in.read(b);
//      input=input+new String(b,0,b.length);														
//    }
//    while( !input.endsWith("\n") &&  !input.endsWith("\r\n") && !quit);
//    return input;
//  }				
//}
