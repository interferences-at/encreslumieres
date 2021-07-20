/**
 * A brush allows one to draw on the screen.
 */
abstract class Brush
{
  public Brush()
  {
  }
  
  public abstract void draw_brush(PGraphics buffer, float x, float y, float size, color tint);
}
