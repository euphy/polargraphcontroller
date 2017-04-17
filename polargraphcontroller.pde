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
 http://www.polargraph.co.uk
 https://github.com/euphy/polargraphcontroller
 
 */

//import processing.video.*;
import diewald_CV_kit.libraryinfo.*;
import diewald_CV_kit.utility.*;
import diewald_CV_kit.blobdetection.*;

import geomerative.*;
//import org.apache.batik.svggen.font.table.*;
//import org.apache.batik.svggen.font.*;
import java.util.zip.CRC32;


// for OSX
import java.text.*;
import java.util.*;
import java.io.*;

import java.util.logging.*;
import javax.swing.*;
import processing.serial.*;
import controlP5.*;
import java.awt.event.KeyEvent;
import java.awt.event.*;
import java.awt.Frame;
import java.awt.BorderLayout;

import java.lang.reflect.Method;

int majorVersionNo = 2;
int minorVersionNo = 4;
int buildNo = 2;

String programTitle = "Polargraph Controller v" + majorVersionNo + "." + minorVersionNo + " build " + buildNo;
ControlP5 cp5;
Map<String, ControlP5> cp5s = new HashMap<String, ControlP5>();

boolean drawbotReady = false;
boolean drawbotConnected = false;

static final int HARDWARE_VER_UNO = 1;
static final int HARDWARE_VER_MEGA = 100;
static final int HARDWARE_VER_MEGA_POLARSHIELD = 200;
static final int HARDWARE_VER_POLARPRO = 300;
int currentHardware = HARDWARE_VER_MEGA_POLARSHIELD;

final int HARDWARE_ATMEGA328_SRAM = 2048;
final int HARDWARE_ATMEGA1280_SRAM = 8096;
int currentSram = HARDWARE_ATMEGA328_SRAM;

String newMachineName = "PGXXABCD";
PVector machinePosition = new PVector(130.0, 50.0);
float machineScaling = 1.0;
DisplayMachine displayMachine = null;

int homeALengthMM = 400;
int homeBLengthMM = 400;

// preset sizes - these can be referred to in the properties file
// and will be automatically converted to numbers when loaded.
final String PRESET_A3_SHORT = "A3SHORT";
final String PRESET_A3_LONG = "A3LONG";
final String PRESET_A2_SHORT = "A2SHORT";
final String PRESET_A2_LONG = "A2LONG";
final String PRESET_A2_IMP_SHORT = "A2+SHORT";
final String PRESET_A2_IMP_LONG = "A2+LONG";
final String PRESET_A1_SHORT = "A1SHORT";
final String PRESET_A1_LONG = "A1LONG";

final int A3_SHORT = 297;
final int A3_LONG = 420;
final int A2_SHORT = 418;
final int A2_LONG = 594;
final int A2_IMP_SHORT = 450;
final int A2_IMP_LONG = 640;
final int A1_SHORT = 594;
final int A1_LONG = 841;

int leftEdgeOfQueue = 800;
int rightEdgeOfQueue = 1100;
int topEdgeOfQueue = 0;
int bottomEdgeOfQueue = 0;
int queueRowHeight = 15;

int baudRate = 57600;
Serial myPort;                       // The serial port
int[] serialInArray = new int[1];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive

boolean[] keys = new boolean[526];

final JFileChooser chooser = new JFileChooser();

SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy hh:mm:ss");

String commandStatus = "Waiting for a click.";

float sampleArea = 10;
float gridSize = 75.0;
float currentPenWidth = 0.8;
float penIncrement = 0.05;

int penLiftDownPosition = 90;
int penLiftUpPosition = 180;
// this variable controls how big the pixels are scaled when drawn.
// 1.0 represents full size, 2.0 would be twice as big as the grid size,
// 0.5 would be half the grid size.
float pixelScalingOverGridSize = 1.0;

float currentMachineMaxSpeed = 600.0;
float currentMachineAccel = 400.0;
float MACHINE_ACCEL_INCREMENT = 25.0;
float MACHINE_MAXSPEED_INCREMENT = 25.0;

List<String> commandQueue = new ArrayList<String>();
List<String> realtimeCommandQueue = new ArrayList<String>();
List<String> commandHistory = new ArrayList<String>();
List<String> machineMessageLog = new ArrayList<String>();

List<PreviewVector> previewCommandList = new ArrayList<PreviewVector>();
long lastCommandQueueHash = 0L;

File lastImageDirectory = null;
File lastPropertiesDirectory = null;

String lastCommand = "";
String lastDrawingCommand = "";
Boolean commandQueueRunning = false;
static final int DRAW_DIR_NE = 1;
static final int DRAW_DIR_SE = 2;
static final int DRAW_DIR_SW = 3;
static final int DRAW_DIR_NW = 4;
static final int DRAW_DIR_N = 5;
static final int DRAW_DIR_E = 6;
static final int DRAW_DIR_S = 7;
static final int DRAW_DIR_W = 8;

static final int DRAW_DIR_MODE_AUTO = 1;
static final int DRAW_DIR_MODE_PRESET = 2;
static final int DRAW_DIR_MODE_RANDOM = 3;
static int pixelDirectionMode = DRAW_DIR_MODE_PRESET;

static final int PIXEL_STYLE_SQ_FREQ = 0;
static final int PIXEL_STYLE_SQ_SIZE = 1;
static final int PIXEL_STYLE_SQ_SOLID = 2;
static final int PIXEL_STYLE_SCRIBBLE = 3;
static final int PIXEL_STYLE_CIRCLE = 4;
static final int PIXEL_STYLE_SAW = 5;


PVector currentMachinePos = new PVector();
PVector currentCartesianMachinePos = new PVector();
int machineAvailMem = 0;
int machineUsedMem = 0;
int machineMinAvailMem = 2048;


//String testPenWidthCommand = "TESTPENWIDTHSCRIBBLE,";
String testPenWidthCommand = CMD_TESTPENWIDTHSQUARE;
float testPenWidthStartSize = 0.5;
float testPenWidthEndSize = 2.0;
float testPenWidthIncrementSize = 0.5;

int machineStepMultiplier = 8;

int maxSegmentLength = 2;

static final String MODE_BEGIN = "button_mode_begin";
static final String MODE_DRAW_OUTLINE_BOX = "button_mode_drawOutlineBox";
static final String MODE_DRAW_OUTLINE_BOX_ROWS = "button_mode_drawOutlineBoxRows";
static final String MODE_DRAW_SHADE_BOX_ROWS_PIXELS = "button_mode_drawShadeBoxRowsPixels";
static final String MODE_RENDER_SQUARE_PIXELS = "button_mode_renderSquarePixel";
static final String MODE_RENDER_SAW_PIXELS = "button_mode_renderSawPixel";
static final String MODE_RENDER_CIRCLE_PIXELS = "button_mode_renderCirclePixel";
static final String MODE_RENDER_PIXEL_DIALOG = "button_mode_drawPixelsDialog";

static final String MODE_INPUT_ROW_START = "button_mode_inputRowStart";
static final String MODE_INPUT_ROW_END = "button_mode_inputRowEnd";
static final String MODE_DRAW_TESTPATTERN = "button_mode_drawTestPattern";
static final String MODE_DRAW_GRID = "button_mode_drawGrid";
static final String MODE_PLACE_IMAGE = "button_mode_placeImage";
static final String MODE_LOAD_IMAGE = "button_mode_loadImage";
static final String MODE_PAUSE_QUEUE = "button_mode_pauseQueue";
static final String MODE_RUN_QUEUE = "button_mode_runQueue";
static final String MODE_SET_POSITION_HOME = "button_mode_setPositionHome";
static final String MODE_RETURN_TO_HOME = "button_mode_returnToHome";
static final String MODE_INPUT_SINGLE_PIXEL = "button_mode_inputSinglePixel";
static final String MODE_DRAW_TEST_PENWIDTH = "button_mode_drawTestPenWidth";
static final String MODE_RENDER_SCALED_SQUARE_PIXELS = "button_mode_renderScaledSquarePixels";
static final String MODE_RENDER_SOLID_SQUARE_PIXELS = "button_mode_renderSolidSquarePixels";
static final String MODE_RENDER_SCRIBBLE_PIXELS = "button_mode_renderScribblePixels";
static final String MODE_CHANGE_MACHINE_SPEC = "button_mode_changeMachineSpec";
static final String MODE_REQUEST_MACHINE_SIZE = "button_mode_requestMachineSize";
static final String MODE_RESET_MACHINE = "button_mode_resetMachine";

static final String MODE_SAVE_PROPERTIES = "button_mode_saveProperties";
static final String MODE_SAVE_AS_PROPERTIES = "button_mode_saveAsProperties";
static final String MODE_LOAD_PROPERTIES = "button_mode_loadProperties";

static final String MODE_INC_SAMPLE_AREA = "button_mode_incSampleArea";
static final String MODE_DEC_SAMPLE_AREA = "button_mode_decSampleArea";
static final String MODE_INPUT_IMAGE = "button_mode_inputImage";
static final String MODE_IMAGE_PIXEL_BRIGHT_THRESHOLD = "numberbox_mode_pixelBrightThreshold";
static final String MODE_IMAGE_PIXEL_DARK_THRESHOLD = "numberbox_mode_pixelDarkThreshold";

static final String MODE_CONVERT_BOX_TO_PICTUREFRAME = "button_mode_convertBoxToPictureframe";
static final String MODE_SELECT_PICTUREFRAME = "button_mode_selectPictureframe";
static final String MODE_EXPORT_QUEUE = "button_mode_exportQueue";
static final String MODE_IMPORT_QUEUE = "button_mode_importQueue";
static final String MODE_CLEAR_QUEUE = "button_mode_clearQueue";
static final String MODE_FIT_IMAGE_TO_BOX = "button_mode_fitImageToBox";
static final String MODE_RESIZE_IMAGE = "numberbox_mode_resizeImage";
static final String MODE_RENDER_COMMAND_QUEUE = "button_mode_renderCommandQueue";

static final String MODE_MOVE_IMAGE = "toggle_mode_moveImage";
static final String MODE_SET_POSITION = "toggle_mode_setPosition";
static final String MODE_INPUT_BOX_TOP_LEFT = "toggle_mode_inputBoxTopLeft";
static final String MODE_INPUT_BOX_BOT_RIGHT = "toggle_mode_inputBoxBotRight";
static final String MODE_DRAW_TO_POSITION = "toggle_mode_drawToPosition";
static final String MODE_DRAW_DIRECT = "toggle_mode_drawDirect";

static final String MODE_CHANGE_SAMPLE_AREA = "numberbox_mode_changeSampleArea";
static final String MODE_CHANGE_GRID_SIZE = "numberbox_mode_changeGridSize";

static final String MODE_SHOW_DENSITY_PREVIEW = "minitoggle_mode_showDensityPreview";
static final String MODE_SHOW_IMAGE = "minitoggle_mode_showImage";
static final String MODE_SHOW_QUEUE_PREVIEW = "minitoggle_mode_showQueuePreview";
static final String MODE_SHOW_VECTOR = "minitoggle_mode_showVector";
static final String MODE_SHOW_GUIDES = "minitoggle_mode_showGuides";

static final String MODE_CHANGE_MACHINE_WIDTH = "numberbox_mode_changeMachineWidth";
static final String MODE_CHANGE_MACHINE_HEIGHT = "numberbox_mode_changeMachineHeight";
static final String MODE_CHANGE_MM_PER_REV = "numberbox_mode_changeMMPerRev";
static final String MODE_CHANGE_STEPS_PER_REV = "numberbox_mode_changeStepsPerRev";
static final String MODE_CHANGE_STEP_MULTIPLIER = "numberbox_mode_changeStepMultiplier";
static final String MODE_CHANGE_PAGE_WIDTH = "numberbox_mode_changePageWidth";
static final String MODE_CHANGE_PAGE_HEIGHT = "numberbox_mode_changePageHeight";
static final String MODE_CHANGE_PAGE_OFFSET_X = "numberbox_mode_changePageOffsetX";
static final String MODE_CHANGE_PAGE_OFFSET_Y = "numberbox_mode_changePageOffsetY";
static final String MODE_CHANGE_PAGE_OFFSET_X_CENTRE = "button_mode_changePageOffsetXCentre";

