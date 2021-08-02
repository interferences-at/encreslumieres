import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;

final String VERSION = "1.0.1";

/**
 * Encres & lumières
 * Spray paint controlled via OSC.
 * Syphon output.
 * Dependencies:
 * - oscP5
 * - syphon
 *
 * To run: Command-R (or Control-R)
 * To run full screen: Command-Shift-R (or Control-Shift-R)
 * 
 * Interactive controls:
 * - z: undo 
 * - r: redo
 */
class App {
  // private constants
  private final int OSC_SEND_PORT = 13333;
  private final String OSC_SEND_HOST = "127.0.0.1";
  private final int BLOB_INPUT_WIDTH = 720; // The PS3 Eye camera is 640x480
  private final int BLOB_INPUT_HEIGHT = 480; // and blobdetective sends us the blob position in that range
  private final int NUM_SPRAY_CANS = 6; // maximum number of spraycans - not too many is more optimized
  private final int MOUSE_GRAFFITI_IDENTIFIER = 0; // the index of the mouse spraycan
  //private final String BACKGROUND_IMAGE_NAME = "background.png"; // you can change the background image by changing this file
  private int DEFAULT_BRUSH_INDEX = 0;
  private int DEFAULT_LAYER_INDEX = 0;
  /*
   * Now, the /force we receive from the Arduino over wifi is 
   * within the range [0,1023] and we invert the number, so that
   * if we received, 100, example, we will turn it here into
   * 1023 - 100, which results in 923. Now we will compare it to
   * a threshold, for example 400. If that inverted force is over
   * 400, the brush will be on. this._force_threshold is what you will
   * need to change often. See below.
   */
  final int FORCE_MAX = 1700; // DO NOT change this
  int _force_threshold = 300; // Please change this! FSR threshold. (FSR is in the range [0,1023]

  // private attributes
  private boolean _verbose = false;
  private int _osc_receive_port = 8888;
  private int _width = 1920; // window width
  private int _height = 1080; // window height
  // private PGraphics _test_buffer = null;
  // PImage _background_image;
  OscP5 _osc_receiver;
  NetAddress _osc_send_address;
  ArrayList<SprayCan> _spray_cans;
  ArrayList<Brush> _brushes;
  ArrayList<Command> _commands;
  ArrayList<Layer> _layers;
  boolean _mouse_is_pressed = false;
  boolean debug_force = false;
  
  float MINIMUM_ALPHA = 0.0; // Here is the min/max alpha ratio according to force FSR pressure sensor
  float MAXIMUM_ALPHA = 0.6;
  int NUM_LAYERS = 10;
  
  /**
   * Constructor.
   * 
   * See this.setup_cb() for more initialization. (OSC receiver, etc.)
   */
  public App(int canvasWidth, int canvasHeight) {
    this._width = canvasWidth;
    this._height = canvasHeight;
    this._brushes = new ArrayList<Brush>();
    this._commands = new ArrayList<Command>();
    this._load_brushes();
    //this._background_image = loadImage(BACKGROUND_IMAGE_NAME);

    // Layers:
    this._layers = new ArrayList<Layer>();
    for (int i = 0; i < NUM_LAYERS; i++) {
      Layer item = new Layer(this._width, this._height);
      this._layers.add(item);
    }
    Layer defaultLayer = this._layers.get(this.DEFAULT_LAYER_INDEX);

    // Spray cans:
    this._spray_cans = new ArrayList<SprayCan>();
    for (int i = 0; i < this.NUM_SPRAY_CANS; i++)
    {
      SprayCan item = new SprayCan(this._width, this._height, defaultLayer);
      item.set_color(color(255, 255, 255, 255)); // default color is orange
      item.set_current_brush(this._brushes.get(this.DEFAULT_BRUSH_INDEX));
      item.set_layer(defaultLayer);
      this._spray_cans.add(item);
    }
    
    // XXX See this.setup_cb() for more initialization. (OSC receiver, etc.)
  }
  
  public void set_force_threshold(int value) {
    // TODO: we could have a different force threshold for each spraycan
    this._force_threshold = value;
  }
  
  private synchronized void _push_command(Command command) {
    this._commands.add(command);
  }
  
