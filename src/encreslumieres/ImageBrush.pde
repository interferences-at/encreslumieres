/**
 * Brush that fills with an image.
 */
class ImageBrush extends Brush {
  ArrayList<PImage> _images;
  private boolean _enable_rotation = true;
  private final boolean _enable_whitify = true; // Turn all pixels to white
  
  public ImageBrush() {
    super();
    this._images = new ArrayList<PImage>();
  }
  
  /**
   * Enables or disable the rotation of the images.
   */
  public void set_enable_rotation(boolean value) {
    this._enable_rotation = value;
  }
  
  /**
   * Loads a image given its file name.
   */
  public void load_image(String image_file_name) {
    PImage image = loadImage(image_file_name);
    // Make all pixels white and keep only the alpha of the image for the brush:
    if (_enable_whitify) {
      int numPixels = image.width * image.height;
      image.loadPixels();
      for (int i = 0; i < numPixels; i ++) {
        color pixel = image.pixels[i];
        image.pixels[i] = color(255, 255, 255, alpha(pixel));
      }
      image.updatePixels();
    }
    this._images.add(image);
  }
  
  public final void draw_brush(PGraphics buffer, float x, float y, float size, color tint) {
    PImage chosen_image = null;
    if (this._images.size() == 0) {
      println("ImageBrush::draw_brush: Warning: No image loaded yet.");
      return;
    } else if (this._images.size() == 1) {
      chosen_image = this._images.get(0);
    } else {
      chosen_image = this._images.get((int) random(this._images.size() - 1));
    }
    
    buffer.pushStyle();
    buffer.pushMatrix();
    //buffer.colorMode(RGB, 255);
    buffer.tint(red(tint), green(tint), blue(tint), alpha(tint));
    buffer.translate(x, y);
    if (this._enable_rotation) {
      buffer.rotate(radians(random(0.0, 360.0)));
    }
    buffer.imageMode(CENTER);
    // buffer.blendMode(ADD);
    buffer.image(chosen_image, 0, 0, size, size);
    
    buffer.popMatrix();
    buffer.popStyle();
  }
}