static final String MODE_CHANGE_HOMEPOINT_X = "numberbox_mode_changeHomePointX";
static final String MODE_CHANGE_HOMEPOINT_Y = "numberbox_mode_changeHomePointY";
static final String MODE_CHANGE_HOMEPOINT_X_CENTRE = "button_mode_changeHomePointXCentre";

static final String MODE_CHANGE_PEN_WIDTH = "numberbox_mode_changePenWidth";
static final String MODE_SEND_PEN_WIDTH = "button_mode_sendPenWidth";

static final String MODE_CHANGE_PEN_TEST_START_WIDTH = "numberbox_mode_changePenTestStartWidth";
static final String MODE_CHANGE_PEN_TEST_END_WIDTH = "numberbox_mode_changePenTestEndWidth";
static final String MODE_CHANGE_PEN_TEST_INCREMENT_SIZE = "numberbox_mode_changePenTestIncrementSize";

static final String MODE_CHANGE_MACHINE_MAX_SPEED = "numberbox_mode_changeMachineMaxSpeed";
static final String MODE_CHANGE_MACHINE_ACCELERATION = "numberbox_mode_changeMachineAcceleration";
static final String MODE_SEND_MACHINE_SPEED = "button_mode_sendMachineSpeed";
static final String MODE_SEND_MACHINE_SPEED_PERSIST = "button_mode_sendMachineSpeedPersist";

static final String MODE_RENDER_VECTORS = "button_mode_renderVectors";
static final String MODE_LOAD_VECTOR_FILE = "button_mode_loadVectorFile";
static final String MODE_CHANGE_MIN_VECTOR_LINE_LENGTH = "numberbox_mode_changeMinVectorLineLength";

static final String MODE_CHANGE_SERIAL_PORT = "button_mode_serialPortDialog";
static final String MODE_SEND_MACHINE_STORE_MODE = "button_mode_machineStoreDialog";
static final String MODE_SEND_MACHINE_LIVE_MODE = "button_mode_sendMachineLiveMode";
static final String MODE_SEND_MACHINE_EXEC_MODE = "button_mode_machineExecDialog";

static final String MODE_RESIZE_VECTOR = "numberbox_mode_resizeVector";
static final String MODE_MOVE_VECTOR = "toggle_mode_moveVector";

static final String MODE_CHOOSE_CHROMA_KEY_COLOUR = "toggle_mode_chooseChromaKeyColour";
static final String MODE_CHANGE_PIXEL_SCALING = "numberbox_mode_changePixelScaling";
static final String MODE_PEN_LIFT_UP = "button_mode_penUp";
static final String MODE_PEN_LIFT_DOWN = "button_mode_penDown";
static final String MODE_PEN_LIFT_POS_UP = "numberbox_mode_penUpPos";
static final String MODE_PEN_LIFT_POS_DOWN = "numberbox_mode_penDownPos";
static final String MODE_SEND_PEN_LIFT_RANGE = "button_mode_sendPenliftRange";
static final String MODE_SEND_PEN_LIFT_RANGE_PERSIST = "button_mode_sendPenliftRangePersist";

static final String MODE_SEND_ROVE_AREA = "button_mode_sendRoveArea";
static final String MODE_SELECT_ROVE_IMAGE_SOURCE = "button_mode_selectRoveImageSource";
static final String MODE_SEND_START_TEXT = "toggle_mode_sendStartText";
// controls to do with text start
static final String MODE_CHANGE_TEXT_ROW_SIZE = "numberbox_mode_changeTextRowSize";
static final String MODE_CHANGE_TEXT_ROW_SPACING = "numberbox_mode_changeTextRowSize";

static final String MODE_SHOW_WRITING_DIALOG = "button_mode_drawWritingDialog";
static final String MODE_START_SWIRLING = "button_mode_startSwirling";
static final String MODE_STOP_SWIRLING = "button_mode_stopSwirling";
static final String MODE_START_MARKING = "button_mode_startMarking";
static final String MODE_STOP_MARKING = "button_mode_stopMarking";
static final String MODE_START_SPRITE = "button_mode_drawSpriteDialog";
static final String MODE_START_RANDOM_SPRITES = "button_mode_startRandomSprite";
static final String MODE_STOP_RANDOM_SPRITES = "button_mode_stopRandomSprites";
static final String MODE_DRAW_NORWEGIAN_DIALOG = "button_mode_drawNorwegianDialog";

static final String MODE_LIVE_BLUR_VALUE = "numberbox_mode_liveBlurValue";
static final String MODE_LIVE_SIMPLIFICATION_VALUE = "numberbox_mode_liveSimplificationValue";
static final String MODE_LIVE_POSTERISE_VALUE = "numberbox_mode_livePosteriseValue";
static final String MODE_LIVE_CAPTURE_FROM_LIVE = "button_mode_liveCaptureFromLive";
static final String MODE_LIVE_CANCEL_CAPTURE = "button_mode_liveClearCapture";
static final String MODE_LIVE_ADD_CAPTION = "button_mode_liveAddCaption";
static final String MODE_LIVE_CONFIRM_DRAW = "button_mode_liveConfirmDraw";

static final String MODE_VECTOR_PATH_LENGTH_HIGHPASS_CUTOFF = "numberbox_mode_vectorPathLengthHighPassCutoff";
static final String MODE_SHOW_WEBCAM_RAW_VIDEO = "toggle_mode_showWebcamRawVideo";
static final String MODE_FLIP_WEBCAM_INPUT = "toggle_mode_flipWebcam";
static final String MODE_ROTATE_WEBCAM_INPUT = "toggle_mode_rotateWebcam";

static final String MODE_SEND_BUTTON_ACTIVATE = "button_mode_sendButtonActivate";
static final String MODE_SEND_BUTTON_DEACTIVATE = "button_mode_sendButtonDeactivate";

static final String MODE_ADJUST_PREVIEW_CORD_OFFSET = "numberbox_mode_previewCordOffsetValue";

static final String MODE_CYCLE_DENSITY_PREVIEW_STYLE = "button_mode_cycleDensityPreviewStyle";

static final String MODE_CHANGE_DENSITY_PREVIEW_POSTERIZE = "numberbox_mode_changeDensityPreviewPosterize";
static final String MODE_PREVIEW_PIXEL_DENSITY_RANGE = "minitoggle_mode_previewPixelDensityRange";

static final String MODE_CHANGE_POLYGONIZER = "button_mode_cyclePolygonizer";
static final String MODE_CHANGE_POLYGONIZER_LENGTH = "numberbox_mode_changePolygonizerLength";





PVector statusTextPosition = new PVector(300.0, 12.0);

static String currentMode = MODE_BEGIN;
static String lastMode = MODE_BEGIN;

static PVector boxVector1 = null;
static PVector boxVector2 = null;

static PVector rowsVector1 = null;
static PVector rowsVector2 = null;

static final float MASKED_PIXEL_BRIGHTNESS = -1.0;
static int pixelExtractBrightThreshold = 255;
static int pixelExtractDarkThreshold = 0;
static boolean liftPenOnMaskedPixels = true;
int numberOfPixelsTotal = 0;
int numberOfPixelsCompleted = 0;

Date timerStart = null;
Date timeLastPixelStarted = null;

boolean pixelTimerRunning = false;
boolean displayingSelectedCentres = false;
boolean displayingRowGridlines = false;
boolean displayingInfoTextOnInputPage = false;
boolean displayingGridSpots = true;

boolean displayingImage = true;
boolean displayingVector = true;
boolean displayingQueuePreview = true;
boolean displayingDensityPreview = false;

boolean displayingGuides = true;

static final int DENSITY_PREVIEW_STYLE_COUNT = 6;

static final int DENSITY_PREVIEW_ROUND = 0;
static final int DENSITY_PREVIEW_DIAMOND = 1;
static final int DENSITY_PREVIEW_NATIVE = 2;
static final int DENSITY_PREVIEW_NATIVE_ARC = 3;
static final int DENSITY_PREVIEW_ROUND_SIZE = 4;
static final int DENSITY_PREVIEW_NATIVE_SIZE = 5;

static final int DEFAULT_DENSITY_PREVIEW_STYLE = DENSITY_PREVIEW_NATIVE;
int densityPreviewStyle = DEFAULT_DENSITY_PREVIEW_STYLE;
int densityPreviewPosterize = 255;
boolean previewPixelDensityRange = true;

static final byte COORD_MODE_NATIVE_STEPS = 0;
static final byte COORD_MODE_NATIVE_MM = 1;
static final byte COORD_MODE_CARTESIAN_MM_ABS = 2;
static final byte COORD_MODE_CARTESIAN_MM_SCALED = 3;


boolean useSerialPortConnection = false;

static final char BITMAP_BACKGROUND_COLOUR = 0x0F;

PVector homePointCartesian = null;

public color chromaKeyColour = color(0,255,0);

// used in the preview page
public color pageColour = color(220);
public color frameColour = color(200,0,0);
public color machineColour = color(150);
public color guideColour = color(255);
public color backgroundColour = color(100);
public color densityPreviewColour = color(0);

public Integer previewCordOffset = 0;

public boolean debugPanels = false;

public boolean showingSummaryOverlay = true;
public boolean showingDialogBox = false;

public Integer windowWidth = 650;
public Integer windowHeight = 400;

public static Integer serialPortNumber = -1;

public Textarea consoleArea = null;
public Println console = null;
public PrintStream savedOut = null;

Properties props = null;
public static String propertiesFilename = "default.properties.txt";
public static String newPropertiesFilename = null;

public static final String TAB_NAME_INPUT= "default";
public static final String TAB_LABEL_INPUT = "input";
public static final String TAB_NAME_ROVING = "tab_roving";
public static final String TAB_LABEL_ROVING = "Roving";
public static final String TAB_NAME_DETAILS = "tab_details";
public static final String TAB_LABEL_DETAILS = "Setup";
public static final String TAB_NAME_QUEUE = "tab_queue";
public static final String TAB_LABEL_QUEUE = "Queue";
public static final String TAB_NAME_TRACE = "tab_trace";
public static final String TAB_LABEL_TRACE = "Trace";

// Page states
public String currentTab = TAB_NAME_INPUT;


public static final String PANEL_NAME_INPUT = "panel_input";
public static final String PANEL_NAME_ROVING = "panel_roving";
public static final String PANEL_NAME_DETAILS = "panel_details";
public static final String PANEL_NAME_QUEUE = "panel_queue";
public static final String PANEL_NAME_TRACE = "panel_trace";

public static final String PANEL_NAME_GENERAL = "panel_general";

public final PVector DEFAULT_CONTROL_SIZE = new PVector(100.0, 20.0);
public final PVector CONTROL_SPACING = new PVector(4.0, 4.0);
public PVector mainPanelPosition = new PVector(10.0, 85.0);

public final Integer PANEL_MIN_HEIGHT = 400;

public Set<String> panelNames = null;
public List<String> tabNames = null;
public Set<String> controlNames = null;
public Map<String, List<Controller>> controlsForPanels = null;

public Map<String, Controller> allControls = null;
public Map<String, String> controlLabels = null;
public Set<String> controlsToLockIfBoxNotSpecified = null;
public Set<String> controlsToLockIfImageNotLoaded = null;

public Map<String, Set<Panel>> panelsForTabs = null;
public Map<String, Panel> panels = null;

// machine moving
PVector machineDragOffset = new PVector (0.0, 0.0);
PVector lastMachineDragPosition = new PVector (0.0, 0.0);
public final float MIN_SCALING = 0.01;
public final float MAX_SCALING = 30.0;

RShape vectorShape = null;
String vectorFilename = null;
float vectorScaling = 100;
PVector vectorPosition = new PVector(0.0,0.0);
int minimumVectorLineLength = 2;
public static final int VECTOR_FILTER_LOW_PASS = 0;