  private synchronized Command _pop_command() {
    Command ret = null;
    if (this._commands.size() > 0)
    {
      ret = this._commands.get(0);
      this._commands.remove(0);
    }
    return ret;
  }
  
  private void _consume_commands() {
    // Happens in the draw_cb thread.
    final int MAX_COMMANDS = this._commands.size();
    for (int i = 0; i < MAX_COMMANDS; i ++) {
      Command command = this._pop_command();
      if (command == null) {
        break;
      } else {
        command.apply(this);
      }
    }
  }
  
  private void _add_one_brush(String image_file_name) {
    Brush image_brush = new ImageBrush();
    ((ImageBrush) image_brush).load_image(image_file_name);
    this._brushes.add(image_brush);
  }
  
  /**
   * Loads all the brushes.
   *
   * Modify this method when we add some new PNG images to draw with.
   * (or any other kind of brush)
   */
  private void _load_brushes() {
    //Brush point_shader_brush = new PointShaderBrush();
    //this._brushes.add(point_shader_brush);
    
    this._brushes.add((Brush) new EraserBrush()); // 0
    
    //Brush image_brush = new ImageBrush();
    //((ImageBrush) image_brush).load_image("brush_A_1.png");
    //this._brushes.add(image_brush);
    
    this._add_one_brush("01_BizzareSplat_64x64.png");
    this._add_one_brush("02_DoubleSpot_64x64.png");
    this._add_one_brush("03_FatLine_64x64.png");
    this._add_one_brush("04_LargeSplat_64x64.png");
    this._add_one_brush("05_LargeSplat2_64x64.png");
    this._add_one_brush("06_MediumSplat_64x64.png");
    this._add_one_brush("07_ParticuleSpot_64x64.png");
    this._add_one_brush("08_PlainSpot_64x64.png");
    this._add_one_brush("09_SideSpot_64x64.png");
    this._add_one_brush("10_SmallSplat_64x64.png");
    this._add_one_brush("11_SplatSpot_64x64.png");
    this._add_one_brush("12_SpotSplat_64x64.png");

    ImageBrush image_brush = new ImageBrush();
    image_brush.load_image("13_Part01_00000_64x64.png");
    image_brush.load_image("13_Part01_00001_64x64.png");
    image_brush.load_image("13_Part01_00002_64x64.png");
    image_brush.load_image("13_Part01_00003_64x64.png");
    image_brush.load_image("13_Part01_00004_64x64.png");
    image_brush.load_image("13_Part01_00005_64x64.png");
    image_brush.load_image("13_Part01_00006_64x64.png");
    image_brush.load_image("13_Part01_00007_64x64.png");
    image_brush.load_image("13_Part01_00008_64x64.png");
    image_brush.load_image("13_Part01_00009_64x64.png");
    image_brush.load_image("13_Part01_00010_64x64.png");
    image_brush.load_image("13_Part01_00011_64x64.png");
    image_brush.load_image("13_Part01_00012_64x64.png");
    image_brush.load_image("13_Part01_00013_64x64.png");
    image_brush.load_image("13_Part01_00014_64x64.png");
    image_brush.load_image("13_Part01_00015_64x64.png");
    image_brush.load_image("13_Part01_00016_64x64.png");
    image_brush.load_image("13_Part01_00017_64x64.png");
    image_brush.load_image("13_Part01_00018_64x64.png");
    image_brush.load_image("13_Part01_00019_64x64.png");
    image_brush.load_image("13_Part01_00020_64x64.png");
    image_brush.load_image("13_Part01_00021_64x64.png");
    image_brush.load_image("13_Part01_00022_64x64.png");
    image_brush.load_image("13_Part01_00023_64x64.png");
    image_brush.load_image("13_Part01_00024_64x64.png");
    image_brush.load_image("13_Part01_00025_64x64.png");
    image_brush.load_image("13_Part01_00026_64x64.png");
    image_brush.load_image("13_Part01_00027_64x64.png");
    image_brush.load_image("13_Part01_00028_64x64.png");
    image_brush.load_image("13_Part01_00029_64x64.png");
    image_brush.load_image("13_Part01_00030_64x64.png");
    image_brush.load_image("13_Part01_00031_64x64.png");
    image_brush.load_image("13_Part01_00032_64x64.png");
    image_brush.load_image("13_Part01_00033_64x64.png");
    image_brush.load_image("13_Part01_00034_64x64.png");
    image_brush.load_image("13_Part01_00035_64x64.png");
    image_brush.load_image("13_Part01_00036_64x64.png");
    image_brush.load_image("13_Part01_00037_64x64.png");
    image_brush.load_image("13_Part01_00038_64x64.png");
    image_brush.load_image("13_Part01_00039_64x64.png");
    image_brush.load_image("13_Part01_00040_64x64.png");
    image_brush.load_image("13_Part01_00041_64x64.png");
    image_brush.load_image("13_Part01_00042_64x64.png");
    image_brush.load_image("13_Part01_00043_64x64.png");
    image_brush.load_image("13_Part01_00044_64x64.png");
    image_brush.load_image("13_Part01_00045_64x64.png");
    image_brush.load_image("13_Part01_00046_64x64.png");
    image_brush.load_image("13_Part01_00047_64x64.png");
    image_brush.load_image("13_Part01_00048_64x64.png");
    image_brush.load_image("13_Part01_00049_64x64.png");
    this._brushes.add((Brush) image_brush);
    
    DEFAULT_BRUSH_INDEX = 13; // FIXME: Does this have an effect?
    
    this._brushes.add((Brush) new EraserBrush()); // 14
  }
  
