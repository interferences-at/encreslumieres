/**
 * One node in a path.
 */
class Node extends PVector
{  
  private float _size;
  private color _color;
  private float _angle;  
  //private float noiseDepth; // for spray pattern generation
  //private float timestamp;  // for replay
  //PGraphics targetBuffer;
  private boolean _is_drawn = false;
  private boolean _debug = false;
  
  
  public Node(float x, float y, float size, color colour)
  {
    super(x, y);
    this._size = size;
    this._color = colour;
    this._angle = 0.0; // TODO
    //this.noiseDepth = random(1.0);
    //this.timestamp  = millis();
  }
  
  public PVector get_position()
  {
    return new PVector(this.x, this.y);
  }
  
  public float get_size()
  {
    return this._size;
  }
  
  public color get_color()
  {
    return this._color;
  }
  
  /**
   * Triggers redrawing.
   */
  public void set_is_drawn(boolean value)
  {
    this._is_drawn = value;
  }
  
  /**
   * @param buffer: The pixel buffer to paint on.
   */
  public boolean draw_node(PGraphics buffer, Brush brush)
  {
    PVector direction = new PVector(this.x, this.y); // inherited from PVector
    direction.normalize();
    
    if (this._is_drawn)
    {
      return false; // we draw each knot only once!
      // we store those pixels in a pixel buffer.
    }
    else
    {
      brush.draw_brush(buffer, this.x, this.y, this._size, this._color);
      this._is_drawn = true;
      return true;
    }
  }
  
  public void set_debug(boolean value)
  {
    this._debug = value;
  }
}