String storeFilename = "comm.txt";
boolean overwriteExistingStoreFile = true;

static boolean drawingTraceShape = true;
static boolean retraceShape = true;
static boolean flipWebcamImage = false;
static boolean rotateWebcamImage = false;
static boolean confirmedDraw = false;

static PImage liveImage = null;
static PImage processedLiveImage = null;
static PImage capturedImage = null;
static PImage processedCapturedImage = null;

static final Integer LIVE_SIMPLIFICATION_MIN = 1;
static final Integer LIVE_SIMPLIFICATION_MAX = 32;

static int pathLengthHighPassCutoff = 0;
static final Integer PATH_LENGTH_HIGHPASS_CUTOFF_MAX = 10000;
static final Integer PATH_LENGTH_HIGHPASS_CUTOFF_MIN = 0;

BlobDetector blob_detector;
int liveSimplification = 5;
int blurValue = 1;
int posterizeValue = 5;
int sepKeyColour = color(0, 0, 255);

Map<Integer, PImage> colourSeparations = null;
RShape traceShape = null;
RShape captureShape = null;

String shapeSavePath = "../../savedcaptures/";
String shapeSavePrefix = "shape-";
String shapeSaveExtension = ".svg";

static Float gcodeZAxisDrawingHeight = 1.0; //-0.125000;

String filePath = null;

static PApplet parentPapplet = null;

boolean rescaleDisplayMachine = true;

// Polygonization. It's a geomerative thing.
int polygonizer = 0;
float polygonizerLength = 0.0;

void setup()
{
  println("Running polargraph controller");
  frame.setResizable(true);
  initLogging();
  parentPapplet = this;
  

  try 
  { 
    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); 
  } 
  catch (Exception e) 
  { 
    e.printStackTrace();   
  }

  RG.init(this);
  loadFromPropertiesFile();

  size(windowWidth, windowHeight);
  this.cp5 = new ControlP5(this);
  initTabs();
  
  String[] serialPorts = Serial.list();
  println("Serial ports available on your machine:");
  println(serialPorts);

  if (getSerialPortNumber() >= 0)
  {
    println("About to connect to serial port in slot " + getSerialPortNumber());
    // Print a list of the serial ports, for debugging purposes:
    if (serialPorts.length > 0)
    {
      String portName = null;
      try 
      {
        println("Get serial port no: "+getSerialPortNumber());
        portName = serialPorts[getSerialPortNumber()];
        myPort = new Serial(this, portName, getBaudRate());
        //read bytes into a buffer until you get a linefeed (ASCII 10):
        myPort.bufferUntil('\n');
        useSerialPortConnection = true;
        println("Successfully connected to port " + portName);
      }
      catch (Exception e)
      {
        println("Attempting to connect to serial port " 
        + portName + " in slot " + getSerialPortNumber() 
        + " caused an exception: " + e.getMessage());
      }
    }
    else
    {
      println("No serial ports found.");
      useSerialPortConnection = false;
    }
  }
  else
  {
    useSerialPortConnection = false;
  }

  currentMode = MODE_BEGIN;
  preLoadCommandQueue();
  changeTab(TAB_NAME_INPUT, TAB_NAME_INPUT);

  addEventListeners();

  frameRate(8);
  noLoop();
}

void fitDisplayMachineToWindow() {
  
  Rectangle gr = panels.get(PANEL_NAME_GENERAL).getOutline();
  println(gr);
  
  Rectangle ir = panels.get(PANEL_NAME_INPUT).getOutline();
  println(ir);
  
  float targetHeight = ir.getBottom() - gr.getTop() - CONTROL_SPACING.y;
  println("Target height is " + targetHeight + " pixels");
  
  float machineHeight = getDisplayMachine().getOutline().getHeight();
  println(machineHeight);
  
  machineScaling = (targetHeight / machineHeight);
  println(machineScaling);
  
  if (machineScaling < 0) {
    machineScaling = 1.0;
  }
  
  getDisplayMachine().getOffset().x = ((gr.getRight() > ir.getRight()) ? gr.getRight() : ir.getRight()) + CONTROL_SPACING.x;
  getDisplayMachine().getOffset().y = gr.getTop();
  
}

void addEventListeners()
{
  frame.addComponentListener(new ComponentAdapter() 
    {
      public void componentResized(ComponentEvent event) 
      {
      windowResized();
//        if (event.getSource()==frame) 
//        {
//  	  windowResized();
//        }
      }
    }
  );
  
  addMouseWheelListener(new java.awt.event.MouseWheelListener() 
    { 
      public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) 
      { 
        mouseWheel(evt.getWheelRotation());
      }
    }
  ); 
}  


void preLoadCommandQueue()
{
  addToCommandQueue(CMD_CHANGEPENWIDTH+currentPenWidth+",END");
  addToCommandQueue(CMD_SETMOTORSPEED+currentMachineMaxSpeed+",END");
  addToCommandQueue(CMD_SETMOTORACCEL+currentMachineAccel+",END");
}

void windowResized()
{
  noLoop();
  windowWidth = frame.getWidth();
  windowHeight = frame.getHeight();
  println("New window size: " + windowWidth + " x " + windowHeight);
  if (frame.getExtendedState() == Frame.MAXIMIZED_BOTH) {
    println("Max");
    frame.setExtendedState(0);
    frame.setSize(windowWidth, windowHeight);
  }
  
  for (String key : getPanels().keySet())
  {
    Panel p = getPanels().get(key);
    p.setSizeByHeight(windowHeight - p.getOutline().getTop() - (DEFAULT_CONTROL_SIZE.y*2));
    if (debugPanels) {
      println("Resize " + key + " to be " + p.getOutline().getWidth() + "px across, " + p.getOutline().getHeight() + "px tall");
    }
  }

  // Required to tell CP5 to be able to use the new sized window
  // How does this work?
  cp5.setGraphics(this,0,0);
  
  loop();
}

void draw()
{

  if (getCurrentTab() == TAB_NAME_INPUT) {
    drawImagePage();
  }
  else if (getCurrentTab() == TAB_NAME_QUEUE) {
    drawCommandQueuePage();
  }
  else if (getCurrentTab() == TAB_NAME_DETAILS) {
    drawDetailsPage();
  }
  else if (getCurrentTab() == TAB_NAME_ROVING) {
    drawRovingPage();
  }
  else if (getCurrentTab() == TAB_NAME_TRACE) {
    drawTracePage();
  }
  else {
    drawDetailsPage();
  }

  if (isShowingSummaryOverlay()) {
    drawSummaryOverlay();
  }
  
  if (isShowingDialogBox()) {
    drawDialogBox();
  }

  if (drawbotReady) {
    dispatchCommandQueue();
  }
}

String getCurrentTab()
{
  return this.currentTab;
}

boolean isShowingSummaryOverlay()
{
  return this.showingSummaryOverlay;
}
void drawSummaryOverlay()
{
}
boolean isShowingDialogBox()
{
  return false;
}
void drawDialogBox()
{
  
}
String getVectorFilename()
{
  return this.vectorFilename;
}
void setVectorFilename(String filename)
{
  this.vectorFilename = filename;
}
RShape getVectorShape()
{
  return this.vectorShape;
}
void setVectorShape(RShape shape)
{
  this.vectorShape = shape;
}

color getPageColour()
{
  return this.pageColour;
}
color getMachineColour()
{
  return this.machineColour;
}
color getBackgroundColour()
{
  return this.backgroundColour;
}
color getGuideColour()
{
  return this.guideColour;
}
color getFrameColour()
{
  return this.frameColour;
}


Panel getPanel(String panelName)
{
  return getPanels().get(panelName);
}

void drawImagePage()
{
  strokeWeight(1);
  background(getBackgroundColour());
  noFill();
  stroke(255, 150, 255, 100);
  strokeWeight(3);
  stroke(150);
  noFill();
  if (rescaleDisplayMachine) {
    fitDisplayMachineToWindow();
    rescaleDisplayMachine = false;
  }
  getDisplayMachine().draw();
  drawMoveImageOutline();
  stroke(255, 0, 0);
 
  for (Panel panel : getPanelsForTab(TAB_NAME_INPUT))
  {
    panel.draw();
  }
  stroke(200,200);
  text(propertiesFilename, getPanel(PANEL_NAME_GENERAL).getOutline().getLeft(), getPanel(PANEL_NAME_GENERAL).getOutline().getTop()-7);

  showGroupBox();
  showCurrentMachinePosition();
  if (displayingQueuePreview)
    previewQueue();
  if (displayingInfoTextOnInputPage)
    showText(250,45);
  drawStatusText((int)statusTextPosition.x, (int)statusTextPosition.y);

  showCommandQueue((int) getDisplayMachine().getOutline().getRight()+6, 20);
}

void drawMachineOutline()
{
  rect(machinePosition.x,machinePosition.y, machinePosition.x+getDisplayMachine().getWidth(), machinePosition.y+getDisplayMachine().getHeight());
}
void drawDetailsPage()
{
  strokeWeight(1);
  background(100);
  noFill();
  stroke(255, 150, 255, 100);
  strokeWeight(3);
  stroke(150);
  noFill();
  getDisplayMachine().drawForSetup();
  stroke(255, 0, 0);
 
  for (Panel panel : getPanelsForTab(TAB_NAME_DETAILS))
  {
    panel.draw();
  }
  text(propertiesFilename, getPanel(PANEL_NAME_GENERAL).getOutline().getLeft(), getPanel(PANEL_NAME_GENERAL).getOutline().getTop()-7);

//  showCurrentMachinePosition();
  if (displayingInfoTextOnInputPage)
    showText(250,45);
  drawStatusText((int)statusTextPosition.x, (int)statusTextPosition.y);

  showCommandQueue((int) getDisplayMachine().getOutline().getRight()+6, 20);
}

void drawRovingPage()
{
  strokeWeight(1);
  background(100);
  noFill();
  stroke(255, 150, 255, 100);
  strokeWeight(3);
  stroke(150);
  noFill();
  getDisplayMachine().drawForSetup();
  stroke(255, 0, 0);
 
  for (Panel panel : getPanelsForTab(TAB_NAME_ROVING))
  {
    panel.draw();
  }
  text(propertiesFilename, getPanel(PANEL_NAME_GENERAL).getOutline().getLeft(), getPanel(PANEL_NAME_GENERAL).getOutline().getTop()-7);

//  showCurrentMachinePosition();
  showGroupBox();
  showCurrentMachinePosition();
  if (displayingInfoTextOnInputPage)
    showText(250,45);
  drawStatusText((int)statusTextPosition.x, (int)statusTextPosition.y);

  showCommandQueue((int) getDisplayMachine().getOutline().getRight()+6, 20);
}

void drawTracePage()
{
  strokeWeight(1);
  background(100);
  noFill();
  stroke(255, 150, 255, 100);
  strokeWeight(3);
  stroke(150);
  noFill();
  getDisplayMachine().drawForTrace();
  if (displayingImage && getDisplayMachine().imageIsReady() && retraceShape)
  {
    processedLiveImage = trace_processImageForTrace(getDisplayMachine().getImage());
    colourSeparations = trace_buildSeps(processedLiveImage, sepKeyColour);
    traceShape = trace_traceImage(colourSeparations);
    drawingTraceShape = true;
  }

  stroke(255, 0, 0);
 
  for (Panel panel : getPanelsForTab(TAB_NAME_TRACE))
  {
    panel.draw();
  }
  text(propertiesFilename, getPanel(PANEL_NAME_GENERAL).getOutline().getLeft(), getPanel(PANEL_NAME_GENERAL).getOutline().getTop()-7);


  if (displayingInfoTextOnInputPage)
    showText(250,45);
  drawStatusText((int)statusTextPosition.x, (int)statusTextPosition.y);
  showCommandQueue((int) width-200, 20);


//  processGamepadInput();
//
//  if (displayGamepadOverlay)
//    displayGamepadOverlay();
}