  /**
   * Checks if a given spray can index exists.
   */
  public boolean has_can_index(int spray_can_index) {
    return (0 <= spray_can_index && spray_can_index < this.NUM_SPRAY_CANS);
  }

  /**
   * Checks if a given layer index exists.
   */
  public boolean has_layer(int layer_index) {
    return (0 <= layer_index && layer_index < this.NUM_LAYERS);
  }
  
  /**
   * Chooses a brush for a given spray can.
   */
  public boolean choose_brush(int spray_can_index, int brush_index) {
    if (has_can_index(spray_can_index)) {
      if (brush_index >= this._brushes.size()) {
        println("Warning: no such brush index: " + brush_index); 
        return false;
      } else {
        this._spray_cans.get(spray_can_index).set_current_brush(this._brushes.get(brush_index));
        return true;
      }
    } else {
      println("Warning: no such spray can index: " + spray_can_index); 
      return false;
    }
  }

  public void set_verbose(boolean value) {
    this._verbose = value;
  }

  /**
   * Sets the OSC receive port number.
   * Call this before calling setup_cb().
   */
  public void set_osc_receive_port(int value) {
    // TODO: reset the this._osc_receiver when this is called.
    this._osc_receive_port = value;
  }

  /**
   * Sets the size of the canvas. 
   * Called from the main sketch file.
   */
  public void set_sketch_size(int size_width, int size_height) {
    this._width = size_width;
    this._height = size_height;
  }
  
  /**
   * Sets up the app.
   * Called from the main sketch file.
   */
  public void setup_cb() {
    //this._test_buffer = createGraphics(this._width, this._height, P3D);
    // start oscP5, listening for incoming messages at a given port
    this._osc_receiver = new OscP5(this, this._osc_receive_port);
    this._osc_send_address = new NetAddress(OSC_SEND_HOST, OSC_SEND_PORT);
  }

  /**
   * Draws the whole sketch.
   *
   * Called from the main sketch file.
   */
  public void draw_cb(float mouse_x, float mouse_y) {
    background(0, 0, 0, 0);
    // background(0);
    //image(this._background_image, 0, 0);
    
    if (this._mouse_is_pressed) {
      // FIXME: we must set the value of the force sensor to set the alpha_ratio
      this._push_command((Command)
          new AddNodeCommand(MOUSE_GRAFFITI_IDENTIFIER, mouse_x, mouse_y)); // , float size
    }
    // apply some commands in the queue, if needed.
    // we use that queue since the OSC receiver is in a separate thread.
    // TODO: create a queue of OSC messages instead of command - for a simpler code?
    this._consume_commands();
    
    // Render the spray cans, each to its own layer:
    for (int spraycan_index = 0; spraycan_index < this._spray_cans.size(); spraycan_index++) {
      SprayCan spraycan = this._spray_cans.get(spraycan_index);
      spraycan.draw_spraycan();
    }
    // Draw each layer to the main window, starting from layer 0:
    for (int layer_index = 0; layer_index < NUM_LAYERS; layer_index++) {
      Layer layer = this._layers.get(layer_index);
      layer.draw_layer();
    }
    // we do not care about the layer number for the rendering order of the cursors
    for (int spraycan_index = 0; spraycan_index < this._spray_cans.size(); spraycan_index++) {
      SprayCan spraycan = this._spray_cans.get(spraycan_index);
      spraycan.draw_cursor();
    }
  }

