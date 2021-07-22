/**
 * One node in a path.
 *
 * Paths contain a list of point coordinates.
 */
class Node extends PVector {
  private float _size;
  private color _color;
  private float _angle;  
  //private float noiseDepth; // for spray pattern generation
  //private float timestamp;  // for replay
  //PGraphics targetBuffer;
  private boolean _is_drawn = false;
  private boolean _debug = false;
  
  
  public Node(float x, float y, float size, color colour) {
    super(x, y);
    this._size = size;
    this._color = colour;
    this._angle = 0.0; // TODO
    //this.noiseDepth = random(1.0);
    //this.timestamp  = millis();
  }
  
  /**
   * Gets the position of this painting node.
   */
  public PVector get_position() {
    return new PVector(this.x, this.y);
  }
  
  /**
   * Gets the size of this painting node.
   */
  public float get_size() {
    return this._size;
  }
  
  /**
   * Gets the color of this painting node.
   */
  public color get_color() {
    return this._color;
  }
  
  /**
   * Triggers redrawing.
   *
   * If the new value is false, will redraw it on the next pass.
   */
  public void set_is_drawn(boolean value) {
    this._is_drawn = value;
  }
  
  /**
   * Draws this node.
   *
   * @param buffer: The pixel buffer to paint on.
   */
  public boolean draw_node(PGraphics buffer, Brush brush) {
    PVector direction = new PVector(this.x, this.y); // inherited from PVector
    direction.normalize();
    
    if (this._is_drawn) {
      return false; // we draw each knot only once!
      // we store those pixels in a pixel buffer.
    } else {
      brush.draw_brush(buffer, this.x, this.y, this._size, this._color);
      this._is_drawn = true;
      return true;
    }
  }
  
  /**
   * Enables or disables its debug mode.
   */
  public void set_debug(boolean value) {
    this._debug = value;
  }
}