void drawCommandQueuePage()
{
  cursor(ARROW);
  background(100);

  // machine outline
  fill(100);
  drawMachineOutline();
  showingSummaryOverlay = false;
  

  
  int right = 0;
  for (Panel panel : getPanelsForTab(TAB_NAME_QUEUE))
  {
    panel.draw();
    float r = panel.getOutline().getRight();
    if (r > right)
      right = (int) r;
  }
  text(propertiesFilename, getPanel(PANEL_NAME_GENERAL).getOutline().getLeft(), getPanel(PANEL_NAME_GENERAL).getOutline().getTop()-7);
  showCommandQueue(right, (int)mainPanelPosition.y);
  
  drawStatusText((int)statusTextPosition.x, (int)statusTextPosition.y);
  
}

void drawImageLoadPage()
{
  drawImagePage();
}



void drawMoveImageOutline()
{
  if (MODE_MOVE_IMAGE == currentMode && getDisplayMachine().getImage() != null)
  {
    // get scaled size of the  image
    PVector imageSize = getDisplayMachine().inMM(getDisplayMachine().getImageFrame().getSize());
    PVector imageSizeOnScreen = getDisplayMachine().scaleToScreen(imageSize);
    imageSizeOnScreen.sub(getDisplayMachine().getOutline().getTopLeft());
    PVector offset = new PVector(imageSizeOnScreen.x/2.0, imageSizeOnScreen.y/2.0);
    
    PVector mVect = getMouseVector();
    PVector imagePos = new PVector(mVect.x-offset.x, mVect.y-offset.y);

    fill(80,50);
    noStroke();
    rect(imagePos.x+imageSizeOnScreen.x, imagePos.y+4, 4, imageSizeOnScreen.y);
    rect(imagePos.x+4, imageSizeOnScreen.y+imagePos.y, imageSizeOnScreen.x-4, 4);
    tint(255,180);
    image(getDisplayMachine().getImage(), imagePos.x, imagePos.y, imageSizeOnScreen.x, imageSizeOnScreen.y);
    noTint();
    // decorate image
    noFill();
  }
  else if (MODE_MOVE_VECTOR == currentMode && getVectorShape() != null)
  {
    RPoint[][] pointPaths = getVectorShape().getPointsInPaths();
    RG.ignoreStyles();
    stroke(100);
    strokeWeight(1);

    // offset mouse vector so it grabs the centre of the shape
    PVector centroid = new PVector(getVectorShape().width/2, getVectorShape().height/2);
    centroid = PVector.mult(centroid, (vectorScaling/100));
    PVector offsetMouseVector = PVector.sub(getDisplayMachine().scaleToDisplayMachine(getMouseVector()), centroid);
    if (pointPaths != null)
    {
      int increment = round((pointPaths.length/10.0)+0.5);
      println(increment);
      for (int i = 0; i<pointPaths.length; i+=increment)
      {
        if (pointPaths[i] != null) 
        {
          beginShape();
          for (int j = 0; j<pointPaths[i].length; j++)
          {
            PVector p = new PVector(pointPaths[i][j].x, pointPaths[i][j].y);
            p = PVector.mult(p, (vectorScaling/100));
            p = PVector.add(p, offsetMouseVector);
            p = getDisplayMachine().scaleToScreen(p);
            vertex(p.x, p.y);
          }
          endShape();
        }
      }
    }
  }
}

void showCurrentMachinePosition()
{
  noStroke();
  fill(255,0,255,150);
  PVector pgCoord = getDisplayMachine().scaleToScreen(currentMachinePos);
  ellipse(pgCoord.x, pgCoord.y, 20, 20);

  // also show cartesian position if reported
  fill(255,255,0,150);
  ellipse(currentCartesianMachinePos.x, currentCartesianMachinePos.y, 15, 15);

  noFill();
}

void showGroupBox()
{
  if (displayingGuides)
  {
    if (isBoxSpecified())
    {
      noFill();
      stroke(getFrameColour());
      strokeWeight(1);
      PVector topLeft = getDisplayMachine().scaleToScreen(boxVector1);
      PVector botRight = getDisplayMachine().scaleToScreen(boxVector2);
      rect(topLeft.x, topLeft.y, botRight.x-topLeft.x, botRight.y-topLeft.y);
    }
    else 
    {
      noFill();
      stroke(getFrameColour());
      strokeWeight(1);
  
      if (getBoxVector1() != null)
      {
        PVector topLeft = getDisplayMachine().scaleToScreen(boxVector1);
        line(topLeft.x, topLeft.y, topLeft.x-10, topLeft.y);
        line(topLeft.x, topLeft.y, topLeft.x, topLeft.y-10);
      }
  
      if (getBoxVector2() != null)
      {
        PVector botRight = getDisplayMachine().scaleToScreen(boxVector2);
        line(botRight.x, botRight.y, botRight.x+10, botRight.y);
        line(botRight.x, botRight.y, botRight.x, botRight.y+10);
      }
    }
  }
  
}

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
        Integer code = Math.round(ins.get("G"));
        if (code >= 2) {
          continue;
        }
        
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
//        RPoint[][] points = parent.getPointsInPaths();
//        totalPoints = 0;
//        if (points != null) {
//          for (int i = 0; i<points.length; i++) {
//            if (points[i] != null) {
//              for (int j = 0; j<points[i].length; j++) {
//                totalPoints++;
//              }
//            }
//          }
//        }
//        points = null;
//        println("" + totalPoints + " points.");
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
    println("Execption reading lines from the gcode file " + filename);
    e.printStackTrace();
  }
  finally {
    try {
      reader.close();
    } 
    catch (IOException e) {
      println("Exception closing the gcode file " + filename);
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
      Float value = Float.parseFloat(splitted[i].substring(1));

      if ("X".equalsIgnoreCase(axis) || "Y".equalsIgnoreCase(axis) || "Z".equalsIgnoreCase(axis) || "G".equalsIgnoreCase(axis)) {
        instruction.put(axis, value);
      }
    }
//  println("instruction: " + instruction);
    if (instruction.isEmpty()) {
      throw new Exception();
    }
  } 
  catch (Exception e) {
    throw new Exception("Exception while reading the lines from a gcode file: " + line + ", " + e.getMessage());
  }
  
  return instruction;
}


void setPictureFrameDimensionsToBox()
{
//  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
//  {
    Rectangle r = new Rectangle(getDisplayMachine().inSteps(getBoxVector1()), getDisplayMachine().inSteps(getBoxVectorSize()));
    getDisplayMachine().setPictureFrame(r);
//  }
}
void setBoxToPictureframeDimensions()
{
  setBoxVector1(getDisplayMachine().inMM(getDisplayMachine().getPictureFrame().getTopLeft()));
  setBoxVector2(getDisplayMachine().inMM(getDisplayMachine().getPictureFrame().getBotRight()));
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    Toggle t = (Toggle) getAllControls().get(MODE_SHOW_IMAGE);
    t.setValue(0);
    t.update();

    t = (Toggle) getAllControls().get(MODE_SHOW_DENSITY_PREVIEW);
    t.setValue(1);
    t.update();
    
  }
}

float getGridSize()
{
  return this.gridSize;
}
void setGridSize(float s)
{
  // round it down
  this.gridSize = (int)s;
}

void setSampleArea(float v)
{
  this.sampleArea = v;
}

void controlEvent(ControlEvent controlEvent) 
{
  if (controlEvent.isTab()) 
  {
    if (controlEvent.tab().getName() == getCurrentTab())
    {
      // already here.
      println("Already here.");
    }
    else
    {
      changeTab(currentTab, controlEvent.tab().getName());
    }
  }
  else if(controlEvent.isGroup()) 
  {
    print("got an event from "+controlEvent.group().getName()+"\t");

    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    for (int i=0; i<controlEvent.group().getArrayValue().length; i++) 
    {
      int n = (int)controlEvent.group().getArrayValue()[i];
    }
    println();
  } 
}

void changeTab(String from, String to)
{
  // hide old panels
  currentTab = to;
  for (Panel panel : getPanelsForTab(currentTab))
  {
    for (Controller c : panel.getControls())
    {
      c.moveTo(currentTab);
      c.show();
    }
  }
}



boolean mouseOverMachine()
{
  boolean result = false;
  if (isMachineClickable())
  {
    if (getDisplayMachine().getOutline().surrounds(getMouseVector())
      && mouseOverControls().isEmpty())
    {
      result = true;
    }
    else
      result = false;
  }
  return result;
}

Set<Controller> mouseOverControls()
{
  Set<Controller> set = new HashSet<Controller>(1);
  for (String key : getAllControls().keySet())
  {
    if (getAllControls().get(key).isInside())
    {
      set.add(getAllControls().get(key));
    }
  }
  return set;
}


boolean isMachineClickable()
{
  if (getCurrentTab() == TAB_NAME_INPUT)
  {
    return true;
  }
  else if (getCurrentTab() == TAB_NAME_ROVING)
  {
    return true;
  }
  else if (getCurrentTab() == TAB_NAME_QUEUE)
  {
    return false;
  }
  else if (getCurrentTab() == TAB_NAME_DETAILS)
  {
    return false;
  }
  else
  {
    return false;
  }
}
boolean isPanelClickable()
{
  return true;
}
boolean isQueueClickable()
{
  return true;
}

boolean mouseOverPanel()
{
  boolean result = false;
  for (Panel panel : getPanelsForTab(currentTab))
  {
    if (panel.getOutline().surrounds(getMouseVector())) {
//      println("Outline: " + panel.getOutline().toString());
//      println("OVER PANEL!" + panel.getName());
      result = true;
      break;
    }
  }
  return result;
}

boolean mouseOverQueue()
{
  boolean result = true;
  if (mouseX < leftEdgeOfQueue
    || mouseX > rightEdgeOfQueue
    || mouseY < topEdgeOfQueue
    || mouseY > bottomEdgeOfQueue)
    result = false;
  return result;
}

void changeMachineScaling(int delta)
{
  boolean scalingChanged = true;
  machineScaling += (delta * (machineScaling * 0.1));
  if (machineScaling <  MIN_SCALING)
  {
    machineScaling = MIN_SCALING;
    scalingChanged = false;
  }
  else if (machineScaling > MAX_SCALING)
  {
    machineScaling = MAX_SCALING;
    scalingChanged = false;
  }
}

boolean checkKey(int k)
{
  if (keys.length >= k) {
    return keys[k];  
  }
  return false;
}

void keyReleased()
{ 
  keys[keyCode] = false; 
}

