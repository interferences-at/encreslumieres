/**
 * Round eraser.
 */
class EraserBrush extends Brush
{
  public EraserBrush()
  {
    super();
  }
  
  public final void draw_brush(PGraphics buffer, float x, float y, float size, color colour)
  {
    color c = color(0, 0, 0, 0); // transparent black
    float radius = size / 2.0;
    //canvas.beginDraw();
    buffer.loadPixels();
    for (int index_x = 0; index_x < buffer.width; index_x ++)
    {
      for (int index_y = 0; index_y < buffer.height; index_y ++)
      {
        float distance = dist(index_x, index_y, x, y);
        if (distance <= radius)
        {
          int loc = index_x + index_y * buffer.width;
          buffer.pixels[loc] = c;
        }
      }
    }
    buffer.updatePixels();
    //canvas.endDraw();
  }
}
