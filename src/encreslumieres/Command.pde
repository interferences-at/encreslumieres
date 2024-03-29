/**
 * @file The class hierarchy of Commands.
 *
 * When we receive an OSC message, we create some commands.
 * Those commands are then applied before drawing each frame.
 */


/**
 * A command is an action to do by the program.
 *
 * Parent class for all commands.
 */
abstract class Command {
  private int _spray_can_index;
  
  public Command(int spray_can_index) {
    this._spray_can_index = spray_can_index;
  }
  
  public int get_spray_can_index() {
    return this._spray_can_index;
  }
  
  public abstract void apply(App app);
}


/**
 * Adds a node to a stroke.
 */
public class AddNodeCommand extends Command {
    private float _x;
    private float _y;
    private float _size;
    
    public AddNodeCommand(int spray_can_index, float x, float y, float size) {
      super(spray_can_index);
      this._x = x;
      this._y = y;
      this._size = size;
    }
    
    public AddNodeCommand(int spray_can_index, float x, float y) {
      super(spray_can_index);
      this._x = x;
      this._y = y;
      this._size =  64.0; // FIXME
    }
    
    public final void apply(App app) {
      app.apply_add_node(this.get_spray_can_index(), this._x, this._y); // TODO , this._size);
    }
}


/**
 * Creates a new stroke.
 */
public class NewStrokeCommand extends Command {
    private float _x = -1.0;
    private float _y = -1.0;
    private float _size = -1.0;
    
    public NewStrokeCommand(int spray_can_index, float x, float y, float size) {
      super(spray_can_index);
      this._x = x;
      this._y = y;
      this._size = size;
    }
    
    public NewStrokeCommand(int spray_can_index, float x, float y) {
      super(spray_can_index);
      this._x = x;
      this._y = y;
    }
    
    public NewStrokeCommand(int spray_can_index) {
      super(spray_can_index);
    }
    
    public final void apply(App app) {
      if (this._x == -1.0) {
        app.apply_new_stroke(this.get_spray_can_index());
      } else if (this._size == -1.0) {
        app.apply_new_stroke(this.get_spray_can_index(), this._x, this._y);
      } else {
        app.apply_new_stroke(this.get_spray_can_index(), this._x, this._y, this._size);
      }
    }
}


/**
 * Clears the screen for a given layer.
 */
public class ClearCommand extends Command {
    private int _layer_index;

    public ClearCommand(int spray_can_index, int layer_index) {
      super(spray_can_index);
      this._layer_index = layer_index;
    }
    
    public final void apply(App app) {
      app.apply_clear(this._layer_index);
    }
}