void keyPressed()
{

  keys[keyCode] = true;
  //println("key: " + KeyEvent.getKeyText(keyCode));
  //println("Keys: " + keys);
  //println("Keycode: " + keyCode);
  
  if (checkKey(CONTROL) && checkKey(KeyEvent.VK_PAGE_UP)) 
    changeMachineScaling(1);
  else if (checkKey(CONTROL) && checkKey(KeyEvent.VK_PAGE_DOWN)) 
    changeMachineScaling(-1);
  else if (checkKey(CONTROL) && checkKey(DOWN))
    getDisplayMachine().getOffset().y = getDisplayMachine().getOffset().y + 10;
  else if (checkKey(CONTROL) && checkKey(UP)) 
    getDisplayMachine().getOffset().y = getDisplayMachine().getOffset().y - 10;
  else if (checkKey(CONTROL) && checkKey(RIGHT)) 
    getDisplayMachine().getOffset().x = getDisplayMachine().getOffset().x + 10;
  else if (checkKey(CONTROL) && checkKey(LEFT)) 
    getDisplayMachine().getOffset().x = getDisplayMachine().getOffset().x - 10;
  else if (checkKey(KeyEvent.VK_ESCAPE))
    key = 0;
  else if (checkKey(CONTROL) && checkKey(KeyEvent.VK_G))
  {
    Toggle t = (Toggle) getAllControls().get(MODE_SHOW_GUIDES);
    if (displayingGuides)
    {
      minitoggle_mode_showGuides(false);
      t.setValue(0);
    }
    else
    {
      minitoggle_mode_showGuides(true);
      t.setValue(1);
    }
    t.update();
  }
  else if (checkKey(CONTROL) && checkKey(KeyEvent.VK_C))
  {
    toggleShowConsole();
  }
  else if (checkKey(CONTROL) && checkKey(KeyEvent.VK_S))
  {
    if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
      displayingSelectedCentres = (displayingSelectedCentres) ? false : true;
  }
  else if (checkKey(CONTROL) && checkKey(KeyEvent.VK_I))
  {
    displayingInfoTextOnInputPage = (displayingInfoTextOnInputPage) ? false : true;
  }
  else if (key == '#' )
  {
    addToRealtimeCommandQueue(CMD_PENUP+"END");
  }
  else if (key == '~')
  {
    addToRealtimeCommandQueue(CMD_PENDOWN+"END");
  }
  else if (key == '<')
  {
    if (this.maxSegmentLength > 1)
      this.maxSegmentLength--;
  }
  else if (key == '>')
  {
    this.maxSegmentLength++;
  }
}
void mouseDragged()
{
  if (mouseOverControls().isEmpty())
  {
    if (mouseButton == CENTER)
    {
      machineDragged();
    }
    else if (mouseButton == LEFT)
    {
      if (currentMode.equals(MODE_INPUT_BOX_TOP_LEFT))
      {
        // dragging a selection area
        PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
        setBoxVector2(pos);
      }
    }
  }
}
  
void mouseClicked()
{
  if (mouseOverPanel())
  { // changing mode
    
  }
  else
  {
    if (currentMode.equals(MODE_MOVE_IMAGE))
    {
      PVector imageSize = getDisplayMachine().inMM(getDisplayMachine().getImageFrame().getSize());
      PVector mVect = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
      PVector offset = new PVector(imageSize.x/2.0, imageSize.y/2.0);
      PVector imagePos = new PVector(mVect.x-offset.x, mVect.y-offset.y);
  
      imagePos = getDisplayMachine().inSteps(imagePos);
      getDisplayMachine().getImageFrame().setPosition(imagePos.x, imagePos.y);
  
      if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
        getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    }
    else if (currentMode.equals(MODE_MOVE_VECTOR))
    {
      // offset mouse vector so it grabs the centre of the shape
      PVector centroid = new PVector(getVectorShape().width/2, getVectorShape().height/2);
      centroid = PVector.mult(centroid, (vectorScaling/100));
      PVector offsetMouseVector = PVector.sub(getDisplayMachine().scaleToDisplayMachine(getMouseVector()), centroid);
      vectorPosition = offsetMouseVector;
    }
    else if (mouseOverQueue())
    {
      // stopping or starting 
      println("queue clicked.");
      queueClicked();
    }
    else if (mouseOverMachine())
    { 
      // picking coords
      machineClicked();
    }
  }
}

void machineDragged()
{
  if (mouseButton == CENTER)
  {
    PVector currentPos = getMouseVector();
    PVector change = PVector.sub(currentPos, lastMachineDragPosition);
    lastMachineDragPosition = new PVector(currentPos.x, currentPos.y);
    PVector currentPosition = getDisplayMachine().getOutline().getPosition();
    getDisplayMachine().getOffset().add(change);
    cursor(MOVE);
  }
}

void machineClicked()
{
  if (mouseButton == LEFT)
  {
    leftButtonMachineClick();
  }
}
void mousePressed()
{
//  println("mouse pressed");
//  println("mouse button: "+mouseButton);
//  println("Current mode: " +currentMode);
  if (mouseButton == CENTER)
  {
    middleButtonMachinePress();
    lastMachineDragPosition = getMouseVector();
  }
  else if (mouseButton == LEFT)
  {
    if (MODE_INPUT_BOX_TOP_LEFT.equals(currentMode) && mouseOverMachine())
    {
      minitoggle_mode_showImage(true);
      minitoggle_mode_showDensityPreview(false);
      PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
      setBoxVector1(pos);
      if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
      {
        getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
//        minitoggle_mode_showImage(false);
//        minitoggle_mode_showDensityPreview(true);
      }
    }
    else
    {
//      println("Do nothing.");
    }
  }
}

void mouseReleased()
{
  if (mouseButton == LEFT)
  {
    if (MODE_INPUT_BOX_TOP_LEFT.equals(currentMode) && mouseOverMachine())
    {
      PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
      setBoxVector2(pos);
      if (isBoxSpecified())
      {
        if (getBoxVector1().x > getBoxVector2().x)
        {
          float temp = getBoxVector1().x;
          getBoxVector1().x = getBoxVector2().x;
          getBoxVector2().x = temp;
        }
        if (getBoxVector1().y > getBoxVector2().y)
        {
          float temp = getBoxVector1().y;
          getBoxVector1().y = getBoxVector2().y;
          getBoxVector2().y = temp;
        }
        if (getDisplayMachine().pixelsCanBeExtracted())
        {
          getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
          minitoggle_mode_showImage(false);
          minitoggle_mode_showDensityPreview(true);
          getAllControls().get(MODE_SHOW_IMAGE).setValue(0);
          getAllControls().get(MODE_SHOW_DENSITY_PREVIEW).setValue(1);
        }
      }
    }
  }
}

void middleButtonMachinePress()
{
  PVector machineDragOffset = PVector.sub(getMouseVector(), getDisplayMachine().getOutline().getPosition());
  this.machineDragOffset = machineDragOffset;
}

void leftButtonMachineClick()
{
  if (currentMode.equals(MODE_BEGIN))
    currentMode = MODE_INPUT_BOX_TOP_LEFT;
  else if (currentMode.equals(MODE_SET_POSITION))
    sendSetPosition();
  else if (currentMode.equals(MODE_DRAW_DIRECT))
    sendMoveToPosition(true);
  else if (currentMode.equals(MODE_DRAW_TO_POSITION))
    sendMoveToPosition(false);
  else if (currentMode.equals(MODE_CHOOSE_CHROMA_KEY_COLOUR))
    setChromaKey(getMouseVector());
  else if (currentMode.equals(MODE_SEND_START_TEXT))
    sendStartTextAtPoint();
  
}

void mouseWheel(int delta) 
{
  noLoop();
  // get the mouse position on the machine, before changing the machine scaling
  PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
  changeMachineScaling(delta);
  
  // now work out what the machine position needs to be to line the pos up with mousevector again
  PVector scaledPos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
//  println("original pos: " + pos);
//  println("scaled pos: " + scaledPos);
  
  PVector change = PVector.sub(scaledPos, pos);
//  println("change: " + change);

  // and adjust for the new scaling factor
  change.mult(machineScaling);
  
  // finally update the machine offset (position)
  getDisplayMachine().getOffset().add(change);
  loop();
} 

void setChromaKey(PVector p)
{
  color col = getDisplayMachine().getPixelAtScreenCoords(p); 
  chromaKeyColour = col;
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
  }
}

boolean isPreviewable(String command)
{
  if (command.startsWith(CMD_CHANGELENGTHDIRECT) 
    || command.startsWith(CMD_CHANGELENGTH)
    || command.startsWith(CMD_DRAWPIXEL))
  {
    return true;
  }
  else
  {
    return false;
  }
}

boolean toggleShowConsole() {
  if (console == null) {
    savedOut = System.out;
    console = cp5.addConsole(consoleArea);
    consoleArea.setVisible(true);
    console.play();
  }
  else {
    console.pause();
    consoleArea.setVisible(false);
    cp5.remove(console);
    console = null;
    System.setOut(savedOut);
  }
  
//  println("Ow");
  
  return console == null;
}

/**
  This will comb the command queue and attempt to draw a picture of what it contains.
  Coordinates here are in pixels.
*/
void previewQueue() {
  previewQueue(false);
}

void previewQueue(boolean forceRebuild)
{
  PVector startPoint = null;
  if (forceRebuild || (commandQueue.hashCode() != lastCommandQueueHash))
  {
    println("regenerating preview queue.");
    previewCommandList.clear();
    
    
    for (String command : commandQueue)
    {
      if (command.startsWith(CMD_CHANGELENGTHDIRECT) || command.startsWith(CMD_CHANGELENGTH) || command.startsWith(CMD_DRAWPIXEL))
      {
        String[] splitted = split(command, ",");

        PreviewVector pv = new PreviewVector();
        pv.command = splitted[0];

        String aLenStr = splitted[1];
        String bLenStr = splitted[2];
        
        PVector endPoint = new PVector(Integer.parseInt(aLenStr)+previewCordOffset, Integer.parseInt(bLenStr)+previewCordOffset);
        endPoint = getDisplayMachine().asCartesianCoords(endPoint);
        endPoint = getDisplayMachine().inMM(endPoint);
        
        pv.x = endPoint.x;
        pv.y = endPoint.y;
        pv.z = -1.0;
        
        if (command.startsWith(CMD_DRAWPIXEL))
        {
          String densStr = splitted[4];
          pv.z = Integer.parseInt(densStr);
        }
        
        previewCommandList.add(pv);
      }
    }
    lastCommandQueueHash = commandQueue.hashCode();
  }
  
  for (PreviewVector pv : previewCommandList)
  {
    PVector p = (PVector) pv;
    p = getDisplayMachine().scaleToScreen(p);

    if (startPoint == null)
    {
      noStroke();
      fill(255,0,255,150);
      startPoint = getDisplayMachine().scaleToScreen(currentMachinePos);
      ellipse(p.x, p.y, 20, 20);
      noFill();
    }
    
    if (pv.command.equals(CMD_CHANGELENGTHDIRECT))
      stroke(0);
    else 
      stroke(200,0,0);
    line(startPoint.x, startPoint.y, p.x, p.y);
    startPoint = p;

    if (pv.z >= 0.0)
    {
      noStroke();
      fill(255,pv.z,pv.z);
      ellipse(p.x, p.y, 5,5);
      noFill();
    }
//    ellipse(p.x, p.y, 5,5); // Circle at each node

  }

  if (startPoint != null)
  {
    noStroke();
    fill(200,0,0,128);
    ellipse(startPoint.x, startPoint.y, 15,15);
    noFill();
  }
  
}

boolean isHiddenPixel(PVector p)
{
  if ((p.z == MASKED_PIXEL_BRIGHTNESS) || (p.z > pixelExtractBrightThreshold) || (p.z < pixelExtractDarkThreshold))
    return true;
  else
    return false;
}

void sizeImageToFitBox() {
  PVector boxSize = getDisplayMachine().inSteps(getBoxSize());
  PVector boxPos = getDisplayMachine().inSteps(getBoxVector1());
  println("image: " + boxSize);
  
  Rectangle r = new Rectangle(boxPos, boxSize);
  getDisplayMachine().setImageFrame(r);
}

void exportQueueToFile() {
	if (!commandQueue.isEmpty() || !realtimeCommandQueue.isEmpty()) {
		selectOutput("Enter a filename to save to:", "exportQueueToFile");  // Opens file chooser
	}
}

void exportQueueToFile(File selection) {
	if (selection != null) {
		filePath = selection.getAbsolutePath();
		println("User selected " + filePath);
		// If a file was selected, print path to folder
		println("Output file: " + filePath);
		List<String> allCommands = new ArrayList<String>(realtimeCommandQueue);
		allCommands.addAll(commandQueue);
  
		String[] list = (String[]) allCommands.toArray(new String[0]);
		saveStrings(filePath, list);
		println("Completed queue export, " + list.length + " commands exported.");
	}  
}

void fileSelected(File selection) {
	if (selection == null) {
		println("Window was closed or the user hit cancel.");
		filePath = null;
	} else {
		filePath = selection.getAbsolutePath();
		println("User selected " + filePath);
	}
}

