/**
 * A brush allows one to draw on the screen.
 */
abstract class Brush {
  public Brush() {
    // This class is abstract.
    // Nothing to do.
  }
  
  public abstract void draw_brush(PGraphics buffer, float x, float y, float size, color tint);
}