  private void log_debug(String message) {
    if (this._verbose) {
      println(message);
    }
  }

  private void log_info(String message) {
    println(message);
  }

  public void mousePressed_cb(float mouse_x, float mouse_y) {
    this._mouse_is_pressed = true;
    
    if (this._spray_cans.get(MOUSE_GRAFFITI_IDENTIFIER).get_enable_linked_strokes()) {
      // no need to add a new node, since it will be added in the blob cb.
      //this._push_command((Command)
      //    new AddNodeCommand(MOUSE_GRAFFITI_IDENTIFIER, x, y));
    } else {
      this._push_command((Command)
          new NewStrokeCommand(MOUSE_GRAFFITI_IDENTIFIER));
    }
  }

  public void mouseReleased_cb(float mouse_x, float mouse_y) {
    // add EndStrokeCommand
    this._mouse_is_pressed = false;
  }

  public void keyPressed_cb() {
    if (key == CODED && keyCode == SHIFT) {
      this.handle_enable_linked_strokes(MOUSE_GRAFFITI_IDENTIFIER, true);
    } else if (key == 'x' || key == 'X') {
      this.handle_clear(MOUSE_GRAFFITI_IDENTIFIER);
    }
  }
  
  public void keyReleased_cb() {
    if (key == CODED && keyCode == SHIFT) {
      this.handle_enable_linked_strokes(MOUSE_GRAFFITI_IDENTIFIER, true);
    }
  }
  
  /**
   * Convert a X coordinate from blob range to display range.
   */
  private float map_x(int spray_can_index, float value) {
    SprayCan spray_can = this._spray_cans.get(spray_can_index);
    float scale_center_x = spray_can.get_scale_center_x();
    float scale_factor = spray_can.get_scale_factor();
    
    float from_x = (this._width * scale_center_x) - (this._width / 2.0 * scale_factor);
    float to_x = (this._width * scale_center_x) + (this._width / 2.0 * scale_factor);
    return map(value, 0.0, BLOB_INPUT_WIDTH, from_x, to_x);
  }

  /**
   * Convert a Y coordinate from blob range to display range.
   */
  private float map_y(int spray_can_index, float value) {
    float height_3_4 = this._width * (3.0 / 4.0);
    SprayCan spray_can = this._spray_cans.get(spray_can_index);
    float scale_center_y = spray_can.get_scale_center_y();
    float scale_factor = spray_can.get_scale_factor();
    
    float from_y = (height_3_4 * scale_center_y) - (height_3_4 / 2.0 * scale_factor);
    float to_y = (height_3_4 * scale_center_y) + (height_3_4 / 2.0 * scale_factor);
    return map(value, 0.0, BLOB_INPUT_HEIGHT, from_y, to_y);
  }