void importQueueFromFile() {
	commandQueue.clear();
	selectInput("Select file to import queue from", "fileSelected");
	if (filePath == null) {
		// nothing selected
		println("No input file was selected.");
	} else {
		println("Input file: " + filePath);
		String commands[] = loadStrings(filePath);
		commandQueue.addAll(Arrays.asList(commands));
		println("Completed queue import, " + commandQueue.size() + " commands found.");
	}
}




void queueClicked()
{
  int relativeCoord = (mouseY-topEdgeOfQueue);
  int rowClicked = relativeCoord / queueRowHeight;
  int totalCommands = commandQueue.size()+realtimeCommandQueue.size();
  
  if (rowClicked < 1) // its the header - start or stop queue
  {
    if (commandQueueRunning)
      commandQueueRunning = false;
    else
      commandQueueRunning = true;
  }
  else if (rowClicked > 2 && rowClicked < totalCommands+3) // it's a command from the queue
  {
    int cmdNumber = rowClicked-2;
    if (commandQueueRunning)
    {
      // if its running, then clicking on a command will mark it as a pause point
    }
    else
    {
      // if it's not running, then clicking on a command row will remove it
      if (!realtimeCommandQueue.isEmpty())
      {
        if (cmdNumber <= realtimeCommandQueue.size())
          realtimeCommandQueue.remove(cmdNumber-1);
        else  
        {
          cmdNumber-=(realtimeCommandQueue.size()+1);
          commandQueue.remove(cmdNumber);
        }        
      }
      else
      {
        commandQueue.remove(cmdNumber-1);
      }
    }
  }
}


boolean isRowsSpecified()
{
  if (rowsVector1 != null && rowsVector2 != null)
    return true;
  else
    return false;
}

boolean isBoxSpecified()
{
  if (boxVector1 != null && boxVector2 != null)
  {
    return true;
  }
  else
    return false;
}

void setBoxVector1(PVector vec)
{
  boxVector1 = vec;
}
void setBoxVector2(PVector vec)
{
  boxVector2 = vec;
}
PVector getBoxVector1()
{
  return this.boxVector1;
}
PVector getBoxVector2()
{
  return this.boxVector2;
}
PVector getBoxVectorSize()
{
  return PVector.sub(getBoxVector2(),getBoxVector1());
}

float getSampleArea()
{
  return this.sampleArea;
}


void resetQueue()
{
  currentMode = MODE_BEGIN;
  commandQueue.clear();
  realtimeCommandQueue.clear();
}

