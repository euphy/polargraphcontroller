public final class BLOBable_blueBlobs implements BLOBable{
  private PImage img_;
  int col = color(0, 0, 255);
  
  public BLOBable_blueBlobs(PImage img){
    img_ = img;
  }
  
  //@Override
  public final void init() {
  }
  
  //@Override
  public final void updateOnFrame(int width, int height) {
  }
  //@Override
  public final boolean isBLOBable(int pixel_index, int x, int y) {
    if( img_.pixels[pixel_index] ==  col){
      return true;
    } else {
      return false;
    }
  }
}
