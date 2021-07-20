/**
 * One stroke we draw with a paintbrush.
 *
 * Each stroke/path contains a list of points/knots/nodes.
 */
class Stroke
{
  private ArrayList<Node> _nodes; // raw point list
  private Node _previous_node;
  private Node _current_node;
  private float _step_size = 1.0; // how many pixels between each
  private Brush _brush = null;
  
  public Stroke()
  {
    // nothing to do
  }

  public Stroke(Node startingPoint)
  {
    this.add_knot(startingPoint);
  }
  
  public Stroke(Node startingPoint, float step_size)
  {
    this._step_size = step_size;
    this.add_knot(startingPoint);
  }
  
  public void set_step_size(float value)
  {
    this._step_size = value;
  }
  
  public void set_brush(Brush brush)
  {
    this._brush = brush;
  }
  
  /**
   * Adds a new knot, either a first knot in a new path, 
   * or one more knot in an existing one.
   */
  public void add_knot(Node k)
  {
    if (this._nodes == null)
    {
      this._create_list(k);
    }
    else
    {
      this._add_node(k);
    }
  }
  
  /**
   * When the first knot is added, we want to create the list.
   */
  private void _create_list(Node k)
  { 
    this._previous_node = k;
    this._current_node = k;
    
    if (this._nodes == null)
    {
      this._nodes = new ArrayList<Node>();
    }
    this._nodes.add(k);
    // XXX this.knots.add(this.currentKnot); // FIXME: why do we add the first knot twice?
  }
  
  /** 
   * Add a new knot and all knots between it and 
   * the previous knot, based on the defined step size.
   */
  private void _add_node(Node k)
  {
    int size = this._nodes.size();
    if (size == 0)
    {
      this._create_list(k);
      return;
    }
    
    this._previous_node = this._nodes.get(size - 1);
    this._current_node = k;
    // Compute the vector from previous to current knot
    PVector prevPos = this._previous_node.get_position();
    PVector newPos  = this._current_node.get_position();
    PVector velocity = PVector.sub(newPos, prevPos);
 
    // How many points can we fit between the two last knots?
    float mag = velocity.mag();
    
    // Create intermediate knots and pass them interpolated parameters
    if (mag > this._step_size)
    {
      float num_steps = mag / this._step_size;
      for (int i = 1; i < num_steps; i++)
      {
        float interpolatedX = lerp(_previous_node.x, _current_node.x, i / num_steps);
        float interpolatedY = lerp(_previous_node.y, _current_node.y, i / num_steps);
        float interpolatedSize  = lerp(_previous_node.get_size(),
                _current_node.get_size(), i / num_steps);
        color interpolatedColor = lerpColor(_previous_node.get_color(),
                _current_node.get_color(), i / num_steps);
        Node stepKnot = new Node(interpolatedX, interpolatedY,
                interpolatedSize, interpolatedColor);
        this._nodes.add(stepKnot);
      }
    }
    else
    {
      this._nodes.add(this._current_node);
    }
  }
  
  public boolean draw_stroke(PGraphics buffer)
  {
    if (this._brush == null)
    {
      println("Warning: Stroke::draw_stroke: brush is null");
      return false;
    }
    else
    {
      if (this._nodes == null)
      {
        //println("No node to draw in draw_stroke");
        return false;
      }
      for (Node p: this._nodes)
      {
        // draws each node only once, on the pixel buffer
        // if a node is already drawn, it won't add any pixel on the buffer.
        // TODO: we should simply return if this stroke has been drawn and if no more node will ever be added to it.
        p.draw_node(buffer, this._brush);
      }
    return true;
    }
  }
  
  public void clear_stroke()
  {
    this._nodes.clear();
  }
}
