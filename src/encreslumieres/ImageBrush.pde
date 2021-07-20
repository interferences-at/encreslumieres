/**
 * Brush that fills with an image.
 */
class ImageBrush extends Brush
{
  ArrayList<PImage> _images;
  private boolean _enable_rotation = true;
  
  public ImageBrush()
  {
    super();
    this._images = new ArrayList<PImage>();
  }
  
  public void set_enable_rotation(boolean value)
  {
    this._enable_rotation = value;
  }
  
  public void load_image(String image_file_name)
  {
    this._images.add(loadImage(image_file_name));
  }
  
  public final void draw_brush(PGraphics buffer, float x, float y, float size, color colour)
  {
    PImage chosen_image = null;
    if (this._images.size() == 0)
    {
      println("ImageBrush::draw_brush: Warning: No image loaded yet.");
      return;
    }
    else if (this._images.size() == 1)
    {
      chosen_image = this._images.get(0);
    }
    else
    {
      chosen_image = this._images.get((int) random(this._images.size() - 1));
    }
    
    buffer.pushStyle();
    buffer.pushMatrix();
    //buffer.colorMode(RGB, 255);
    // println("XXX: draw brush " + red(colour) + " " + green(colour) + " " + blue(colour) + " " + alpha(colour));
    buffer.tint(red(colour), green(colour), blue(colour), alpha(colour));
    buffer.translate(x, y);
    if (this._enable_rotation)
    {
      buffer.rotate(radians(random(0.0, 360.0)));
    }
    buffer.imageMode(CENTER);
    buffer.image(chosen_image, 0, 0, size, size);
    
    buffer.popMatrix();
    buffer.popStyle();
  }
}
