public void trace_initTrace(PImage img)
{
  // dummy initCamera(), does nothing
  //  tracetraceEnabled = true;
  img.loadPixels();
  blob_detector = new BlobDetector(img.width, img.height);
  blob_detector.setResolution(1);
  blob_detector.computeContours(true);
  blob_detector.computeBlobPixels(true);
  blob_detector.setMinMaxPixels(10*10, img.width * img.height);
  
  blob_detector.setBLOBable(new BLOBable_blueBlobs(liveImage));
}

public void trace_initCameraProcCam()
{
//  try
//  {
//    String[] cameras = Capture.list();
//    if (cameras.length > 0) {
//      liveCamera = new Capture(this, 640, 480, cameras[0]);
//      //liveCamera.start();
//      traceEnabled = true;
//    }
//  }
//  catch (Exception e)
//  {
//    println("Exception occurred trying to look for attached webcams.  Webcam will not be used. " + e.getMessage());
//    traceEnabled = false;
//  }

}  
//public PImage trace_buildLiveImage()
//{
//  //liveCamera.start();
//  PImage pimg = createImage(640, 480, RGB);
//  pimg.loadPixels();
//  if (liveCamera.available()) {
//    liveCamera.read();
//  }
//  pimg.pixels = liveCamera.pixels;
//  // flip the image left to right
//  if (flipWebcamImage)
//  {
//
//    List<int[]> list = new ArrayList<int[]>(480);
//
//    for (int r=0; r<pimg.pixels.length; r+=640)
//    {
//      int[] temp = new int[640];
//      for (int c=0; c<640; c++)
//      {
//        temp[c] = pimg.pixels[r+c];
//      }
//      list.add(temp);
//    }
//
//    // reverse the list
//    Collections.reverse(list);
//
//    for (int r=0; r<list.size(); r++)
//    {
//      for (int c=0; c<640; c++)
//      {
//        pimg.pixels[(r*640)+c] = list.get(r)[c];
//      }
//    }
//  }
//  pimg.updatePixels();
//  return pimg;
//}

public PImage trace_processImageForTrace(PImage in)
{
  PImage out = createImage(in.width, in.height, RGB);
  out.loadPixels();
  for (int i = 0; i<in.pixels.length; i++) {
    out.pixels[i] = in.pixels[i];
  }
  out.filter(BLUR, blurValue);
  out.filter(GRAY);
  out.filter(POSTERIZE, posterizeValue);
  out.updatePixels();
  return out;
}

public RShape trace_traceImage(Map<Integer, PImage> seps)
{
  RShape allShapes = null;
  if (seps != null)
  {
    //println("detecting...");
    int i = 0;
    int shapeNo = 1;
    allShapes = new RShape();
    for (Integer key : seps.keySet())
    {
      i++;
      //println("Analysing sep " + i + " of " + seps.size());
      PImage sep = seps.get(key);
      blob_detector.setBLOBable(new BLOBable_blueBlobs(sep));
      blob_detector.update();
      ArrayList<Blob> blob_list = blob_detector.getBlobs();
      for (int blob_idx = 0; blob_idx < blob_list.size(); blob_idx++ ) {
        //println("Getting blob " + blob_idx + " of " + blob_list.size());
        // get the current blob from the blob-list
        Blob blob = blob_list.get(blob_idx);
        // get the list of all the contours from the current blob
        ArrayList<Contour> contour_list = blob.getContours();
        // iterate through the contour_list
        for (int contour_idx = 0; contour_idx < contour_list.size(); contour_idx++ ) {
          // get the current contour from the contour-list
          Contour contour = contour_list.get(contour_idx);

          // example how to simplify a contour
          if (liveSimplification > 0) {
            // can improve speed, if the contour is needed for further work
            ArrayList<Pixel> contour_simple = Polyline.SIMPLIFY(contour, 2, 1);
            // repeat the simplifying process a view more times
            for (int simple_cnt = 0; simple_cnt < liveSimplification; simple_cnt++) {
              contour_simple= Polyline.SIMPLIFY(contour_simple, 2, simple_cnt);
            }
            RShape shp = trace_convertDiewaldToRShape(contour_simple);
            if (shp != null)
            {
              shapeNo++;
              //println("adding shape " + shapeNo + " - blob: " + blob_idx + ", contour: " + contour_idx);
              allShapes.addChild(shp);
            }
          }
          else
          {
            RShape shp = trace_convertDiewaldToRShape(contour.getPixels());
            if (shp != null)
              allShapes.addChild(shp);
          }
        }
      }
    }
  }
  // rotate image
  if (rotateWebcamImage)
  {
    allShapes.rotate(radians(-90));
    // transform it so that top left is at 0,0.
    RPoint topLeft = allShapes.getTopLeft();
    allShapes.translate(-topLeft.x, -topLeft.y);
  }
  return allShapes;
}

Map<Integer, PImage> trace_buildSeps(PImage img, Integer keyColour)
{
  // create separations
  // pull out number of colours
  Set<Integer> colours = null;
  List<Integer> colourList = null;

  colours = new HashSet<Integer>();
  for (int i=0; i< img.pixels.length; i++) {
    colours.add(img.pixels[i]);
  }
  colourList = new ArrayList(colours);

  Map<Integer, PImage> seps = new HashMap<Integer, PImage>(colours.size());
  for (Integer colour : colours) {
    PImage sep = createImage(img.width, img.height, RGB);
    sep.loadPixels();
    seps.put(colour, sep);
  }

  for (int i = 0; i<img.pixels.length; i++) {
    Integer pixel = img.pixels[i];
    seps.get(pixel).pixels[i] = keyColour;
  }

  return seps;
}

RShape trace_convertDiewaldToRShape(List<Pixel> points)
{
  RShape shp = null;
  if (points.size() > 2) {
    shp = new RShape();
    Pixel p = points.get(0);
    shp.addMoveTo(float(p.x_), float(p.y_));
    for (int idx = 1; idx < points.size(); idx++) {
      p = points.get(idx);
      shp.addLineTo(float(p.x_), float(p.y_));
    }
    shp.addClose();
  }
  return shp;
}


public void trace_captureCurrentImage(PImage inImage)
{
  captureShape = traceShape;
}

public void trace_captureCurrentImage()
{
//  capturedImage = webcam_buildLiveImage();
  if (getDisplayMachine().imageIsReady())
    trace_captureCurrentImage(getDisplayMachine().getImage());
}

public void trace_processLoadedImage()
{
  trace_captureCurrentImage(getDisplayMachine().getImage());
}

public void trace_saveShape(RShape sh)
{
  SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddhhmmss");
  String dateCode = sdf.format(new java.util.Date());
  String filename = shapeSavePath + shapeSavePrefix + dateCode + shapeSaveExtension;
  RG.saveShape(filename, sh);
}

//public void stop() {
//  liveCamera.stop();
//  super.stop();
//}