void showText(int xPosOrigin, int yPosOrigin)
{
  noStroke();
  fill(0, 0, 0, 80);
  rect(xPosOrigin, yPosOrigin, 220, 550);
  
  
  textSize(12);
  fill(255);
  int tRow = 15;
  int textPositionX = xPosOrigin+4;
  int textPositionY = yPosOrigin+4;
  
  int tRowNo = 1;
  PVector screenCoordsCart = getMouseVector();
 
  text(programTitle, textPositionX, textPositionY+(tRow*tRowNo++));
  tRowNo++;
  text("Cursor position: " + mouseX + ", " + mouseY, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("MM Per Step: " + getDisplayMachine().getMMPerStep(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Steps Per MM: " + getDisplayMachine().getStepsPerMM() ,textPositionX, textPositionY+(tRow*tRowNo++));

  if (getDisplayMachine().getOutline().surrounds(screenCoordsCart))
  {
    PVector posOnMachineCartesianInMM = getDisplayMachine().scaleToDisplayMachine(screenCoordsCart);
    text("Machine x/y mm: " + posOnMachineCartesianInMM.x+","+posOnMachineCartesianInMM.y, textPositionX, textPositionY+(tRow*tRowNo++));
    
    PVector posOnMachineNativeInMM = getDisplayMachine().convertToNative(posOnMachineCartesianInMM);
    text("Machine a/b mm: " + posOnMachineNativeInMM.x+","+posOnMachineNativeInMM.y, textPositionX, textPositionY+(tRow*tRowNo++));
  
    PVector posOnMachineNativeInSteps = getDisplayMachine().inSteps(posOnMachineNativeInMM);
    text("Machine a/b steps: " + posOnMachineNativeInSteps.x+","+posOnMachineNativeInSteps.y, textPositionX, textPositionY+(tRow*tRowNo++));
  }
  else
  {
    text("Machine x/y mm: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
    text("Machine a/b mm: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
    text("Machine a/b steps: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
  }
  


  drawStatusText(textPositionX, textPositionY+(tRow*tRowNo++));  
    
  text(commandStatus, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Mode: " + currentMode, textPositionX, textPositionY+(tRow*tRowNo++));

  // middle side
  text("Grid size: " + getGridSize(), textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Box width: " + getBoxWidth(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Box height: " + getBoxHeight(), textPositionX, textPositionY+(tRow*tRowNo++));

  text("Box offset left: " + getBoxPosition().x, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Box offset top: " + getBoxPosition().y, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Available memory: " + machineAvailMem + " (min: " + machineMinAvailMem +", used: "+ machineUsedMem+")", textPositionX, textPositionY+(tRow*tRowNo++));

  text("Time cmd: " + getCurrentPixelTime() + ", total: " + getTimeSoFar(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Average time per cmd: " + getAveragePixelTime(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Time to go: " + getTimeRemainingMins() + " mins (" + getTimeRemainingSecs() + " secs)", textPositionX, textPositionY+(tRow*tRowNo++));

  text("Commands sent: " + getPixelsCompleted() + ", remaining: " + getPixelsRemaining(), textPositionX, textPositionY+(tRow*tRowNo++));

  text("Estimated complete: " + getEstimatedCompletionTime(), textPositionX, textPositionY+(tRow*tRowNo++));

  text("Pixel sample area: " + sampleArea, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Pixel drawing scale: " + getPixelScalingOverGridSize(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Max line segment length: " + getMaxSegmentLength(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Ignore vector lines shorter than: " + minimumVectorLineLength, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Zoom: " + machineScaling, textPositionX, textPositionY+(tRow*tRowNo++));

  tRowNo++;
  text("Machine settings:", textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent pen width: " + currentPenWidth, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent speed: " + currentMachineMaxSpeed, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent accel: " + currentMachineAccel, textPositionX, textPositionY+(tRow*tRowNo++));

  tRowNo++;
  text("Chroma key colour: ", textPositionX, textPositionY+(tRow*tRowNo));
  fill(chromaKeyColour);
  stroke(255);
  strokeWeight(1);
  rect(textPositionX+120, textPositionY+(tRow*tRowNo)-15, 25, 15);
  noFill();
  noStroke();
  tRowNo++;

}

void drawStatusText(int x, int y)
{
  String drawbotStatus = null;
  
  if (useSerialPortConnection)
  {
    if (isDrawbotConnected())
    {
      if (drawbotReady)
      {
        fill(0, 200, 0);
        if (currentHardware >= HARDWARE_VER_MEGA_POLARSHIELD)
          drawbotStatus = "Polargraph READY! (PolargraphSD)";
        else if (currentHardware >= HARDWARE_VER_MEGA)
          drawbotStatus = "Polargraph READY! (Mega)";
        else if (currentHardware >= HARDWARE_VER_POLARPRO)
          drawbotStatus = "Polargraph READY! (PRO)";
        else
          drawbotStatus = "Polargraph READY! (Uno)";
      }
      else
      {
        fill(200, 200, 0);
        String busyDoing = lastCommand;
        if ("".equals(busyDoing))
          busyDoing = commandHistory.get(commandHistory.size()-1);
        drawbotStatus = "BUSY: " + busyDoing;
      }  
    }
    else
    {
      fill(255, 0, 0);
      drawbotStatus = "Polargraph is not connected.";
    }  
  }
  else
  {
    fill(255, 0, 0);
    drawbotStatus = "No serial connection.";
  }
  
  text(drawbotStatus, x, y);
  fill(255);
}

void setCommandQueueFont()
{
  textSize(12);
  fill(255);
}  
void showCommandQueue(int xPos, int yPos)
{
  setCommandQueueFont();
  int tRow = 15;
  int textPositionX = xPos;
  int textPositionY = yPos;
  int tRowNo = 1;

  int commandQueuePos = textPositionY+(tRow*tRowNo++);

  topEdgeOfQueue = commandQueuePos-queueRowHeight;
  leftEdgeOfQueue = textPositionX;
  rightEdgeOfQueue = textPositionX+300;
  bottomEdgeOfQueue = height;
  
  drawCommandQueueStatus(textPositionX, commandQueuePos, 14);
  commandQueuePos+=queueRowHeight;
  text("Last command: " + ((commandHistory.isEmpty()) ? "-" : commandHistory.get(commandHistory.size()-1)), textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  text("Current command: " + lastCommand, textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  
  fill(128,255,255);
  int queueNumber = commandQueue.size()+realtimeCommandQueue.size();
  for (String s : realtimeCommandQueue)
  {
    text((queueNumber--)+". "+ s, textPositionX, commandQueuePos);
    commandQueuePos+=queueRowHeight;
  }
  
  fill(255);
  try
  {
    // Write out the commands into the window, stop when you fall off the bottom of the window
    // Or run out of commands
    int commandNo = 0;
    while (commandQueuePos <= height && commandNo < commandQueue.size())
    {
      String s = commandQueue.get(commandNo);
      text((queueNumber--)+". "+ s, textPositionX, commandQueuePos);
      commandQueuePos+=queueRowHeight;
      commandNo++;
    }
  }
  catch (ConcurrentModificationException cme)
  {
    // not doing anything with this exception - I don't mind if it's wrong on the screen for a second or two.
    println("Caught the pesky ConcurrentModificationException: " + cme.getMessage());
  }
  showmachineMessageLog(rightEdgeOfQueue, 20);
  
}

void drawCommandQueueStatus(int x, int y, int tSize)
{
  String queueStatus = null;
  textSize(tSize);
  if (commandQueueRunning)
  {
    queueStatus = "QUEUE RUNNING - click to pause";
    fill(0, 200, 0);
  }
  else
  {
    queueStatus = "QUEUE PAUSED - click to start";
    fill(255, 0, 0);
  }

  text("CommandQueue: " + queueStatus, x, y);
  setCommandQueueFont();
}

void showmachineMessageLog(int xPos, int yPos)
{
  setCommandQueueFont();
  int tRow = 15;
  int textPositionX = xPos;
  int textPositionY = yPos;
  int tRowNo = 1;

  int pos = textPositionY+(tRow*tRowNo++);
  pos+=queueRowHeight;
  
  fill(255);
  // Write out the commands into the window, stop when you fall off the bottom of the window
  // Or run out of commands
  int entryNo = machineMessageLog.size()-1;
  while (pos <= height && entryNo >= 0)
  {
    String s = machineMessageLog.get(entryNo);
    String type = s.substring(0,1);
    if ("E".equals(type)) fill(255,128,128);
    else if ("D".equals(type)) fill(50,50,50);
    else if ("I".equals(type)) fill(255);
    text(s, textPositionX, pos);
    pos+=queueRowHeight;
    entryNo--;
  }
}

long getCurrentPixelTime()
{
  if (pixelTimerRunning)
    return new Date().getTime() - timeLastPixelStarted.getTime();
  else
    return 0L;
}
long getAveragePixelTime()
{
  if (pixelTimerRunning)
  {
    long msElapsed = timeLastPixelStarted.getTime() - timerStart.getTime();
    int pixelsCompleted = getPixelsCompleted();
    if (pixelsCompleted > 0)
      return msElapsed / pixelsCompleted;
    else
      return 0L;
  }
  else
    return 0L;
}
long getTimeSoFar()
{
  if (pixelTimerRunning)
    return new Date().getTime() - timerStart.getTime();
  else
    return 0L;
}
long getTimeRemaining()
{
  if (pixelTimerRunning)
    return getTotalEstimatedTime() - getTimeSoFar();
  else
    return 0L;
}
long getTotalEstimatedTime()
{
  if (pixelTimerRunning)
    return (getAveragePixelTime() * numberOfPixelsTotal);
  else
    return 0L;
}
long getTimeRemainingSecs()
{
  if (pixelTimerRunning)
    return getTimeRemaining() / 1000L;
  else
    return 0L;
}
long getTimeRemainingMins()
{
  if (pixelTimerRunning)
    return getTimeRemainingSecs()/60L;
  else
    return 0L;
}
String getEstimatedCompletionTime()
{
  if (pixelTimerRunning)
  {
    long totalTime = getTotalEstimatedTime()+timerStart.getTime();
    return sdf.format(totalTime);
  }
  else
    return "TIMER NOT RUNNING";
}

int getPixelsCompleted()
{
  if (pixelTimerRunning)
    return numberOfPixelsCompleted-1;
  else
    return 0;
}
int getPixelsRemaining()
{
  if (pixelTimerRunning)
    return numberOfPixelsTotal - getPixelsCompleted();
  else
    return 0;
}


float getBoxWidth()
{
  if (boxVector1 != null && boxVector2 != null)
    return (boxVector2.x-boxVector1.x);
  else
    return 0;
}

float getBoxHeight()
{
  if (boxVector1 != null && boxVector2 != null)
    return (boxVector2.y-boxVector1.y);
  else
    return 0;
}
PVector getBoxSize()
{
  PVector p = PVector.sub(getBoxVector2(), getBoxVector1());
  return p;
}

PVector getBoxPosition()
{
  if (boxVector1 != null)
    return boxVector1;
  else
    return new PVector();
}

void clearBoxVectors()
{
  setBoxVector1(null);
  setBoxVector2(null);
  getDisplayMachine().setExtractedPixels(null);
}

public PVector getHomePoint()
{
  return this.homePointCartesian;
}



//public Machine getMachine()
//{
//  return this.machine;
//}
public DisplayMachine getDisplayMachine()
{
  if (displayMachine == null)
    displayMachine = new DisplayMachine(new Machine(5000, 5000, 200.0, 95.0), machinePosition, machineScaling);
    
  displayMachine.setOffset(machinePosition);
  displayMachine.setScale(machineScaling);
  return displayMachine;
}

Integer getHardwareVersion()
{
  return this.currentHardware;
}

void changeHardwareVersionTo(int newVer)
{
  this.currentHardware = newVer;

  this.panelNames = null;
  this.tabNames = null;
  this.controlNames = null;
  this.controlsForPanels = null;

  this.panelsForTabs = null;
  this.panels = null;

  switch (newVer)
  {
    case HARDWARE_VER_MEGA :
      currentSram = HARDWARE_ATMEGA1280_SRAM;
    default   :  
      currentSram = HARDWARE_ATMEGA328_SRAM;
  }
//  windowResized();
}

void setHardwareVersionFromIncoming(String readyString)
{
  int newHardwareVersion = HARDWARE_VER_UNO;
  if ("READY".equals(readyString))
  {
    newHardwareVersion = HARDWARE_VER_UNO;
  }
  else
  {
    String ver = readyString.substring(6);
    int verInt = HARDWARE_VER_UNO;
    try
    {
      verInt = Integer.parseInt(ver);
    }
    catch (NumberFormatException nfe)
    {
      println("Bad format for hardware version - defaulting to ATMEGA328 (Uno)");
      verInt = HARDWARE_VER_UNO;
    }
    
    if (HARDWARE_VER_MEGA == verInt 
    || HARDWARE_VER_MEGA_POLARSHIELD == verInt)
      newHardwareVersion = verInt;
    else
      newHardwareVersion = HARDWARE_VER_UNO;
  }
  
  // now see if it's different to last time.
  if (newHardwareVersion != currentHardware)
  {
    // and make the controller reflect the new hardware.
    changeHardwareVersionTo(newHardwareVersion);
  }
}

void serialEvent(Serial myPort) 
{ 
  // read the serial buffer:
  String incoming = myPort.readStringUntil('\n');
  myPort.clear();
  // if you got any bytes other than the linefeed:
  incoming = trim(incoming);
  println("incoming: " + incoming);
  
  if (incoming.startsWith("READY"))
  {
    drawbotReady = true;
    setHardwareVersionFromIncoming(incoming);
  }
  else if (incoming.startsWith("MSG"))
    readMachineMessage(incoming);
  else if (incoming.startsWith("SYNC"))
    readMachinePosition(incoming);
  else if (incoming.startsWith("CARTESIAN"))
    readCartesianMachinePosition(incoming);
  else if (incoming.startsWith("PGNAME"))
    readMachineName(incoming);
  else if (incoming.startsWith("PGSIZE"))
    readMachineSize(incoming);
  else if (incoming.startsWith("PGMMPERREV"))
    readMmPerRev(incoming);
  else if (incoming.startsWith("PGSTEPSPERREV"))
    readStepsPerRev(incoming);
  else if (incoming.startsWith("PGSTEPMULTIPLIER"))
    readStepMultiplier(incoming);
  else if (incoming.startsWith("PGLIFT"))
    readPenLiftRange(incoming);
  else if (incoming.startsWith("PGSPEED"))
    readMachineSpeed(incoming);
    
  else if ("RESEND".equals(incoming))
    resendLastCommand();
  else if ("DRAWING".equals(incoming))
    drawbotReady = false;
  else if (incoming.startsWith("MEMORY"))
    extractMemoryUsage(incoming);
    
  else if (incoming.startsWith("BUTTON"))
    handleMachineButton(incoming);

  if (drawbotReady)
    drawbotConnected = true;
}

void handleMachineButton(String msg)
{
  machineMessageLog.add(msg);
}

void extractMemoryUsage(String mem)
{
  String[] splitted = split(mem, ",");
  if (splitted.length == 3)
  {
    machineAvailMem = Integer.parseInt(splitted[1]);
    machineUsedMem = currentSram - machineAvailMem;
    if (machineAvailMem < machineMinAvailMem)
      machineMinAvailMem = machineAvailMem;
  }
}

void readMachineMessage(String msg)
{
  msg = msg.substring(4, msg.length());
  String type = msg.substring(0,1);
  msg = msg.substring(2, msg.length());
  String timestamp = new SimpleDateFormat("HH:mm:ss").format(new Date());
  
  msg = type + timestamp + " " + msg;
  machineMessageLog.add(msg);
  if (machineMessageLog.size() > 200) 
  {
    machineMessageLog.remove(0);
  }
}

void readMachinePosition(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 4)
  {
    String currentAPos = splitted[1];
    String currentBPos = splitted[2];
    Float a = Float.valueOf(currentAPos).floatValue();
    Float b = Float.valueOf(currentBPos).floatValue();
    currentMachinePos.x = a;
    currentMachinePos.y = b;  
    currentMachinePos = getDisplayMachine().inMM(getDisplayMachine().asCartesianCoords(currentMachinePos));
  }
}
void readCartesianMachinePosition(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 4)
  {
    String currentAPos = splitted[1];
    String currentBPos = splitted[2];
    Float a = Float.valueOf(currentAPos).floatValue();
    Float b = Float.valueOf(currentBPos).floatValue();
    currentCartesianMachinePos.x = a;
    currentCartesianMachinePos.y = b;  
  }
}

void readMmPerRev(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 3)
  {
    String mmStr = splitted[1];
    
    float mmPerRev = Float.parseFloat(mmStr);
    getDisplayMachine().setMMPerRev(mmPerRev);
    updateNumberboxValues();
  }
}

void readStepsPerRev(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 3)
  {
    String stepsStr = splitted[1];
    
    Float stepsPerRev = Float.parseFloat(stepsStr);
    getDisplayMachine().setStepsPerRev(stepsPerRev);
    updateNumberboxValues();
  }
}

void readStepMultiplier(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 3)
  {
    String stepsStr = splitted[1];
    
    machineStepMultiplier = Integer.parseInt(stepsStr);
    updateNumberboxValues();
  }
}


void readMachineSize(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 4)
  {
    String mWidth = splitted[1];
    String mHeight = splitted[2];
    
    Integer intWidth = Integer.parseInt(mWidth);
    Integer intHeight = Integer.parseInt(mHeight);
    
    float fWidth = getDisplayMachine().inSteps(intWidth);
    float fHeight = getDisplayMachine().inSteps(intHeight);
    
    getDisplayMachine().setSize(int(fWidth+0.5), int(fHeight+0.5));
    updateNumberboxValues();
  }
}

void readMachineName(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 3)
  {
    String name = splitted[1];
    
  }
}

void readMachineSpeed(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 4)
  {
    String speed = splitted[1];
    String accel = splitted[2];
    
    currentMachineMaxSpeed = Float.parseFloat(speed);
    currentMachineAccel = Float.parseFloat(accel);
    
    updateNumberboxValues();
  }
}

void readPenLiftRange(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 4)
  {
    String downPos = splitted[1];
    String upPos = splitted[2];
    
    penLiftDownPosition = Integer.parseInt(downPos);
    penLiftUpPosition = Integer.parseInt(upPos);

    updateNumberboxValues();
  }
}

void resendLastCommand()
{
  println("Re-sending command: " + lastCommand);
  myPort.write(lastCommand);
  drawbotReady = false;
}

void dispatchCommandQueue()
{
  if (isDrawbotReady() 
    && (!commandQueue.isEmpty() || !realtimeCommandQueue.isEmpty())
    && commandQueueRunning)
  {
    if (pixelTimerRunning)
    {
      timeLastPixelStarted = new Date();
      numberOfPixelsCompleted++;
    }

    if (!realtimeCommandQueue.isEmpty())
    {
      String command = realtimeCommandQueue.get(0);
      lastCommand = command;
      realtimeCommandQueue.remove(0);
      println("Dispatching PRIORITY command: " + command);
    }
    else
    {
      String command = commandQueue.get(0);
      lastCommand = command;
      commandQueue.remove(0);
      println("Dispatching command: " + command);
    }
//    Checksum crc = new CRC32();
//    crc.update(lastCommand.getBytes(), 0, lastCommand.length());
//    lastCommand = lastCommand+":"+crc.getValue();
    println("Last command:" + lastCommand);
    myPort.write(lastCommand);
    myPort.write(10); // OH *$%! of COURSE you should terminate it.
    drawbotReady = false;
  }
  else if (commandQueue.isEmpty())
  {
    stopPixelTimer();
  }  
}

void addToCommandQueue(String command)
{
  synchronized (commandQueue)
  {
    commandQueue.add(command);
  }
}
synchronized void addToRealtimeCommandQueue(String command)
{
  synchronized (realtimeCommandQueue)
  {
    realtimeCommandQueue.add(command);
  }
}

void startPixelTimer()
{
  timerStart = new Date();
  timeLastPixelStarted = timerStart;
  pixelTimerRunning = true;
}
void stopPixelTimer()
{
  pixelTimerRunning = false;
}

boolean isDrawbotReady()
{
  return drawbotReady;
}
boolean isDrawbotConnected()
{
  return drawbotConnected;
}

Properties getProperties()
{
  if (props == null)
  {
    FileInputStream propertiesFileStream = null;
    try
    {
      props = new Properties();
      String fileToLoad = sketchPath(propertiesFilename);
      
      File propertiesFile = new File(fileToLoad);
      if (!propertiesFile.exists())
      {
        println("saving.");
        savePropertiesFile();
        println("saved.");
      }
      
      propertiesFileStream = new FileInputStream(propertiesFile);
      props.load(propertiesFileStream);
      println("Successfully loaded properties file " + fileToLoad);
    }
    catch (IOException e)
    {
      println("Couldn't read the properties file - will attempt to create one.");
      println(e.getMessage());
    }
    finally
    {
      try 
      { 
        propertiesFileStream.close();
      }
      catch (Exception e) 
      {
        println("Exception: "+e.getMessage());
      };
    }
  }
  return props;
}

void loadFromPropertiesFile()
{
  getDisplayMachine().loadDefinitionFromProperties(getProperties());
  this.pageColour = getColourProperty("controller.page.colour", color(220));
  this.frameColour = getColourProperty("controller.frame.colour", color(200,0,0));
  this.machineColour = getColourProperty("controller.machine.colour", color(150));
  this.guideColour = getColourProperty("controller.guide.colour", color(255));
  this.backgroundColour = getColourProperty("controller.background.colour", color(100));
  this.densityPreviewColour = getColourProperty("controller.densitypreview.colour", color(0));
  this.chromaKeyColour = getColourProperty("controller.pixel.mask.color", color(0,255,0));

  // pen size
  this.currentPenWidth = getFloatProperty("machine.pen.size", 0.8);

  // motor settings
  this.currentMachineMaxSpeed = getFloatProperty("machine.motors.maxSpeed", 2000.0);
  this.currentMachineAccel = getFloatProperty("machine.motors.accel", 2000.0);
  this.machineStepMultiplier = getIntProperty("machine.step.multiplier", 8);
  
  // serial port
  this.serialPortNumber = getIntProperty("controller.machine.serialport", 0);
  this.baudRate = getIntProperty("controller.machine.baudrate", 57600);

  // row size
  this.gridSize = getFloatProperty("controller.grid.size", 100.0);
  this.sampleArea = getIntProperty("controller.pixel.samplearea", 2);
  this.pixelScalingOverGridSize = getFloatProperty("controller.pixel.scaling", 1.0);
  
  // pixel renderer
  this.densityPreviewStyle = getIntProperty("controller.density.preview.style", 1);
  
  // initial screen size
  this.windowWidth = getIntProperty("controller.window.width", 650);
  this.windowHeight = getIntProperty("controller.window.height", 400);
  
  println("windowHeight:" + this.windowHeight);

  this.testPenWidthStartSize = getFloatProperty("controller.testPenWidth.startSize", 0.5);
  this.testPenWidthEndSize = getFloatProperty("controller.testPenWidth.endSize", 2.0);
  this.testPenWidthIncrementSize = getFloatProperty("controller.testPenWidth.incrementSize", 0.5);
  
  this.maxSegmentLength = getIntProperty("controller.maxSegmentLength", 2);
  
  float homePointX = getFloatProperty("controller.homepoint.x", 0.0);
  float homePointY = getFloatProperty("controller.homepoint.y", 0.0);
  
  if (homePointX == 0.0)
  {
    float defaultX = getDisplayMachine().getWidth() / 2.0;    // in steps
    float defaultY = getDisplayMachine().getPage().getTop();  // in steps
//    homePointX = getDisplayMachine().inMM(defaultX);
//    homePointY = getDisplayMachine().inMM(defaultY);
    println("Loading default homepoint.");
  }
  this.homePointCartesian = new PVector(getDisplayMachine().inSteps(homePointX), getDisplayMachine().inSteps(homePointY));
//  println("home point loaded: " + homePointCartesian + ", " + getHomePoint());

  // Geomerative stuff  
  polygonizer = getIntProperty("controller.geomerative.polygonizer", RG.ADAPTATIVE);
  polygonizerLength = getFloatProperty("controller.geomerative.polygonizerLength", 1.0);
  setupPolygonizer();
  
  setVectorFilename(getStringProperty("controller.vector.filename", null));
  if (getVectorFilename() != null)
  {
    RShape shape = null;
    // test if file exists
    File f =  new File(getVectorFilename());
    if (f.isFile()) {
      shape = RG.loadShape(getVectorFilename());
    }
    else {
      println("Tried to load vector file (" + getVectorFilename() + ") but I couldn't find it.");
    }
    
    if (shape != null) {
      setVectorShape(shape);
    }
    else {
      println("File not found (" + getVectorFilename() + ")");
    }
  }
  vectorScaling = getFloatProperty("controller.vector.scaling", 100.0);
  getVectorPosition().x = getFloatProperty("controller.vector.position.x", 0.0);
  getVectorPosition().y = getFloatProperty("controller.vector.position.y", 0.0);
  this.minimumVectorLineLength = getIntProperty("controller.vector.minLineLength", 0);
  
  
  println("Finished loading configuration from properties file.");
}

void savePropertiesFile()
{
  Properties props = new Properties();
  
  props = getDisplayMachine().loadDefinitionIntoProperties(props);

  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  
  df.applyPattern("###.##");
  
  props.setProperty("controller.page.colour", hex(this.pageColour, 6));
  props.setProperty("controller.frame.colour", hex(this.frameColour,6));
  props.setProperty("controller.machine.colour", hex(this.machineColour,6));
  props.setProperty("controller.guide.colour", hex(this.guideColour,6));
  props.setProperty("controller.background.colour", hex(this.backgroundColour,6));
  props.setProperty("controller.densitypreview.colour", hex(this.densityPreviewColour,6));

  
  // pen size
  props.setProperty("machine.pen.size", df.format(currentPenWidth));
  // serial port
  props.setProperty("controller.machine.serialport", getSerialPortNumber().toString());
  props.setProperty("controller.machine.baudrate", getBaudRate().toString());

  // row size
  props.setProperty("controller.grid.size", new Float(gridSize).toString());
  props.setProperty("controller.pixel.samplearea", df.format(sampleArea));
  props.setProperty("controller.pixel.scaling", df.format(pixelScalingOverGridSize));

  // density preview style
  props.setProperty("controller.density.preview.style", new Integer(getDensityPreviewStyle()).toString());

  // initial screen size
  props.setProperty("controller.window.width", new Integer((windowWidth < 100) ? 100 : windowWidth-16).toString());
  props.setProperty("controller.window.height", new Integer((windowWidth < 100) ? 100 : windowHeight-38).toString());

  props.setProperty("controller.testPenWidth.startSize", df.format(testPenWidthStartSize));
  props.setProperty("controller.testPenWidth.endSize", df.format(testPenWidthEndSize));
  props.setProperty("controller.testPenWidth.incrementSize", df.format(testPenWidthIncrementSize));
  
  props.setProperty("controller.maxSegmentLength", new Integer(getMaxSegmentLength()).toString());
  
  props.setProperty("machine.motors.maxSpeed", df.format(currentMachineMaxSpeed));
  props.setProperty("machine.motors.accel", df.format(currentMachineAccel));
  props.setProperty("machine.step.multiplier", new Integer(machineStepMultiplier).toString());
  
  props.setProperty("controller.pixel.mask.color", hex(this.chromaKeyColour, 6));
  
  PVector hp = null;  
  if (getHomePoint() != null)
  {
    hp = getHomePoint();
  }
  else
    hp = new PVector(2000.0, 1000.0);
    
  hp = getDisplayMachine().inMM(hp);
  
  props.setProperty("controller.homepoint.x", df.format(hp.x));
  props.setProperty("controller.homepoint.y", df.format(hp.y));
  
  if (getVectorFilename() != null)
    props.setProperty("controller.vector.filename", getVectorFilename());
    
  props.setProperty("controller.vector.scaling", df.format(vectorScaling));
  props.setProperty("controller.vector.position.x", df.format(getVectorPosition().x));
  props.setProperty("controller.vector.position.y", df.format(getVectorPosition().y));
  props.setProperty("controller.vector.minLineLength", new Integer(this.minimumVectorLineLength).toString());
  
  props.setProperty("controller.geomerative.polygonizer", new Integer(polygonizer).toString());
  props.setProperty("controller.geomerative.polygonizerLength", df.format(polygonizerLength));

 
  FileOutputStream propertiesOutput = null;

  try
  {
    //save the properties to a file
    File propertiesFile = new File(sketchPath(propertiesFilename));
    if (propertiesFile.exists())
    {
      propertiesOutput = new FileOutputStream(propertiesFile);
      Properties oldProps = new Properties();
      FileInputStream propertiesFileStream = new FileInputStream(propertiesFile);
      oldProps.load(propertiesFileStream);
      oldProps.putAll(props);
      oldProps.store(propertiesOutput,"   ***  Polargraph properties file   ***  ");
      println("Saved settings.");
    }
    else
    { // create it
      propertiesFile.createNewFile();
      propertiesOutput = new FileOutputStream(propertiesFile);
      props.store(propertiesOutput,"   ***  Polargraph properties file   ***  ");
      println("Created file.");
    }
  }
  catch (Exception e)
  {
    println("Exception occurred while creating new properties file: " + e.getMessage());
  }
  finally
  {
    if (propertiesOutput != null)
    {
      try
      {
        propertiesOutput.close();
      }
      catch (Exception e2) {println("what now!"+e2.getMessage());}
    }
  }
}

boolean getBooleanProperty(String id, boolean defState) 
{
  return boolean(getProperties().getProperty(id,""+defState));
}
 
int getIntProperty(String id, int defVal) 
{
  return int(getProperties().getProperty(id,""+defVal)); 
}
 
float getFloatProperty(String id, float defVal) 
{
  return float(getProperties().getProperty(id,""+defVal)); 
}
String getStringProperty(String id, String defVal)
{
  return getProperties().getProperty(id, defVal);
}
color getColourProperty(String id, color defVal)
{
  color col = color(180);
  String colStr = getProperties().getProperty(id, "");
  if ("".equals(colStr))
  {
    col = defVal;
  }
  
  if (colStr.length() == 1)
  {
    // single value grey
    colStr = colStr+colStr;
    col = color(unhex(colStr));
  }
  else if (colStr.length() == 3)
  {
    // 3 digit rgb
    String d1 = colStr.substring(0,1);
    String d2 = colStr.substring(1,2);
    String d3 = colStr.substring(2,3);
    d1 = d1+d1;
    d2 = d2+d2;
    d3 = d3+d3;
    
    col = color(unhex(d1), unhex(d2), unhex(d3));
  }
  else if  (colStr.length() == 6)
  {
    // 6 digit rgb
    String d1 = colStr.substring(0,2);
    String d2 = colStr.substring(2,4);
    String d3 = colStr.substring(4,6);
    
    col = color(unhex(d1), unhex(d2), unhex(d3));
  }
  
  return col;
}

Integer getSerialPortNumber()
{
  return this.serialPortNumber;
}
String getStoreFilename()
{
  return this.storeFilename;
}
void setStoreFilename(String filename)
{
  this.storeFilename = filename;
}

boolean getOverwriteExistingStoreFile()
{
  return this.overwriteExistingStoreFile;
}
void setOverwriteExistingStoreFile(boolean over)
{
  this.overwriteExistingStoreFile = over;
}
  
void initProperties()
{
  getProperties();
}

PVector getVectorPosition()
{
  return vectorPosition;
}

float getPixelScalingOverGridSize()
{
  return pixelScalingOverGridSize;
}

void setPixelScalingOverGridSize(float scaling)
{
  pixelScalingOverGridSize = scaling;
}

int getDensityPreviewStyle()
{
  return densityPreviewStyle;
}

Integer getBaudRate()
{
  return baudRate;
}

void setupPolygonizer() {
  RG.setPolygonizer(polygonizer); // http://www.polargraph.co.uk/forum/polargraphs-group2/troubleshooting-forum5/svg-differences-between-polargraphcontroller-2-1-1-2-3-0-thread523.0
  switch(polygonizer) {
   case 1: RG.setPolygonizerLength(polygonizerLength); break;
  }
  println("Polygonizer: " + polygonizer);
  println("PolygonizerLength: " + polygonizerLength);
  
}
void initLogging()
{
  try
  {
//    logger = Logger.getLogger("uk.co.polargraph.controller");
//    FileHandler fileHandler = new FileHandler("mylog.txt");
//    fileHandler.setFormatter(new SimpleFormatter());
//    logger.addHandler(fileHandler);
//    logger.setLevel(Level.INFO);
//    logger.info("Hello");
//    if (isUseWindowedConsole())
//    {
//      console = new Console();
//    }
//    else
//    {
//      console.close();
//      console = null;
//    }
  }
  catch(Exception e)
  {
    println("Exception setting up logger: " + e.getMessage());
  }
}


PImage makeColourImage(int w, int h, int colour)
{
  PImage img = createImage(w,h,RGB);
  for(int i=0; i < img.pixels.length; i++) {
    img.pixels[i] = colour; 
  }
  return img;
}