  /**
   * Handles /color OSC messages.
   */
  private void handle_color(int spray_can_index, int r, int g, int b, int a) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.set_color(color(r, g, b, a));
    } else {
      println("No such can index " + spray_can_index);
    }
  }
  
  /**
   * Sets the center of the scale window.
   * So we store the scale center and factor in the SprayCan attributes
   * and then we use it in map_x and map_y methods of the App class.
   *
   * @param x: range [0,1]
   * @param y: range [0,1]
   */
  private void handle_scale_center(int spray_can_index, float x, float y) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.set_scale_center(x, y);
    } else {
      println("No such can index " + spray_can_index);
    }
  }
  
  /**
   * @param factor: range [0,1] How big the scaled window will be. (1 is the default)
   */
  private void handle_scale_factor(int spray_can_index, float factor) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.set_scale_factor(factor);
    } else {
      println("No such can index " + spray_can_index);
    }
  }

  /**
   * Handles /set/step_size OSC messages.
   * For distance between each brush. (in pixels)
   */
  private void handle_set_step_size(int spray_can_index, float value) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.set_step_size(value);
    } else {
      println("No such can index " + spray_can_index);
    }
  }

  /**
   * Handles /brush/weight OSC messages.
   */
  private void handle_brush_weight(int spray_can_index, int weight) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.set_brush_weight(weight);
    } else {
      println("No such can index " + spray_can_index);
    }
  }
  
  /**
   * Handles /brush/choice OSC messages.
   */
  private void handle_brush_choice(int spray_can_index, int brush_index) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      if (brush_index >= this._brushes.size()) {
        println("no such brush index " + brush_index);
      } else {
        Brush brush = this._brushes.get(brush_index);
        spray_can.set_current_brush(brush);
      }
    } else {
      println("No such can index " + spray_can_index);
    }
  }
  
  private float _map_force_to_alpha_ratio(float value)
  {
    float ret = map(value, this._force_threshold, this.FORCE_MAX, MINIMUM_ALPHA, MAXIMUM_ALPHA);
    ret = min(ret, 1.0);
    ret = max(ret, 0.0); // clip within [0,1]
    return ret;
  }

  /**
   * Handles /blob OSC messages.
   */
  private void handle_blob(int spray_can_index, int x, int y, int size) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      float mapped_x = this.map_x(spray_can_index, x);
      float mapped_y = this.map_y(spray_can_index, y);
      spray_can.set_cursor_x_y_size(mapped_x, mapped_y, size);
      if (spray_can.get_is_spraying()) {
        this._push_command((Command)
            new AddNodeCommand(spray_can_index, mapped_x, mapped_y, size));
      }
    } else {
      println("No such can index " + spray_can_index);
    }
  }
  
  /**
   * Handles /layer OSC messages.
   * @param layer_number index within the range [0,NUM_LAYERS-1]
   */
  private void handle_layer(int spray_can_index, int layer_number) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      if (layer_number >= NUM_LAYERS) {
        println("Layer number too big: " + NUM_LAYERS);
      } else {
        Layer layer = this._layers.get(layer_number);
        spray_can.set_layer(layer);
      }
    } else {
      println("No such can index " + spray_can_index);
    }
  }
  
  /**
   * Given a force amount (from the FSR sensor)
   * it converts it to a boolean: is pressed or not.
   */
  private boolean _force_to_is_pressed(float force) {
    boolean ret = false;
    if (force > this._force_threshold) {
      ret = true;
    }
    return ret;
  }
  
  /**
   * Handles /force OSC messages.
   */
  private void handle_force(int spray_can_index, float force) {
    // Invert the number (only once here)
    //force = FORCE_MAX - force;

    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      if (this.debug_force) {
        // println("INDEX: " + spray_can_index);
        println("FORCE: " + force);
      }
      boolean is_pressed = this._force_to_is_pressed(force);
      boolean was_pressed = spray_can.get_is_spraying();
      spray_can.set_is_spraying(is_pressed);
      spray_can.set_alpha_ratio(this._map_force_to_alpha_ratio(force));
      if (! was_pressed && is_pressed) {
        if (this.debug_force) {
          println("FORCE: NEW STROKE");
        }
        
        // create the new stroke - or just add a new node in the previous stroke if linked strokes are enabled
        if (spray_can.get_enable_linked_strokes()) {
          // nothing to do
        } else {
          this._push_command((Command)
              new NewStrokeCommand(spray_can_index)); // TODO: should we already create the first node, for faster response?
        }
      }
    } else {
      println("No such can index " + spray_can_index);
    }
  }
  
  private void handle_enable_linked_strokes(int spray_can_index, boolean enable) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.set_enable_linked_strokes(enable);
    } else {
      println("No such can index " + spray_can_index);
    }
  }

  /**
   * Handles clear OSC messages.
   */
  private void handle_clear(int layer_index) {
    int useless_spraycan_arg = 0;
    if (this.has_layer(layer_index)) {
      this._push_command((Command)
          new ClearCommand(useless_spraycan_arg, layer_index));
    } else {
      println("No such layer index " + layer_index);
    }
  }
  
  /**
   * Called by a command.
   */
  public void apply_add_node(int spray_can_index, float x, float y) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.add_node(x, y);
    } else {
      println("Warning: No such spray can: " + spray_can_index);
    }
  }
  
  /**
   * Called by a command.
   */
  public void apply_new_stroke(int spray_can_index) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.start_new_stroke();
    } else {
      println("Warning: No such spray can: " + spray_can_index);
    }
  }
  
  /**
   * Called by a command.
   */
  public void apply_new_stroke(int spray_can_index, float x, float y) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.start_new_stroke(x, y);
    } else {
      println("Warning: No such spray can: " + spray_can_index);
    }
  }
  
  /**
   * Called by a command.
   */
  public void apply_new_stroke(int spray_can_index, float x, float y, float size) {
    if (this.has_can_index(spray_can_index)) {
      SprayCan spray_can = this._spray_cans.get(spray_can_index);
      spray_can.start_new_stroke(x, y, size);
    } else {
      println("Warning: No such spray can: " + spray_can_index);
    }
  }
  
  /**
   * Called by a command.
   */
  public void apply_clear(int layer_index) {
    if (this.has_layer(layer_index)) {
      Layer layer = this._layers.get(layer_index);
      layer.clear_layer();
    } else {
      println("Warning: No such layer" + layer_index);
    }
  }

  /**
   * Incoming osc message are forwarded to the oscEvent method.
   *
   * The name of this method is set up by the oscP5 library.
   */
  public void oscEvent(OscMessage message) {
    int identifier = 0;
    //print("Received " + message.addrPattern() + " " + message.typetag() + "\n");
    
    // ---  /force ---
    if (message.checkAddrPattern("/1/raw"))
    {
      // TODO: parse string identifier as a first OSC argument
      float force = 0;
      
      if (message.checkTypetag("ffffffffffffffffffffff")) {
        identifier = 1;
        force = message.get(12).floatValue();
        //println(force);
      } else {
        println("Wrong OSC typetags for /1/raw: " + message.typetag());
        // we use to support only the value - no identifier, but
        // not anymore
      }
      this.handle_force(identifier, force);
    }
    else if (message.checkAddrPattern("/2/raw"))
    {
      // TODO: parse string identifier as a first OSC argument
      float force = 0;
      if (message.checkTypetag("ffffffffffffffffffffff")) {
        identifier = 2;
        force = message.get(12).floatValue();
        //println(force);
      } else {
        println("Wrong OSC typetags for /2/raw: " + message.typetag());
        // we use to support only the value - no identifier, but
        // not anymore
      }
      this.handle_force(identifier, force);
    }
    else if (message.checkAddrPattern("/3/raw"))
    {
      // TODO: parse string identifier as a first OSC argument
      float force = 0;
      if (message.checkTypetag("ffffffffffffffffffffff")) {
        identifier = 3;
        force = message.get(12).floatValue();
        //println(force);
      } else {
        println("Wrong OSC typetags for /3/raw: " + message.typetag());
        // we use to support only the value - no identifier, but
        // not anymore
      }
      this.handle_force(identifier, force);
    }
    else if (message.checkAddrPattern("/4/raw"))
    {
      // TODO: parse string identifier as a first OSC argument
      float force = 0;
      if (message.checkTypetag("ffffffffffffffffffffff")) {
        identifier = 4;
        force = message.get(12).floatValue();
        //println(force);
      } else {
        println("Wrong OSC typetags for /4/raw: " + message.typetag());
        // we use to support only the value - no identifier, but
        // not anymore
      }
      this.handle_force(identifier, force);
    }
    else if (message.checkAddrPattern("/5/raw"))
    {
      // TODO: parse string identifier as a first OSC argument
      float force = 0;
      if (message.checkTypetag("ffffffffffffffffffffff")) {
        identifier = 5;
        force = message.get(12).floatValue();
        //println(force);
      } else {
        println("Wrong OSC typetags for /5/raw: "  + message.typetag());
        // we use to support only the value - no identifier, but
        // not anymore
      }
      this.handle_force(identifier, force);
    }

    // ---  /blob ---
    else if (message.checkAddrPattern("/blob"))
    {
      int x = 0;
      int y = 0;
      int size = 0;
      if (message.checkTypetag("iiii")) {
        identifier = message.get(0).intValue();
        x = message.get(1).intValue();
        y = message.get(2).intValue();
        size = message.get(3).intValue();
      } else {
        println("Wrong OSC typetags for /blob: "  + message.typetag());
      }
      this.handle_blob(identifier, x, y, size);
    }
    
    // ---  /color ---
    else if (message.checkAddrPattern("/color"))
    {
      int r = 255;
      int g = 255;
      int b = 255;
      int a = 255;
      if (message.checkTypetag("iiii")) {
        identifier = message.get(0).intValue();
        r = message.get(1).intValue();
        g = message.get(2).intValue();
        b = message.get(3).intValue();
      } else if (message.checkTypetag("iiiii")) {
        identifier = message.get(0).intValue();
        r = message.get(1).intValue();
        g = message.get(2).intValue();
        b = message.get(3).intValue();
        a = message.get(4).intValue();
      } else if (message.checkTypetag("iffff")) {
        identifier = message.get(0).intValue();
        r = (int) message.get(1).floatValue();
        g = (int) message.get(2).floatValue();
        b = (int) message.get(3).floatValue();
        a = (int) message.get(4).floatValue();
      } else {
        println("Wrong OSC typetags for /color: " + message.typetag());
      }
      this.handle_color(identifier, r, g, b, a);
    }
    
    // ---  /brush/weight ---
    else if (message.checkAddrPattern("/brush/weight"))
    {
      int weight = 100;
      if (message.checkTypetag("ii")) {
        identifier = message.get(0).intValue();
        weight = message.get(1).intValue();
      } else if (message.checkTypetag("if")) {
        identifier = message.get(0).intValue();
        weight = message.get(1).intValue();
      } else {
        println("Wrong OSC typetags for /brush/weight: " + message.typetag());
      }
      this.handle_brush_weight(identifier, weight);
    }
    
    // ---  /brush/choice ---
    else if (message.checkAddrPattern("/brush/choice"))
    {
      int brush_choice = 0;
      if (message.checkTypetag("ii")) {
        identifier = message.get(0).intValue();
        brush_choice = message.get(1).intValue();
      } else {
        println("Wrong OSC typetags for /brush/choice: " + message.typetag());
      }
      this.handle_brush_choice(identifier, brush_choice);
    }
    
    // ---  /undo ---
    else if (message.checkAddrPattern("/undo"))
    {
      if (message.checkTypetag("i")) {
        identifier = message.get(0).intValue();
      }
    }
    
     // ---  /clear ---
    else if (message.checkAddrPattern("/clear"))
    {
      if (message.checkTypetag("i")) {
        int layer_index = message.get(0).intValue();
        this.handle_clear(layer_index);
      }
    }
    
    else if (message.checkAddrPattern("/set/force/threshold"))
    {
      if (message.checkTypetag("i")) {
        int value = message.get(0).intValue();
        this.set_force_threshold(value);
      }
    }

    else if (message.checkAddrPattern("/set/step_size"))
    {
      if (message.checkTypetag("if")) {
        identifier = message.get(0).intValue();
        float value = message.get(1).floatValue();
        this.handle_set_step_size(identifier, value);
      }
    }
    
    else if (message.checkAddrPattern("/scale/center"))
    {
      if (message.checkTypetag("iff")) {
        identifier = message.get(0).intValue();
        float x = message.get(1).floatValue();
        float y = message.get(2).floatValue();
        this.handle_scale_center(identifier, x, y);
      }
    }
    
    else if (message.checkAddrPattern("/scale/factor"))
    {
      if (message.checkTypetag("if")) {
        identifier = message.get(0).intValue();
        float value = message.get(1).floatValue();
        this.handle_scale_factor(identifier, value);
      }
    }
    
    // Sets the layer of a spraycan
    else if (message.checkAddrPattern("/layer"))
    {
      if (message.checkTypetag("ii")) {
        identifier = message.get(0).intValue(); // spraycan
        int value = message.get(1).intValue(); // layer
        this.handle_layer(identifier, value);
      }
    }
    
    else if (message.checkAddrPattern("/link_strokes"))
    {
      if (message.checkTypetag("ii")) {
        identifier = message.get(0).intValue();
        boolean value = message.get(1).intValue() == 1;
        this.handle_enable_linked_strokes(identifier, value);
      }
    }

    // fallback
    else
    {
      println("Unknown OSC message.");
    }
  }
}
